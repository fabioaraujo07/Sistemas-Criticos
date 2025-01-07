#!/bin/bash

#Instalar Nginx
sudo apt-get install -y nginx

# Ativar o serviço Nginx na inicialização
sudo systemctl enable nginx
