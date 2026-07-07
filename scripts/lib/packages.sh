#!/usr/bin/bash

install_official_packages() {
    local package_file=$1

    [[ -f "$package_file" ]] ||
        die "Package manifest not found: $package_file"

    require_command pacman

    if [[ ! -s "$package_file" ]]; then
        log_warn "Official package manifest is empty: $package_file"
        return 0
    fi

    log_info "Installing official Arch packages"

    sudo pacman \
        --sync \
        --needed \
        --noconfirm \
        - < "$package_file"

    log_success "Official packages are installed"
}

report_foreign_packages() {
    local package_file=$1

    [[ -f "$package_file" ]] ||
        die "Foreign package manifest not found: $package_file"

    if [[ ! -s "$package_file" ]]; then
        log_info "No foreign or AUR packages are defined"
        return 0
    fi

    log_warn "Foreign packages require a separate installation method"

    while IFS= read -r package_name; do
        [[ -n "$package_name" ]] &&
            printf '  - %s\n' "$package_name"
    done < "$package_file"
}
