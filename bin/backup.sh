#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2025 franklin  <smoooth.y62wj@passmail.net>
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
BACKUP_DIR="/${MC_HOME}/backups"

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

log_header "Starting backup from ${MC_HOME} to ${BD}"

# Create backup directory if it doesn't exist
if [ ! -d "${BD}" ]; then 
    log_info "Creating backup directory: ${BD}"
    mkdir -p "${BD}"
else
    log_info "Backup directory already exists: ${BD}"
fi

# Generate backup file
log_info "Generating backup file: ${BD}/${BF}"
MYTMPDIR="$(mktemp -d)"
pushd "${MYTMPDIR}" || { log_error "Failed to change to temp dir"; exit 1; }
log_info "Using temporary workdir: ${PWD}"

cp -r "${MC_HOME}/world" "${MC_HOME}/world_nether" "${MC_HOME}/world_the_end" "${MYTMPDIR}/"
tar -cf "${MYTMPDIR}/${BF}" -C "${MYTMPDIR}" /tmp # Create the tar archive in the temporary directory

log_info "Compressing backup..."
xz -z "/tmp/${BF}"

log_info "Saving the compressed file to the backup directory"
mv "/tmp/${BF}.xz" "${BD}"

log_info "Backup completed successfully."
popd

log_info "Cleaing up..."
rm -rf "/tmp/tmp.*"

# can i message the console
# screen -S minecraft -p 0 -X stuff "`printf "say This is a test.\r"`";
