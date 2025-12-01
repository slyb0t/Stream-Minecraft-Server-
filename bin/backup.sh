#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

# ChangeLog:
#
# v 0.1 11/30/25 franklin - initial version

BACKUP_DIR="/tmp"
DEB_PKG=(git gnupg)
LRED='\033[1;31m'
MC_HOME="/home/betty"
MC_LOG="/var/log/minecraft"
ME_SU=false

if [ -f "${MC_HOME}/bin/common.sh" ]; then
  source "${MC_HOME}/bin/common.sh"
else
  echo -e "${LRED}can not find common.sh.${NC}"
  exit 1
fi
log_info "successfully sourced common.sh" && echo -e "\n"

if sudo -v &> /dev/null ;then
  log_info "sudo is allowed"
  ME_SU=true
else
  log_warn "sudo is not allowed"
fi

var=$(date +"%FORMAT_STRING")
now=$(date +"%m_%d_%Y")
printf "%s\n" $now
today=$(date +"%Y-%m-%d")
printf "Backup from to ${MC_HOME} ${BACKUP_DIR}/backups/$(date +%A)/betty-mc-${today}.tar.xz"

if [ ! -d "${BACKUP_DIR}/backups/$(date +%A)/" ] ; then 

  mkdir "${MC_HOME}/backups"
fi


cp -r "${MC_HOME}/world