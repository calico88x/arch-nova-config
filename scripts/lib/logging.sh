#!/usr/bin/bash

set -o errexit
set -o nounset
set -o pipefail

readonly RESET=$'\033[0m'
readonly BOLD=$'\033[1m'
readonly RED=$'\033[31m'
readonly GREEN=$'\033[32m'
readonly YELLOW=$'\033[33m'
readonly BLUE=$'\033[34m'

log_info() {
    printf '%s[INFO]%s %s\n' "${BLUE}${BOLD}" "${RESET}" "$*"
}

log_success() {
    printf '%s[OK]%s %s\n' "${GREEN}${BOLD}" "${RESET}" "$*"
}

log_warn() {
    printf '%s[WARN]%s %s\n' "${YELLOW}${BOLD}" "${RESET}" "$*" >&2
}

log_error() {
    printf '%s[ERROR]%s %s\n' "${RED}${BOLD}" "${RESET}" "$*" >&2
}

die() {
    log_error "$*"
    exit 1
}

require_command() {
    local command_name=$1

    command -v "$command_name" >/dev/null 2>&1 ||
        die "Required command not found: $command_name"
}
