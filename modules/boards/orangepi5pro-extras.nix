# Optional hardware workarounds for the Orange Pi 5 Pro.
#
# The OPi5 Pro uses a Motorcomm YT6801 PCIe ethernet controller.
# Despite being marketed as "gigabit", the board's PHY/PCB signal
# integrity cannot complete 1000BASE-T link training — attempting it
# wastes ~14 s on every link event before falling back to 100 Mbps.
# This may be exacerbated by PoE HATs adding electrical noise to the
# PCIe/ethernet path.  Stripping the 1000BASE-T advertisement from
# autonegotiation makes link-up after a flap take ~2 s instead.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.rk3588.orangepi5pro;
in {
  options.rk3588.orangepi5pro = {
    ethernetWorkaround.enable = lib.mkEnableOption ''
      YT6801 PCIe ethernet autonegotiation workaround.
      Limits advertisement to 10/100 Mbps — the board cannot
      train at 1000BASE-T due to PHY/PCB signaling limitations
    '';

    disableLeds.enable = lib.mkEnableOption ''
      disable the bright green and blue status LEDs via udev
    '';
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.ethernetWorkaround.enable {
      environment.systemPackages = [pkgs.ethtool];

      systemd.network.links."10-yt6801" = {
        matchConfig.Driver = "yt6801";
        linkConfig = {
          # Strip 1000BASE-T advertisement — the PHY can't train at
          # gigabit (possibly worsened by PoE HAT noise on the PCIe
          # path), so advertising it wastes ~14 s on every link event
          # before falling back to 100.  With only 10/100 advertised,
          # link-up after a flap takes ~2 s instead.
          AutoNegotiation = true;
          Advertise = "10baset-half 10baset-full 100baset-half 100baset-full";
        };
      };
    })

    (lib.mkIf cfg.disableLeds.enable {
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="leds", KERNEL=="green_led", ATTR{trigger}="none", ATTR{brightness}="0"
        ACTION=="add", SUBSYSTEM=="leds", KERNEL=="blue_led", ATTR{trigger}="none", ATTR{brightness}="0"
      '';
    })
  ];
}
