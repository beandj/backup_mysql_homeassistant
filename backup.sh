#!/bin/bash

# Configurações
DATABASE_NAME=""
BACKUP_PATH="/root/bkp"
RCLONE_REMOTE="gdrive:/MYSQL"
BACKUP_FILENAME="${DATABASE_NAME}_$(date +%Y-%m-%d).sql"
ARCHIVE_FILENAME="${DATABASE_NAME}_$(date +%Y-%m-%d).tar.gz"
LOG_FILE="/root/bkp/backup_log_$(date +%Y-%m-%d).log"
MQTT_TOPIC="backup/mysql"
MQTT_BROKER=""
MQTT_USER=""
MQTT_PASS=""

# Função para logar mensagens
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Função para enviar status via MQTT com metadados de dispositivo
send_mqtt() {
    local status="$1"
    local dump="$2"
    local size="$3"
    local uploaded="$4"
    local clean="$5"
    
    mosquitto_pub -h "$MQTT_BROKER" -u "$MQTT_USER" -P "$MQTT_PASS" -t "$MQTT_TOPIC/status\" -m \"{
        \"status\": \"$status\",
        \"dump\": \"$dump\",
        \"size\": \"$size\",
        \"upload\": \"$uploaded\",
        \"clean\": \"$clean\"
    }"
}

# Início do backup
log "Iniciando backup do banco de dados: $DATABASE_NAME"

# Exportar a base de dados
if mysqldump -u root "$DATABASE_NAME" > "$BACKUP_PATH/$BACKUP_FILENAME"; then
    log "Backup do banco de dados realizado com sucesso."
    DUMP=Sucesso
else
    log "Erro ao realizar o backup do banco de dados."
    DUMP=Falha
    exit 1
fi

# Compactar o backup
if tar -czvf "$BACKUP_PATH/$ARCHIVE_FILENAME" -C "$BACKUP_PATH" "$BACKUP_FILENAME"; then
    log "Compactação do backup realizada com sucesso."
    SIZE=$(du -sh "$BACKUP_PATH/$ARCHIVE_FILENAME" | cut -f1)
else
    log "Erro ao compactar o backup."
    SIZE=Falha
    exit 1
fi

# Enviar o backup para o Google Drive
if rclone copy "$BACKUP_PATH/$ARCHIVE_FILENAME" "$RCLONE_REMOTE"; then
    log "Upload do backup para o Google Drive realizado com sucesso."
    SEND=Sucesso
else
    log "Erro ao enviar o backup para o Google Drive."
    SEND=Falha
    exit 1
fi

# Deletar o arquivo de backup da origem
if rm "$BACKUP_PATH/$BACKUP_FILENAME" "$BACKUP_PATH/$ARCHIVE_FILENAME"; then
    log "Arquivos de backup locais deletados com sucesso."
else
    log "Erro ao deletar os arquivos de backup locais."
    exit 1
fi

# Manter apenas os últimos 5 dias no Google Drive
if rclone delete "$RCLONE_REMOTE" --min-age 5d; then
    log "Limpeza dos backups antigos no Google Drive realizada com sucesso."
    CLEAN=Sucesso
else
    log "Erro ao limpar os backups antigos no Google Drive."
    CLEAN=Falha
    exit 1
fi

log "Processo de backup concluído."
send_mqtt "Sucesso" $DUMP $SIZE $SEND $CLEAN
