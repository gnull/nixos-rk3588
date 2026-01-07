{nixpkgs, gnull, lib, config, pkgs, ...}:
let
  rootPartitionUUID = "14e19a7b-0ae0-484d-9d54-43bd6fdc20c7";
  # TODO: change this if you are using a different board:
  uboot = pkgs.ubootOrangePi5Plus;
in {
  imports = [
    "${gnull}/nixos/modules/installer/sd-card/sd-image.nix"
  ];

  boot = {
    kernelParams = [
      "root=UUID=${rootPartitionUUID}"
      "rootfstype=ext4"
    ];
    consoleLogLevel = 7;

    loader = {
      grub.enable = lib.mkForce false;
      generic-extlinux-compatible.enable = lib.mkForce true;
    };
  };

  sdImage = {
    inherit rootPartitionUUID;
    compressImage = true;

    # install firmware into a separate partition: /boot/firmware
    populateFirmwareCommands = ''
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./firmware
    '';
    # Gap in front of the /boot/firmware partition, in mebibytes (1024×1024 bytes).
    # Can be increased to make more space for boards requiring to dd u-boot SPL before actual partitions.
    firmwarePartitionOffset = 32;
    firmwarePartitionName = "BOOT";
    firmwareSize = 200; # MiB

    populateRootCommands = ''
      mkdir -p ./files/boot
      mkdir -p ./files/boot/firmware
    '';

    postBuildCommands = ''
      dd if=${uboot}/idbloader.img of=$img seek=64 conv=fsync,notrunc
      dd if=${uboot}/u-boot.itb of=$img seek=16384 conv=fsync,notrunc
    '';
  };
}
