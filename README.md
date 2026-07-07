# Arch Nova Config

A close-to-metal, Bash-based configuration and post-install deployment repository for my Arch Linux workstation.

This repository serves two purposes:

1. **Deployment** — reproduce the installed packages, system configuration, services, dotfiles, and Hyprland desktop environment.
2. **Inventory** — retain a sanitized reference snapshot of the machine’s hardware, storage, networking, boot, and service state.

The deployment framework uses standard Arch and Linux tooling rather than a configuration-management abstraction:

* Bash
* `pacman`
* `systemctl`
* `install`
* `rsync`
* `ln`

## Current scope

The automated deployment currently manages:

* official Arch packages
* selected `/etc` configuration files
* systemd-boot configuration
* systemd-networkd configuration
* the `systemd-resolved` resolver symlink
* curated system services
* curated user services
* shell configuration
* Hyprland, Hypridle, Hyprlock, and Hyprpaper
* Kitty
* Waybar
* btop and htop
* qutebrowser bookmarks and quickmarks
* Superfile
* Starship
* wallpaper, lockscreen, and profile-picture assets

This is currently a **post-install deployment**, not a complete Arch installer.

It does not partition disks, create LUKS or LVM volumes, format filesystems, install the base system from an Arch ISO, create users, or provision credentials.

## Target system

| Component    | Configuration                                 |
| ------------ | --------------------------------------------- |
| Distribution | Arch Linux                                    |
| Hostname     | `arch-nova`                                   |
| Desktop      | Hyprland                                      |
| Bootloader   | systemd-boot                                  |
| Network      | iwd + systemd-networkd + systemd-resolved     |
| Audio        | PipeWire + WirePlumber + SOF firmware + RTKit |
| Storage      | LUKS2 + LVM + ext4                            |
| Shell        | Bash                                          |
| Firewall     | UFW                                           |

The repository is tailored to this machine. Review all system and boot configuration before applying it to different hardware.

## Repository layout

```text
.
├── deploy.sh
├── packages/
│   ├── official.txt
│   └── aur.txt
├── scripts/
│   ├── deploy-system.sh
│   ├── deploy-user.sh
│   ├── validate.sh
│   └── lib/
│       ├── files.sh
│       ├── logging.sh
│       ├── packages.sh
│       ├── services.sh
│       └── validation.sh
├── system/
│   ├── boot/
│   ├── etc/
│   ├── services-system.txt
│   └── services-user.txt
├── dotfiles/
│   ├── bash/
│   ├── btop/
│   ├── htop/
│   ├── hypr/
│   ├── kitty/
│   ├── qutebrowser/
│   ├── superfile/
│   ├── waybar/
│   └── starship.toml
└── inventory and reference files
```

### Deployable state

The authoritative deployment inputs are:

* `packages/official.txt`
* `packages/aur.txt`
* `system/`
* `dotfiles/`
* `scripts/`
* `deploy.sh`

### Reference inventory

Top-level files such as the following document the source system but are not automatically deployed:

* `audio.txt`
* `displays.txt`
* `input-devices.txt`
* `ip-addr.txt`
* `lsblk.txt`
* `lspci-drivers.txt`
* `lvm-layout.txt`
* `network-services.txt`
* `pacman-list.txt`
* `time-settings.txt`
* `usb-devices.txt`

These files are useful for diagnostics, recovery, comparison, and future installer development.

## Requirements

The deployment expects:

* an existing Arch Linux installation
* a normal non-root user
* working `sudo` access
* network access for package installation
* Bash at `/usr/bin/bash`
* the repository cloned locally

The required runtime commands are validated before deployment.

## Validate the repository

Run the non-destructive validation script first:

```bash
./scripts/validate.sh
```

Validation currently checks:

* the script is not running directly as root
* the host is Arch Linux
* repository metadata and package manifests exist
* required commands are available
* package manifests contain no duplicate entries

## Deploy

Run the complete post-install deployment as the normal user:

```bash
./deploy.sh
```

The script will request sudo access and then:

1. validate the environment
2. validate package manifests
3. install missing official packages with `pacman --needed`
4. report any foreign or AUR packages
5. deploy managed system configuration
6. recreate the resolver symlink
7. enable curated system services
8. deploy user dotfiles
9. enable curated user services

The deployment is designed to be repeatable. Running it again should converge on the same managed state.

## Individual deployment phases

Deploy only system configuration:

```bash
./scripts/deploy-system.sh
```

Deploy only user configuration:

```bash
./scripts/deploy-user.sh
```

Validate without deploying:

```bash
./scripts/validate.sh
```

## Managed system files

The system phase currently deploys:

```text
/etc/locale.conf
/etc/vconsole.conf
/etc/mkinitcpio.conf
/etc/mkinitcpio.d/linux.preset
/etc/systemd/network/25-wireless.network
/boot/loader/loader.conf
/boot/loader/entries/arch.conf
```

It also enforces:

```text
/etc/resolv.conf -> ../run/systemd/resolve/stub-resolv.conf
```

### Important system-deployment behavior

The current system deployment:

* overwrites the managed destination files
* enables services without immediately starting or restarting them
* does not regenerate the initramfs
* does not restart networking
* does not reboot the machine

Changes to `mkinitcpio.conf`, kernel presets, boot entries, storage identifiers, or network configuration should be reviewed carefully before deployment.

## Managed services

System services are declared in:

```text
system/services-system.txt
```

Current managed system units:

```text
docker.service
iwd.service
sshd.service
systemd-networkd.service
systemd-resolved.service
ufw.service
```

User services are declared in:

```text
system/services-user.txt
```

Current managed user units:

```text
p11-kit-server.socket
pipewire.socket
wireplumber.service
```

The manifests intentionally contain curated high-level units rather than every dependency, socket, target, or generated unit reported by systemd.

## Package manifests

Official repository packages are declared in:

```text
packages/official.txt
```

Regenerate the list from the current system with:

```bash
pacman -Qqen | sort > packages/official.txt
```

Foreign or AUR packages are declared in:

```text
packages/aur.txt
```

Regenerate that list with:

```bash
pacman -Qqem | sort > packages/aur.txt
```

The deployment currently reports foreign packages but does not install them automatically.

## Dotfile behavior

User configuration is copied into the corresponding locations under `$HOME` and `$HOME/.config`.

Directory synchronization is intentionally non-destructive:

* managed files are added or updated
* unrelated application state is preserved
* runtime-created files are not deleted
* `.gitkeep` placeholders are excluded

Hyprland image assets are deployed under:

```text
~/.config/hypr/assets/
```

## Updating the repository

After changing live configuration, update the corresponding file under `dotfiles/` or `system/`.

Do not treat the top-level inventory copies as deployment sources. The deployment framework reads from the dedicated `dotfiles/`, `system/`, and `packages/` directories.

Validate after changes:

```bash
./scripts/validate.sh
```

Then review and commit:

```bash
git diff
git status
git add .
git commit -m "Describe the configuration change"
git push
```

## Sensitive material

The repository intentionally excludes:

* SSH private keys
* Wi-Fi PSKs
* LUKS passphrases
* user passwords
* sudo passwords
* GitHub tokens
* browser cookies and history
* shell command histories
* transient application sessions

The public SSH key is included, but the corresponding private key is not.

Secrets must be provisioned separately or through a future encrypted secrets workflow.

## Safety notes

This repository contains machine-specific boot, storage, networking, firewall, and desktop configuration.

Before using it on another machine, review at minimum:

```text
system/boot/loader/entries/arch.conf
system/etc/mkinitcpio.conf
system/etc/mkinitcpio.d/linux.preset
system/etc/systemd/network/25-wireless.network
system/services-system.txt
packages/official.txt
```

Do not assume UUIDs, LUKS mapper names, LVM volume names, network interfaces, display settings, or hardware drivers are portable.

## Planned work

Future milestones may include:

* post-deployment verification
* change-aware file deployment
* automatic initramfs regeneration when required
* structured backup and rollback behavior
* encrypted secret provisioning
* fresh-install bootstrap support
* LUKS and LVM installation automation
* disposable VM deployment tests

Disk installation and partitioning automation will remain separate from the current post-install deployment layer because those operations are destructive and hardware-specific.

## Design principles

* use native Arch and Linux tooling
* keep every operation visible
* avoid unnecessary abstraction
* remain safe to run repeatedly
* separate deployable state from diagnostic inventory
* keep credentials outside the repository
* prefer explicit, reviewable configuration

