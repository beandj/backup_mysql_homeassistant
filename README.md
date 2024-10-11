# Backup MySQL com MQTT Auto Discovery

Este repositório contém scripts para realizar backups automáticos de um banco de dados MySQL e integrá-los ao Home Assistant usando MQTT. O objetivo é facilitar a gestão dos backups e monitorar o status diretamente na interface do Home Assistant.

## Funcionalidades

- **Backup Automático**: Realiza o backup do banco de dados MySQL e o armazena no Google Drive.
- **MQTT Auto Discovery**: Cria sensores no Home Assistant para monitorar o status dos backups, incluindo:
  - Estado do backup
  - Status do dump
  - Tamanho do backup
  - Status do upload para o Google Drive
  - Status da limpeza de backups antigos

## Pré-requisitos

Antes de usar os scripts, você precisará ter os seguintes programas instalados:

- [Mosquitto Clients](https://mosquitto.org/download/)
- [rclone](https://rclone.org/)


### Scripts

- __Script de Backup__: O script realiza o backup do banco de dados MySQL e o armazena no Google Drive. Adicionar ao crontab do servidor de banco. 

- __Script de Auto Discovery__: O script configura os sensores no Home Assistant usando MQTT para monitorar o status do backup. Importar em __Configurações > Automações e Cenas > Scripts__.

### Uso

1. __Configuração__: Certifique-se de editar as configurações nos scripts para refletir seu banco de dados, caminhos de backup e detalhes do MQTT.

2. __Execução__: Execute o script de backup conforme necessário. O script enviará os dados de status via MQTT, que será capturado pelo Home Assistant.

### Contribuições
Contribuições são bem-vindas! Sinta-se à vontade para abrir um problema ou enviar um pull request.

