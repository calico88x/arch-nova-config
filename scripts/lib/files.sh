#!/usr/bin/bash

ensure_directory() {
    local path=$1
    local mode=${2:-0755}

    install -d -m "$mode" "$path"
}

deploy_file() {
    local source=$1
    local destination=$2
    local mode=${3:-0644}

    [[ -f "$source" ]] ||
        die "Source file not found: $source"

    log_info "Deploying $destination"

    install -Dm "$mode" "$source" "$destination"
}

deploy_system_file() {
    local source=$1
    local destination=$2
    local mode=${3:-0644}

    [[ -f "$source" ]] ||
        die "System source file not found: $source"

    log_info "Deploying $destination"

    sudo install -Dm "$mode" "$source" "$destination"
}

sync_directory() {
    local source=$1
    local destination=$2

    [[ -d "$source" ]] ||
        die "Source directory not found: $source"

    require_command rsync

    ensure_directory "$destination"

    log_info "Synchronizing $source to $destination"

    rsync \
        --archive \
        --exclude '.gitkeep' \
        "$source"/ \
        "$destination"/
}

sync_system_directory() {
    local source=$1
    local destination=$2

    [[ -d "$source" ]] ||
        die "System source directory not found: $source"

    require_command rsync

    sudo install -d -m 0755 "$destination"

    log_info "Synchronizing $source to $destination"

    sudo rsync \
        --archive \
        --delete \
        --exclude '.gitkeep' \
        "$source"/ \
        "$destination"/
}

ensure_symlink() {
    local target=$1
    local link_path=$2

    log_info "Creating symlink $link_path -> $target"

    sudo ln -sfn "$target" "$link_path"
}
