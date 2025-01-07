#!/bin/bash

set -e  # Parar o script em caso de erro

# Variáveis
SQL_VOLUME="sql_storage"
WWW_VOLUME="www_storage"
SQL1="192.168.19.111"
WEB1="192.168.19.121"

LOG_FILE="/var/log/glusterfs_mount.log"

log() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Função para montar o GlusterFS no SQL
configure_sql_mount() {
    log "Configurando montagem do GlusterFS para SQL em /cluster/sql..."

    # Criar o diretório
    sudo mkdir -p /cluster/sql

    # Atualizar /etc/fstab
    sudo sed -i "/$SQL1:\/$SQL_VOLUME \/cluster\/sql glusterfs/d" /etc/fstab
    echo "$SQL1:/$SQL_VOLUME /cluster/sql glusterfs defaults,_netdev 0 0" | sudo tee -a /etc/fstab

    # Montar o volume se necessário
    if mount | grep -q '/cluster/sql'; then
        log "GlusterFS já está montado em /cluster/sql."
    else
        log "Montando o GlusterFS para SQL..."
        sudo mount -t glusterfs "$SQL1:/$SQL_VOLUME" /cluster/sql
    fi

    # Ajustar permissões
    log "Ajustando permissões para mysql:mysql em /cluster/sql..."
    sudo chown -R mysql:mysql /cluster/sql
    sudo chmod -R 0755 /cluster/sql
}

# Função para montar o GlusterFS no Web
configure_www_mount() {
    log "Configurando montagem do GlusterFS para WWW em /cluster/www..."

    # Criar o diretório
    sudo mkdir -p /cluster/www

    # Atualizar /etc/fstab
    sudo sed -i "/$WEB1:\/$WWW_VOLUME \/cluster\/www glusterfs/d" /etc/fstab
    echo "$WEB1:/$WWW_VOLUME /cluster/www glusterfs defaults,_netdev 0 0" | sudo tee -a /etc/fstab

    # Montar o volume se necessário
    if mount | grep -q '/cluster/www'; then
        log "GlusterFS já está montado em /cluster/www."
    else
        log "Montando o GlusterFS para WWW..."
        sudo mount -t glusterfs "$WEB1:/$WWW_VOLUME" /cluster/www
    fi

    # Ajustar permissões
    log "Ajustando permissões para www-data:www-data em /cluster/www..."
    sudo chown -R www-data:www-data /cluster/www
    sudo chmod -R 0755 /cluster/www
}

# Identificar o tipo de máquina
HOSTNAME=$(hostname)

log "Iniciando configuração do GlusterFS na máquina $HOSTNAME..."

if [[ "$HOSTNAME" == "sql1" || "$HOSTNAME" == "sql2" ]]; then
    configure_sql_mount
elif [[ "$HOSTNAME" == "web1" || "$HOSTNAME" == "web2" ]]; then
    configure_www_mount
else
    log "Erro: Este script deve ser executado em sql1, sql2, web1 ou web2." && exit 1
fi

log "Configuração do GlusterFS concluída na máquina $HOSTNAME."
