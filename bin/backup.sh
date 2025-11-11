#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2021-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

# ChangeLog:
#
# v 0.1 11/10/25 franklin - initial version

BACKUP_DIR="/opt/backup"
DEB_PKG=(git gnupg)
LRED='\033[1;31m'
MC_HOME="/opt/mcserver"
MC_LOG="/var/log/minecraft"

function setup_logging() {
  sudo mkdir -p "${MC_LOG}"
  sudo chown -R betty:games "${MC_LOG}"
  if [ ! -e "${MC_HOME}/logs" ]; then
    log_info "creating link to logs folder"
    ln -s "${MC_LOG}" "${MC_HOME}/logs"
  fi
}

function setup_java() {
  log_header "Setup java JDK"
  sudo apt install -y default-jdk
}

function setup_backup() {
  git config --global --add safe.directory "${MC_HOME}"
  localectl set-locale LANG=en_US.UTF-8
  if [ ! -d "${BACKUP_DIR}" ]; then
    log_info "Creating backup dir: ${BACKUP_DIR}"
    sudo mkdir "${BACKUP_DIR}"
  fi
}

function perform_function(){
    sudo cp -Rp "${MC_HOME}" "${BACKUP_DIR}"
}

function main() {
  if [ -f "${MC_HOME}/bin/common.sh" ]; then
    source "${MC_HOME}/bin/common.sh"
  else
    echo -e "${LRED}can not find common.sh.${NC}"
    exit 1
  fi
  log_info "successfully sourced common.sh" && echo -e "\n"

  setup_logging
  # setup_java
  setup_backup
  install_debian

}

main "$@"