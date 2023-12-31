{ pkgs, modulesPath, lib, ... }: {
  imports = [
    # "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    "/etc/nixos/configuration.nix"
  ];

  # Needed for https://github.com/NixOS/nixpkgs/issues/58959
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];
}
