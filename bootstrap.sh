#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2012-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

LRED='\033[1;31m'
MC_HOME="/home/betty"
MC_LOG="/var/log/minecraft"

git config --global --add safe.directory "$MC_HOME"
localectl set-locale LANG=en_US.UTF-8

function create_folders() {
  log_header "Create Downloads folder"
  sudo mkdir -p ${HOME}/Downloads
}

function service_user() {
  log_header "Create service user"
  useradd -d /home/franklin/workspace/minecraft -M -u 420 minecraft
}

function setup_java() {
  log_header "Setup java JDK"
  sudo apt install -y default-jdk
}


function setup_logging() {
  
  sudo mkdir -p /var/log/minecraft
  sudo chown -R betty:betty /var/log/minecraft
  if [ ! -e "${MC_HOME}/server_minecraft/logs" ]; then
  ln -s /var/log/minecraft "${MC_HOME}/server_minecraft/logs"
  fi
  /var/log/minecraft/server_minecraft
  server_minecraft/crash-reports 
  /var/log/minecraft/server_minecraft
}

function setup_tls() {
  log_header "setup TLS"
    sudo apt-get install -y certbot
}

function setup_unmined() {
    # install unmined fotr mapping
  log_header "setup unmined"
   pass
}

function setup_nginx(){
  log_header "Setup nginx"
  sudo mkdir -p /var/www/html/map
  sudo chown -R betty:betty /var/www/html
  # set up nginx for the unmined files
  sudo apt-get -y install nginx
}

function main() {

  figlet -f pagga workspace && echo -e "\n"
  if [ -f "./bin/common.sh" ]; then
    source "./bin/common.sh"
  else
    echo -e "${LRED}can not find common.sh.${NC}"
    exit 1
  fi
  log_info "successfully sourced common.sh" && echo -e "\n"

  create_folders
  setup_logging
  setup_nginx
  
}

main "$@"

