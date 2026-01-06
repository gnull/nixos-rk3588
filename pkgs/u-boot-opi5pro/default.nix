{pkgs, ...}:
  let
  in pkgs.buildUBoot {
    src = pkgs.fetchFromGitHub {
      owner = "orangepi-xunlong";
      repo = "u-boot-orangepi";
      # rev = "v2017.09-rk3588";
      rev = "b04eacaa0df75552d38c68b6ba9f82f603d74177";
      sha256 = "sha256-Z/bS5Na8QJ/5y7uG03ViZSCY5PnIZeXxDMGEihheLg8=";
    };
    version = "2017.09-rk3588";
    defconfig = "orangepi_5_pro_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];
    filesToInstall = [ "u-boot.bin" ];
  }

  ## See
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/misc/uboot/default.nix
  # https://github.com/armbian/build/blob/545b6e28bb7e00336ab108ffc362f0124e86701c/config/boards/orangepi5pro.csc
