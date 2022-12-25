# Partition
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- mkpart primary ext4 512MiB 100%
parted /dev/sda -- set 1 esp on
mkfs.fat -F 32 -n NIXBOOT /dev/sda1
mkfs.ext4 -L nixos /dev/sda2

# Mount
mount /dev/disk/by-label/nixos /mnt
mount --mkdir /dev/disk/by-label/NIXBOOT /mnt/boot

# Copy config files
mkdir -p /mnt/etc/nixos
cp configuration.nix /mnt/etc/nixos/
cp hardware-configuration.nix /mnt/etc/nixos/

# Install
nixos-install
