# args of buildLinux:
#   https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/kernel/generic.nix
# Note that this method will use the deconfig in source tree,
# commbined the common configuration defined in pkgs/os-specific/linux/kernel/common-config.nix, which is suitable for a NixOS system.
# but it't not suitable for embedded systems, so we comment it out.
# ================================================================
# If you already have a generated configuration file, you can build a kernel that uses it with pkgs.linuxManualConfig
# The difference between deconfig and the generated configuration file is that the generated configuration file is more complete,
#
{ fetchFromGitHub
, linuxManualConfig
, ubootTools
, buildLinux
, fetchurl
, lib
, ...
}@args:
let
  modDirVersion = "6.1.75";
in
(buildLinux ( args // {

  # https://github.com/Joshua-Riek/linux-rockchip/tree/noble
  src = fetchFromGitHub {
    owner = "armbian";
    repo = "linux-rockchip";
    rev = "rk-6.1-rkr5.1";
    hash = "sha256-aKm/RQTRTzLr8+ACdG6QW1LWn+ZOjQtlvU2KkZmYicg=";
  };

  inherit modDirVersion;
  version = "${modDirVersion}-armbian";
  extraMeta.branch = "6.1";

  # https://github.com/hbiyik/linux/tree/rk-6.1-rkr3-panthor
  # allows usage of mainline mesa
  kernelPatches = [{
    name = "hbiyik-panthor.patch";
    # Generate using this command:
    #   curl -o hbiyik-panthor.patch -L https://github.com/hbiyik/linux/compare/aa54fa4e0712616d44f2c2f312ecc35c0827833d...c81ebd8e12b64a42a6efd68cc0ed018b57d14e91.patch
    patch = ./hbiyik-panthor.patch;
    extraConfig = { };
  }];

  extraMeta = {
    platforms = with lib.platforms; aarch64;
    hydraPlatforms = [ "aarch64-linux" ];
  };

  configfile = ./rk35xx_vendor_config;
  ignoreConfigErrors = true;

})).overrideAttrs (old: {
  name = "k"; # dodge uboot length limits
  nativeBuildInputs = old.nativeBuildInputs ++ [ ubootTools ];
})
