#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2025 franklin
#
# SPDX-License-Identifier: MIT

# ChangeLog:
#
# v0.1 | 29 Sept 2023 | franklin <smoooth.y62wj@passmail.net>
# v0.2 | 12/27/2025 | update for common.sh

set -o nounset  # Treat unset variables as an error
#set -euo pipefail

# The special shell variable IFS determines how Bash
# recognizes word boundaries while splitting a sequence of character strings.
#IFS=$'\n\t'

LRED='\033[0;31m'
NC='\033[0m' # No Color
SERVER_DIR="${HOME}"
#JAR="${SERVER_DIR}/archive/velocity-3.4.0-SNAPSHOT-558.jar"
JAR="${HOME}/server.jar"
XMX="3500M"
XMS="3500M"

function main() {
  if [ -f "${SERVER_DIR}/bin/common.sh" ]; then
  source "${SERVER_DIR}/bin/common.sh"
else
  # Simple echo if the logging function source fails
  echo -e "${LRED}Cannot find common.sh. Exiting.${NC}"  >> "${MC_LOG}/backup.log"
  exit 1
fi

  log_info "successfully sourced ${SERVER_DIR}/bin/common.sh" && echo -e "\n"

  log_header "Starting the server."
  log_info "Xmx value: ${XMX}"
  log_info "Xms value: ${XMS}"

  log_info "cd to ${SERVER_DIR}"
  pushd ${SERVER_DIR} >> /dev/null || exit 1
  log_info "start screen session"
  screen -mdS minecraft_console /usr/bin/java -Xmx24G -Xms1G -Dfml.queryResult=confirm -jar "${JAR}" nogui
  popd >> /dev/null || exit 1
  log_info "done!"

}

main "$@"
