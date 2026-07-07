#!/usr/bin/bash

enable_system_service() {
    local service_name=$1

    require_command systemctl

    log_info "Enabling system service: $service_name"

    sudo systemctl enable "$service_name"

    log_success "System service enabled: $service_name"
}

enable_and_start_system_service() {
    local service_name=$1

    require_command systemctl

    log_info "Enabling and starting system service: $service_name"

    sudo systemctl enable --now "$service_name"

    log_success "System service active: $service_name"
}

enable_user_service() {
    local service_name=$1

    require_command systemctl

    log_info "Enabling user service: $service_name"

    systemctl --user enable "$service_name"

    log_success "User service enabled: $service_name"
}

enable_and_start_user_service() {
    local service_name=$1

    require_command systemctl

    log_info "Enabling and starting user service: $service_name"

    systemctl --user enable --now "$service_name"

    log_success "User service active: $service_name"
}

restart_system_service() {
    local service_name=$1

    require_command systemctl

    log_info "Restarting system service: $service_name"

    sudo systemctl restart "$service_name"

    log_success "System service restarted: $service_name"
}

daemon_reload() {
    require_command systemctl

    log_info "Reloading systemd manager configuration"

    sudo systemctl daemon-reload

    log_success "Systemd manager configuration reloaded"
}

user_daemon_reload() {
    require_command systemctl

    log_info "Reloading user systemd manager configuration"

    systemctl --user daemon-reload

    log_success "User systemd manager configuration reloaded"
}

enable_system_services_from_file() {
    local service_file=$1
    local service_name

    [[ -f "$service_file" ]] ||
        die "System service manifest not found: $service_file"

    while IFS= read -r service_name; do
        [[ -n "$service_name" ]] || continue
        [[ "$service_name" == \#* ]] && continue

        enable_system_service "$service_name"
    done < "$service_file"
}

enable_user_services_from_file() {
    local service_file=$1
    local service_name

    [[ -f "$service_file" ]] ||
        die "User service manifest not found: $service_file"

    while IFS= read -r service_name; do
        [[ -n "$service_name" ]] || continue
        [[ "$service_name" == \#* ]] && continue

        enable_user_service "$service_name"
    done < "$service_file"
}
