# Mainline U-Boot for Orange Pi 5 Pro (RK3588S).
#
# The defconfig is not yet upstream — Armbian carries a patch that adds
# orangepi-5-pro-rk3588s_defconfig and the board DTS.  We fetch the
# patch directly from Armbian's build repo.
#
# Produces u-boot-rockchip.bin (combined TPL+SPL+ATF+U-Boot, single dd)
# and u-boot-rockchip-spi.bin (for SPI NOR flash, if ever needed).
{
  buildUBoot,
  armTrustedFirmwareRK3588,
  rkbin,
  fetchurl,
  ...
}:
buildUBoot {
  defconfig = "orangepi-5-pro-rk3588s_defconfig";
  extraMeta.platforms = ["aarch64-linux"];
  BL31 = "${armTrustedFirmwareRK3588}/bl31.elf";
  ROCKCHIP_TPL = rkbin.TPL_RK3588;
  extraPatches = [
    (fetchurl {
      name = "add-orangepi5-pro-support.patch";
      url = "https://raw.githubusercontent.com/armbian/build/main/patch/u-boot/v2025.07/board_orangepi5pro/0001-add-orangepi5-pro-support.patch";
      hash = "sha256-cU7V/IloWE/WAl4+V5TRc7rwGriU3XHzW8NDQcRj7SI=";
    })
  ];
  filesToInstall = [
    "u-boot-rockchip.bin"
    "u-boot-rockchip-spi.bin"
  ];
}
