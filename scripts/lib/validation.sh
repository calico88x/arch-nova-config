#!/usr/bin/bash

assert_running_as_user() {
    if [[ $EUID -eq 0 ]]; then
        die "Run the deployment as your normal user, not as root"
    fi
}

assert_arch_linux() {
    [[ -f /etc/arch-release ]] ||
        die "This deployment targets Arch Linux"
}

assert_repository_root() {
    local repository_root=$1

    [[ -d "$repository_root/.git" ]] ||
        die "Repository metadata not found: $repository_root/.git"

    [[ -f "$repository_root/packages/official.txt" ]] ||
        die "Official package manifest is missing"
}

assert_sudo_access() {
    require_command sudo

    log_info "Checking sudo access"

    sudo -v ||
        die "Unable to obtain sudo access"

    log_success "Sudo access is available"
}

validate_required_commands() {
    local commands=(
        awk
        grep
        install
        ln
        pacman
        rsync
        sed
        systemctl
    )

    local command_name

    for command_name in "${commands[@]}"; do
        require_command "$command_name"
    done

    log_success "Required deployment commands are available"
}

validate_package_manifest() {
    local package_file=$1
    local duplicate_count

    [[ -f "$package_file" ]] ||
        die "Package manifest not found: $package_file"

    duplicate_count=$(
        sort "$package_file" |
            uniq -d |
            wc -l
    )

    if (( duplicate_count > 0 )); then
        log_error "Duplicate package entries found in $package_file"
        sort "$package_file" | uniq -d
        return 1
    fi

    log_success "Package manifest contains no duplicates: $package_file"
}
