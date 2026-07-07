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
source "$SCRIPT_DIR/lib/files.sh"
source "$SCRIPT_DIR/lib/services.sh"
source "$SCRIPT_DIR/lib/validation.sh"

main() {
    assert_running_as_user
    assert_arch_linux
    assert_repository_root "$REPOSITORY_ROOT"

    if [[ ${SKIP_SUDO_CHECK:-0} != 1 ]]; then
        assert_sudo_access
    fi

    log_info "Deploying system configuration"

    deploy_system_file \
        "$REPOSITORY_ROOT/system/etc/locale.conf" \
        "/etc/locale.conf"

    deploy_system_file \
        "$REPOSITORY_ROOT/system/etc/vconsole.conf" \
        "/etc/vconsole.conf"

    deploy_system_file \
        "$REPOSITORY_ROOT/system/etc/mkinitcpio.conf" \
        "/etc/mkinitcpio.conf"

    deploy_system_file \
        "$REPOSITORY_ROOT/system/etc/mkinitcpio.d/linux.preset" \
        "/etc/mkinitcpio.d/linux.preset"

    deploy_system_file \
        "$REPOSITORY_ROOT/system/etc/systemd/network/25-wireless.network" \
        "/etc/systemd/network/25-wireless.network"

    deploy_system_file \
        "$REPOSITORY_ROOT/system/boot/loader/loader.conf" \
        "/boot/loader/loader.conf"

    deploy_system_file \
        "$REPOSITORY_ROOT/system/boot/loader/entries/arch.conf" \
        "/boot/loader/entries/arch.conf"

    ensure_symlink \
        "../run/systemd/resolve/stub-resolv.conf" \
        "/etc/resolv.conf"

    enable_system_services_from_file \
        "$REPOSITORY_ROOT/system/services-system.txt"

    log_success "System configuration deployment completed"
    log_warn "Initramfs was not regenerated"
    log_warn "Networking services were not restarted"
}

main "$@"
