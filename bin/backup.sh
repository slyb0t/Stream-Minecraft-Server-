#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2025 franklin 
#
# SPDX-License-Identifier: MIT

# ChangeLog:
#
# v 0.1 11/30/25 franklin - initial version


DEB_PKG=(git gnupg)
LRED='\033[1;31m'
NC='\033[0m' # No Color
MC_HOME="/home/betty"
MC_LOG="/var/log/minecraft"
ME_SU=false
BACKUP_DIR="${MC_HOME}/backups"

# Source common functions
if [ -f "${MC_HOME}/bin/common.sh" ]; then
    source "${MC_HOME}/bin/common.sh"
else
    echo -e "${LRED}Cannot find common.sh.${NC}"
    exit 1
fi
log_info "Successfully sourced common.sh"

# Check for sudo capabilities
if sudo -v &> /dev/null; then
    log_info "Sudo is allowed"
    ME_SU=true
else
    log_warn "Sudo is not allowed"
fi

# Backup naming
today=$(date +"%Y-%m-%d")
BD="${BACKUP_DIR}/$(date +%A)"
BF="betty-mc-${today}.tar"

if [ -f "${BACKUP_DIR}/$(date +%A)/${BF}.xz" ]; then
  log_error "a backup for today already exists. delete it if you are really serious and I will make a new one!"
  exit 1
else
  log_header "Starting backup from ${MC_HOME} to ${BD}"
fi

#if [ -d "/opt/mcserver" ]; then
  # log_info "copy in files from /opt/mcserver"
  # log_warn "You should run the minecraft server from ${MC_HOME}!!"
#  cd /opt/mcserver/ && cp -Rp world/ world_nether/ world_the_end/ /home/betty
#fi

if [ ! -d "${BD}" ]; then 
    log_warn "Creating backup directory: ${BD}"
    mkdir -p "${BD}"
else
    log_success "Backup directory already exists: ${BD}"
fi

log_info "Generating backup file: ${BD}/${BF}"
MYTMPDIR="$(mktemp -d)"
pushd "${MYTMPDIR}" || { log_error "Failed to change to temp dir"; exit 1; }
log_info "Using temporary workdir: ${PWD}"

tar -cf "${MYTMPDIR}/${BF}" "${MC_HOME}/world" "${MC_HOME}/world_nether" "${MC_HOME}/world_the_end"

log_info "Compressing backup..."
xz -z "${MYTMPDIR}/${BF}"

log_info "Saving the compressed file to the backup directory"
mv "${MYTMPDIR}/${BF}.xz" "${BD}"
rm -rf "${MYTMPDIR}"

log_info "Backup completed successfully."
popd

log_info "Cleaing up..."
rm -rf "/tmp/tmp.*"
