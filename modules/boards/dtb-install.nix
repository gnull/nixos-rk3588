{
  config,
  lib,
  options,
  pkgs,
  modulesPath,
  nixos-generators,
  ...
}: let
  extraInstallCommands = ''
    ${pkgs.coreutils}/bin/mkdir -p /boot/dtb/base
    ${pkgs.coreutils}/bin/cp -r ${config.hardware.deviceTree.package}/rockchip/* /boot/dtb/base/
    ${pkgs.coreutils}/bin/sync
  '';
in {
  boot.loader = {
    systemd-boot.extraInstallCommands = extraInstallCommands;
    grub.extraInstallCommands = extraInstallCommands;
  };
}
