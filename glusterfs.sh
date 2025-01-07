#!/bin/bash

set -e  # Parar o script em caso de erro

# Variáveis
STORAGE_DIR="/raid1/glusterfs"
SQL_VOLUME="sql_storage"
WWW_VOLUME="www_storage"
WEB1="192.168.19.121"
WEB2="192.168.19.122"
SQL1="192.168.19.111"
SQL2="192.168.19.112"

LOG_FILE="/var/log/glusterfs_create_volumes.log"

log() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Adicionar peers ao cluster
log "Adicionando peers ao cluster GlusterFS..."
for PEER in $WEB1 $WEB2 $SQL1 $SQL2; do
    log "Adicionando peer: $PEER"
    sudo gluster peer probe "$PEER" || log "Peer $PEER já adicionado ou indisponível."
done

# Criar volume para SQL
log "Criando volume GlusterFS para SQL..."
sudo gluster volume create "$SQL_VOLUME" replica 2 transport tcp \
    "$SQL1:$STORAGE_DIR" "$SQL2:$STORAGE_DIR" force || log "Volume SQL já existe."
sudo gluster volume start "$SQL_VOLUME"

# Criar volume para WWW
log "Criando volume GlusterFS para WWW..."
sudo gluster volume create "$WWW_VOLUME" replica 2 transport tcp \
    "$WEB1:$STORAGE_DIR" "$WEB2:$STORAGE_DIR" force || log "Volume WWW já existe."
sudo gluster volume start "$WWW_VOLUME"

log "Volumes GlusterFS criados com sucesso."
