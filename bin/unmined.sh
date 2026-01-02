#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2014-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

# v0.1 7/29/2022
# v0.2 10/14/2025 - Changed output path logic for better reliability.

LRED='\033[1;31m'
UNMINED="/opt/unmined-cli/unmined-cli" # Path to the unmined-cli executable

# The directory containing the server's world folder (e.g., /home/minecraft/server_minecraft)
# We use the 'dirname' of the world path for the output path to keep all files together.
SERVER_ROOT_DIR="/home/minecraft/server_minecraft"
WORLD_PATH="${SERVER_ROOT_DIR}/world" # Path to the world data folder

OUTPUT_PATH="/home/franklin/workspace/website/static/chonk/minecraft/map"
LOG_DIR="/var/log/minecraft"
LOG_FILE="${LOG_DIR}/unmined.log"

if [ -f "./common.sh" ]; then
  source "./common.sh"
else
  echo -e "${LRED}can not find common.sh.${NC}"
  exit 1
fi
log_info "successfully sourced common.sh" && echo -e "\n"

  setup_figlet
  echo -e "\n" && figlet -f  /usr/share/figlet/fonts/pagga workspace && echo -e "\n"


if [ ! -d "${LOG_DIR}" ]; then
  log_info "Creating log directory: ${LOG_DIR}"
  mkdir -p "$(dirname "${LOG_DIR}")" 
else
  log_info "Found log directory: ${LOG_DIR}"
fi

log_header "Starting world map rendering..."

if [[ ! -x "${UNMINED}" ]]; then
    log_error "ERROR: unmined-cli not found or is not executable at ${UNMINED}"
fi

if [[ ! -d "${WORLD_PATH}" ]]; then
    log_error "ERROR: World path not found at ${WORLD_PATH}"
fi

log_header "rendering the web map..."
"${UNMINED}" web render \
    --world="${WORLD_PATH}" \
    --output="${OUTPUT_PATH}" \
    --force | tee "${LOG_FILE}"

log_info "Map rendering finished."

# Optional: You can add commands here to restart your web server or copy the map files
# if your web server doesn't point directly to the OUTPUT_PATH.

