#!/usr/bin/bash

set -o errexit
set -o nounset
set -o pipefail

readonly REPOSITORY_ROOT=$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &&
        pwd
)

source "$REPOSITORY_ROOT/scripts/lib/logging.sh"
source "$REPOSITORY_ROOT/scripts/lib/packages.sh"
source "$REPOSITORY_ROOT/scripts/lib/validation.sh"

main() {
    log_info "Starting Arch Nova deployment"

    assert_running_as_user
    assert_arch_linux
    assert_repository_root "$REPOSITORY_ROOT"
    assert_sudo_access

    validate_required_commands

    validate_package_manifest \
        "$REPOSITORY_ROOT/packages/official.txt"

    validate_package_manifest \
        "$REPOSITORY_ROOT/packages/aur.txt"

    install_official_packages \
        "$REPOSITORY_ROOT/packages/official.txt"

    report_foreign_packages \
        "$REPOSITORY_ROOT/packages/aur.txt"

    SKIP_SUDO_CHECK=1 \
        "$REPOSITORY_ROOT/scripts/deploy-system.sh"

    "$REPOSITORY_ROOT/scripts/deploy-user.sh"

    log_success "Arch Nova deployment completed"
}

main "$@"
