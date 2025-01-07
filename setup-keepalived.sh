#!/bin/bash

# Verificar o hostname da máquina
HOSTNAME=$(hostname)

# Instalar o Keepalived
sudo apt-get install -y keepalived

# Ativar o serviço keepalived na inicialização
sudo systemctl enable keepalived

# Função para configurar o Keepalived no Master (sql1)
configure_master() {
    MASTER_CONF="/etc/keepalived/keepalived.conf"
    
    # Configuração do Keepalived para o sql1 (Master)
    echo "
vrrp_instance VI_1 {
    state MASTER
    interface enp0s8        # Altere para a interface de rede correta
    virtual_router_id 51
    priority 101          # Maior prioridade para o master
    advert_int 1          # Intervalo de anúncios VRRP (em segundos)
    
    virtual_ipaddress {
        192.168.1.100     # Endereço IP Virtual (VIP) a ser usado no cluster
    }

    track_script {
        chk_mysql          # Script para monitorar o serviço MySQL
    }
}
" | sudo tee $MASTER_CONF

    # Criar o script de monitoramento do MySQL
    MYSQL_CHECK_SCRIPT="/etc/keepalived/check_mysql.sh"
    echo "#!/bin/bash
if systemctl is-active --quiet mysql; then
    exit 0
else
    exit 1
fi
" | sudo tee $MYSQL_CHECK_SCRIPT

    # Tornar o script executável
    sudo chmod +x $MYSQL_CHECK_SCRIPT

    # Reiniciar o serviço Keepalived
    sudo systemctl restart keepalived

    # Verificar o status do Keepalived
    sudo systemctl status keepalived
}

# Função para configurar o Keepalived no Backup (sql2)
configure_backup() {
    BACKUP_CONF="/etc/keepalived/keepalived.conf"

    # Configuração do Keepalived para o sql2 (Backup)
    echo "
vrrp_instance VI_1 {
    state BACKUP
    interface enp0s8        # Altere para a interface de rede correta
    virtual_router_id 51
    priority 100          # Prioridade mais baixa para o backup
    advert_int 1          # Intervalo de anúncios VRRP (em segundos)
    
    virtual_ipaddress {
        192.168.1.100     # O mesmo IP Virtual (VIP) que o master
    }

    track_script {
        chk_mysql          # Script para monitorar o serviço MySQL
    }
}
" | sudo tee $BACKUP_CONF

    # Criar o script de monitoramento do MySQL
    MYSQL_CHECK_SCRIPT="/etc/keepalived/check_mysql.sh"
    echo "#!/bin/bash
if systemctl is-active --quiet mysql; then
    exit 0
else
    exit 1
fi
" | sudo tee $MYSQL_CHECK_SCRIPT

    # Tornar o script executável
    sudo chmod +x $MYSQL_CHECK_SCRIPT

    # Reiniciar o serviço Keepalived
    sudo systemctl restart keepalived

    # Verificar o status do Keepalived
    sudo systemctl status keepalived
}

# Verificar em qual máquina o script está sendo executado
if [[ "$HOSTNAME" == "sql1" ]]; then
    echo "Configurando o Keepalived no Master (sql1)..."
    configure_master
elif [[ "$HOSTNAME" == "sql2" ]]; then
    echo "Configurando o Keepalived no Backup (sql2)..."
    configure_backup
else
    echo "Este script só pode ser executado nas máquinas sql1 ou sql2."
    exit 1
fi
