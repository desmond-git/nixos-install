# Partition
DISK=/dev/disk/by-id/nvme-eui.00000000000000000026b7686581b745
wipefs -a -f $DISK
parted -s $DISK -- mklabel gpt
parted $DISK -- mkpart ESP fat32 1MiB 512MiB
parted $DISK -- set 1 boot on
parted $DISK -- mkpart nixos xfs 512MiB 100%
mkfs.fat -F 32 -n EFI_BOOT $DISK-part1
mkfs.xfs -f -L nixos $DISK-part2
mount $DISK-part2 /mnt
mount --mkdir $DISK-part1 /mnt/boot

# Copy config files
mkdir -p /mnt/etc/nixos
cp configuration.nix /mnt/etc/nixos/
cp hardware-configuration.nix /mnt/etc/nixos/

# Install
nixos-install
