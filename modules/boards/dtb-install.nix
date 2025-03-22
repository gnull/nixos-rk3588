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
    mkdir -p /boot/dtb/base
    cp -r ${config.hardware.deviceTree.package}/dtbs/rockchip/* /boot/dtb/base/
    sync
  '';
in {
  boot.loader = {
    systemd-boot.extraInstallCommands = extraInstallCommands;
    grub.extraInstallCommands = extraInstallCommands;
  };
}
