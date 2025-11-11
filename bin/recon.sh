#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2021-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

# ChangeLog:
#
# v 0.1 11/10/25 franklin - initial version

function determine_host(){
    pass
}

function determine_java() {
    pass
}


function main() {
  if [ -f "./bin/common.sh" ]; then
    source "./bin/common.sh"
  else
    echo -e "${LRED}can not find common.sh.${NC}"
    exit 1
  fi
  log_info "successfully sourced common.sh" && echo -e "\n"
}

main "$@"