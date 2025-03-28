{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  vivado_pkg = pkgs.nur.repos.Nick1296.vivado-2019-2;
  vivado-desktop-symbol = pkgs.makeDesktopItem {
    name = "vivado-2019-2";
    desktopName = "Vivado2019.2";
    exec = "${vivado_pkg}/bin/vivado2019.2";
  };
  cfg = config.modules.programs.vivado;
  username = config.modules.system.username;
in {
  options.modules.programs.vivado.enable = mkEnableOption "vivado";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      vivado_pkg
      vivado-desktop-symbol
    ];

    # Create udev rules. Reference: https://blog.kotatsu.dev/posts/2021-09-14-vivado-on-nixos/
    services.udev.packages = [
      (pkgs.writeTextFile {
        name = "xilinx-dilligent-usb-udev";
        destination = "/etc/udev/rules.d/52-xilinx-digilent-usb.rules";
        text = ''
          ATTR{idVendor}=="1443", MODE:="666"
          ACTION=="add", ATTR{idVendor}=="0403", ATTR{manufacturer}=="Digilent", MODE:="666"
        '';
      })
      (pkgs.writeTextFile {
        name = "xilinx-pcusb-udev";
        destination = "/etc/udev/rules.d/52-xilinx-pcusb.rules";
        text = ''
          ATTR{idVendor}=="03fd", ATTR{idProduct}=="0008", MODE="666"
          ATTR{idVendor}=="03fd", ATTR{idProduct}=="0007", MODE="666"
          ATTR{idVendor}=="03fd", ATTR{idProduct}=="0009", MODE="666"
          ATTR{idVendor}=="03fd", ATTR{idProduct}=="000d", MODE="666"
          ATTR{idVendor}=="03fd", ATTR{idProduct}=="000f", MODE="666"
          ATTR{idVendor}=="03fd", ATTR{idProduct}=="0013", MODE="666"
          ATTR{idVendor}=="03fd", ATTR{idProduct}=="0015", MODE="666"
        '';
      })
      (pkgs.writeTextFile {
        name = "xilinx-ftdi-usb-udev";
        destination = "/etc/udev/rules.d/52-xilinx-ftdi-usb.rules";
        text = ''
          ACTION=="add", ATTR{idVendor}=="0403", ATTR{manufacturer}=="Xilinx", MODE:="666"
        '';
      })
    ];
  };
}
