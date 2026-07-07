#!/usr/bin/bash

set -o errexit
set -o nounset
set -o pipefail

readonly SCRIPT_DIR=$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &&
        pwd
)

readonly REPOSITORY_ROOT=$(
    cd -- "$SCRIPT_DIR/.." &&
        pwd
)

source "$SCRIPT_DIR/lib/logging.sh"
source "$SCRIPT_DIR/lib/validation.sh"

main() {
    log_info "Validating Arch Nova deployment repository"

    assert_running_as_user
    assert_arch_linux
    assert_repository_root "$REPOSITORY_ROOT"

    validate_required_commands

    validate_package_manifest \
        "$REPOSITORY_ROOT/packages/official.txt"

    validate_package_manifest \
        "$REPOSITORY_ROOT/packages/aur.txt"

    log_success "Deployment repository validation passed"
}

main "$@"
