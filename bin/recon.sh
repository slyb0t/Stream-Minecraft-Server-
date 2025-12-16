#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2021-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

# ChangeLog:
#
# v 0.1 11/10/25 franklin - initial version

LRED='\033[1;31m'
MC_HOME="/home/betty"
MC_LOG="/var/log/minecraft"

function determine_host() {
  log_header "review host configuration"
  uname -a
  if [ -f "/etc/os-release" ]; then
    cat /etc/os-release
  fi
}

function determine_java() {
  log_header "review java install"
  java --version

  if [ -z "${JAVA_HOME}" ]; then
    log_info "Java Home: ${JAVA_HOME}"
  else
    log_info "Java Home is not set. Please fix."
  fi
  # which java
  log_info "scope out the jvm files"
  find /usr/lib/jvm/ -name "java*"
}

function determine_logging() {
  pass
}

function review_server() {
  log_info "Review server configuration"

  echo "I am in : ${PWD}"
  echo -e "--------------------\n"
  ls -la
  echo -e "--------------------\n"
  cat "${MC_HOME}/server.properties"
  echo -e "--------------------\n"
  cat "${MC_HOME}/user_jvm_args.txt"
  echo -e "--------------------\n"
  cat "${MC_HOME}/ops.json"
  echo -e "--------------------\n"
  ls -la "${MC_HOME}/mods"
}

function main() {
  if [ -f "./common.sh" ]; then
    source "./common.sh"
  else
    echo -e "${LRED}can not find common.sh.${NC}"
    exit 1
  fi
  log_info "successfully sourced common.sh" && echo -e "\n"

  sudo -v &>/dev/null && log_info "sudo is allowed" || log_warn "sudo is not allowed"

  determine_java
}

main "$@"
