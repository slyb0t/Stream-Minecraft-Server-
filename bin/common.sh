#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2021-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

# ChangeLog:
#
# v 0.1 11/10/25 franklin - initial version
# v 0.2 12/05/25 franklin - used gemini to clean up the script

# --- Safety & Environment ---
# IMPORTANT: Do not use 'set -e' in common.sh if you intend to source it, 
# as an error within common.sh might prematurely kill the calling script.
# The calling script should handle error settings.
# We will use 'set -u' here to catch unbound variables early.
set -u

# --- Global Configuration Variables ---
CONTAINER=false
PRIV_CMD="sudo"
DEB_PKG=(git gnupg figlet) 
PYTHON_CMD=""

# --- Color and Logging Functions ---
# Using tput for compatibility and to check if the terminal supports color.
if tput setaf 1 &>/dev/null; then
  RED=$(tput setaf 1)
  GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3)
  CYAN=$(tput setaf 6)
  LPURP='\033[1;35m'
  BOLD=$(tput bold)
  NC=$(tput sgr0) # No Color
else
  RED=""
  GREEN=""
  YELLOW=""
  CYAN=""
  BOLD=""
  NC=""
fi

log_header() { printf "\n${LPURP}# --- %s ${NC}\n" "$1"; }
log_info() { echo -e "${CYAN}==>${NC} ${BOLD}$1${NC}"; }
log_success() { echo -e "${GREEN}==>${NC} ${BOLD}$1${NC}"; }
log_warn() { echo -e "${YELLOW}WARN:${NC} $1"; }
log_error() { >&2 echo -e "${RED}ERROR:${NC} $1"; } # Errors to stderr

# --- Utility Functions ---

function check_if_root {
    if [[ $(id -u) -eq 0 ]]; then
        log_warn "You are the root user."
    else
        log_success "You are NOT the root user."
    fi
}

function check_container() {
    if [ -f /.dockerenv ] || grep -q 'docker\|lxc' /proc/1/cgroup 2>/dev/null; then
        log_warn "Containerized build environment detected."
        CONTAINER=true
        # Determine privilege command
        if command -v sudo &>/dev/null; then
            PRIV_CMD="sudo"
        else
            PRIV_CMD="" 
        fi
    else
        log_info "NOT a containerized build environment."
    fi
}

function check_installed() {
    if command -v "$1" &>/dev/null; then
        log_success "Found command: ${1}"
        return 0
    else
        return 1
    fi
}

# --- Installation & Setup Functions ---

function install_debian() {
    log_header "Installing Debian Packages"
    
    if [ "${CONTAINER}" = true ]; then
        log_info "Running initial container package update/upgrade."
        ${PRIV_CMD} apt-get update
        ${PRIV_CMD} apt-get upgrade -y
    fi

    local install_list=()
    for pkg in "${DEB_PKG[@]}"; do
        if ! dpkg-query -W -f='${Status}' "${pkg}" 2>/dev/null | grep -q "ok installed"; then
            log_warn "Adding ${pkg} to install list."
            install_list+=("${pkg}")
        else
            log_info "Found package: ${pkg}"
        fi
    done

    if [ ${#install_list[@]} -gt 0 ]; then
        log_info "Installing remaining packages: ${install_list[*]}"
        ${PRIV_CMD} apt-get update
        ${PRIV_CMD} apt-get install --yes "${install_list[@]}"
        ${PRIV_CMD} apt-get autoremove -y
    fi

    if check_installed dircolors && [ ! -f "${HOME}/.dircolors" ]; then
        dircolors -p >"${HOME}/.dircolors"
        log_warn "Generated default ~/.dircolors configuration."
    fi
}

function setup_figlet() {
    log_header "Figlet Font Setup"
    if check_installed git; then
        local FONT_DIR="/usr/share/figlet"
        local TEMP_DIR
        TEMP_DIR=$(mktemp -d)

        if [ -d "${FONT_DIR}" ] && [ ! -d "${FONT_DIR}/figlet-fonts" ]; then
            log_info "Cloning figlet fonts to temporary directory."
            if git clone https://github.com/xero/figlet-fonts.git "${TEMP_DIR}/figlet-fonts"; then
                log_info "Moving fonts to ${FONT_DIR}/fonts"
                ${PRIV_CMD} cp -r "${TEMP_DIR}/figlet-fonts/fonts/." "${FONT_DIR}/fonts/"
                log_success "Figlet fonts installed successfully."
            else
                log_error "Failed to clone figlet fonts repository."
            fi
        else
            log_warn "Figlet font directory already exists or git not found. Skipping font installation."
        fi
        rm -rf "${TEMP_DIR}"
    else
        log_warn "Git is not installed. Skipping figlet font setup."
    fi
}

function setup_1password() {
    log_header "Installing 1Password CLI/App"
    if ! check_installed 1password; then
        log_warn "Installing 1password for Linux"
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | ${PRIV_CMD} gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
        echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | ${PRIV_CMD} tee /etc/apt/sources.list.d/1password.list
        ${PRIV_CMD} mkdir -p /etc/debsig/policies/AC2D62742012EA22/
        curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | ${PRIV_CMD} tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
        ${PRIV_CMD} mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | ${PRIV_CMD} gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
        
        ${PRIV_CMD} apt update && ${PRIV_CMD} apt -y install 1password
        log_success "1password installed successfully."
    else
        log_success "Found 1password already installed."
    fi
}

function setup_golang() {
    log_header "Setting up Go Tools"
    if ! check_installed go; then
        log_warn "Go command not found. Skipping Go tool setup."
        return
    fi

    local GOPATH_BIN="${HOME}/go/bin"
    mkdir -p "${GOPATH_BIN}"
    local go_tools=(
        "github.com/kisielk/errcheck@latest"
        "github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
    )

    for tool in "${go_tools[@]}"; do
        local tool_name
        tool_name=$(basename "$tool" | cut -d'@' -f1) 
        if [ ! -f "${GOPATH_BIN}/${tool_name}" ]; then
            log_info "Installing Go tool: ${tool_name}"
            if go install "$tool"; then
                log_success "${tool_name} installed."
            else
                log_error "Failed to install Go tool: ${tool_name}."
            fi
        else
            log_success "Found Go tool: ${tool_name}."
        fi
    done
}

function check_python_version() {
    log_header "Checking Python Version"
    
    if command -v python3 &>/dev/null; then
        PYTHON_CMD="python3"
    elif command -v python &>/dev/null; then
        local PYTHON_MAJOR_VERSION
        PYTHON_MAJOR_VERSION=$(python -c 'import sys; print(sys.version_info.major)')
        
        if [[ "$PYTHON_MAJOR_VERSION" -eq 3 ]]; then
            PYTHON_CMD="python"
        else
            log_warn "The 'python' command points to Python 2 (v${PYTHON_MAJOR_VERSION})."
            log_error "Python 3 is required. Please install python3 package."
            exit 1
        fi
    else
        log_error "Neither 'python' nor 'python3' found. Please install Python 3."
        exit 1
    fi

    log_success "Using Python command: ${PYTHON_CMD}"
}