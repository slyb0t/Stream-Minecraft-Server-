#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

# ChangeLog:
#
# v 0.1 11/10/25 franklin - initial version

BACKUP_DIR="/tmp"
DEB_PKG=(git gnupg)
LRED='\033[1;31m'
MC_HOME="/home/betty"
MC_LOG="/var/log/minecraft"
ME_SU=false

function setup_logging() {
  log_header "Setup Logging"

  if [ ! -d "${MC_LOG}" ]; then
    log_info "create log directory"
    sudo mkdir -p "${MC_LOG}"
  fi

  mkdir -p "${MC_HOME}/workspace" # betty owns this dir

  log_info "Fix logging permissions"
  sudo chown -R betty:games "${MC_LOG}" "${MC_HOME}/workspace" # change the perms

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

function manage_region_files() {
  if [ ! -d "${MC_HOME}/workspace/Minecraft-Region-Fixer" ]; then
    log_info "Install Region Fixer"
    git clone https://github.com/Fenixin/Minecraft-Region-Fixer.git "${MC_HOME}/workspace/Minecraft-Region-Fixer"
  fi

  log_info "Validate the region files"
  python3 "${MC_HOME}/workspace/Minecraft-Region-Fixer/regionfixer.py" "${MC_HOME}/world"

  # resotre the bad ones from backups
  # python3 regionfixer.py -p 4 --replace-wrong --backups

}

function fix_permissions() {
  chmod 664 "${MC_HOME}/world/poi/*"
}

function perform_function() {
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

  if sudo -v &>/dev/null; then
    log_info "sudo is allowed"
    ME_SU=true
  else
    log_warn "sudo is not allowed"
  fi

  if ME_SU; then setup_logging; fi
  #  if ME_SU; then setup_java; fi
  # if ME_SU; then setup_backup; fi
  install_debian
  if ME_SU; then manage_region_files; fi
  #perform_function

}

main "$@"
