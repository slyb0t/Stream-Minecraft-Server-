#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2025 franklin
#
# SPDX-License-Identifier: MIT

# ChangeLog:
# v 0.1 11/30/25 franklin - initial version
# v 0.2 12/05/25 franklin - Optimized and improved error handling

# --- Configuration ---
# Use set -e to exit immediately if a command exits with a non-zero status.
# Use set -u to treat unset variables as an error.
# Use set -o pipefail to return the exit status of the last command in a pipe that failed.
set -euo pipefail

# Define core paths and user
MC_USER="betty"
MC_HOME="/home/${MC_USER}"
MC_LOG="/var/log/minecraft" # Log directory for the server
BACKUP_DIR="${MC_HOME}/backups"
MC_WORLD_DIR="${MC_HOME}" # The directory containing 'world', 'world_nether', 'world_the_end'

# Files/Directories to include in the backup
BACKUP_TARGETS=(
  "${MC_WORLD_DIR}/world"
  "${MC_WORLD_DIR}/world_nether"
  "${MC_WORLD_DIR}/world_the_end"
  "${MC_WORLD_DIR}/*.yml"
  "${MC_WORLD_DIR}/*.json"
)

LRED='\033[1;31m'
NC='\033[0m' # No Color
ME_SU=false
DEB_PKG=(tar xz)

check_dependencies() {
  log_header "Check Dependencies"
  for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
      log_error "Required command '$cmd' is not installed or not in PATH."
      exit 1
    fi
  done
  log_info "All required commands are available."
}

function main() {
if [ -f "${MC_HOME}/bin/common.sh" ]; then
  source "${MC_HOME}/bin/common.sh"
else
  # Simple echo if the logging function source fails
  echo -e "${LRED}Cannot find common.sh. Exiting.${NC}"
  exit 1
fi
log_info "Successfully sourced common.sh"

check_dependencies

# Check for sudo capabilities (retained logic)
if sudo -v &>/dev/null; then
  log_info "Sudo is allowed"
  ME_SU=true
else
  log_warn "Sudo is not allowed"
fi

# Define the destination directory (daily rotation) and filename
TODAY=$(date +"%Y-%m-%d")
DEST_DIR="${BACKUP_DIR}/$(date +%A)"
BACKUP_FILENAME="${MC_USER}-mc-${TODAY}.tar.xz"
DEST_PATH="${DEST_DIR}/${BACKUP_FILENAME}"

log_header "Starting backup for '${MC_USER}' worlds to ${DEST_DIR}"

# Create backup directory if it doesn't exist
if [ ! -d "${DEST_DIR}" ]; then
  log_info "Creating backup directory: ${DEST_DIR}"
  # Use -p to avoid error if parent directories don't exist
  mkdir -p "${DEST_DIR}"
else
  log_info "Backup directory already exists: ${DEST_DIR}"
fi

# Generate and compress the backup file directly
log_info "Creating compressed backup file: ${DEST_PATH}"

# tar -Jcf:
# -J: Use xz compression (equivalent to --xz)
# -c: Create an archive
# -f: Specify the archive filename
# The following command creates the compressed archive directly,
# avoiding intermediate files and reducing I/O operations.
if tar -Jcf "${DEST_PATH}" "${BACKUP_TARGETS[@]}"; then
  log_info "Backup completed successfully: ${DEST_PATH}"
else
  log_error "tar failed to create the backup archive."
  exit 1
fi

log_info "Cleanup: Backup does not require temporary files with tar -Jcf."

log_header "Backup script finished."

# Optional: You might consider adding a cleanup step here to remove archives older than X days/weeks
# in the destination directory to prevent the backup directory from filling up completely.
#
}

main "$@"
