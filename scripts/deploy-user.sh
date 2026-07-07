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

    log_info "Deploying user configuration"

    deploy_file \
        "$REPOSITORY_ROOT/dotfiles/bash/.bashrc" \
        "$HOME/.bashrc"

    deploy_file \
        "$REPOSITORY_ROOT/dotfiles/bash/.bash_profile" \
        "$HOME/.bash_profile"

    deploy_file \
        "$REPOSITORY_ROOT/dotfiles/bash/.bash_logout" \
        "$HOME/.bash_logout"

    deploy_file \
        "$REPOSITORY_ROOT/dotfiles/starship.toml" \
        "$HOME/.config/starship.toml"

    sync_directory \
        "$REPOSITORY_ROOT/dotfiles/btop" \
        "$HOME/.config/btop"

    sync_directory \
        "$REPOSITORY_ROOT/dotfiles/htop" \
        "$HOME/.config/htop"

    sync_directory \
        "$REPOSITORY_ROOT/dotfiles/hypr" \
        "$HOME/.config/hypr"

    sync_directory \
        "$REPOSITORY_ROOT/dotfiles/kitty" \
        "$HOME/.config/kitty"

    sync_directory \
        "$REPOSITORY_ROOT/dotfiles/qutebrowser" \
        "$HOME/.config/qutebrowser"

    sync_directory \
        "$REPOSITORY_ROOT/dotfiles/superfile" \
        "$HOME/.config/superfile"

    sync_directory \
        "$REPOSITORY_ROOT/dotfiles/waybar" \
        "$HOME/.config/waybar"

    enable_user_services_from_file \
        "$REPOSITORY_ROOT/system/services-user.txt"

    log_success "User configuration deployment completed"
}

main "$@"
