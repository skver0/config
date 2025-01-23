# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'Dracula'
    '';
  };

in
{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/nixos.nix
    ];

  services.usbmuxd.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "hakudatsu"; # Define your hostname.

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Budapest";

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  
  programs.hyprland.enable = true;
    
  # Configure keymap in X11
  services.xserver = {
    layout = "hu";
    xkbVariant = "";
  };

  console.keyMap = "hu101";

  services.printing.enable = true;

  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.naturalScrolling = true;
  programs.fish.enable = true;
  services.postgresql = {
  enable = true;
};
# Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.skver = {
    shell = pkgs.fish;
    isNormalUser = true;
    description = "skver";
    extraGroups = [ "input" "networkmanager" "wheel" "docker" "video" ];
    packages = with pkgs; [
      firefox
      kitty
    #  thunderbird
    ];
  };

  environment.systemPackages = with pkgs; [
     libimobiledevice
     wget
     git
     p7zip
     fprintd
     python311
     sage
     brightnessctl
     hyprpaper
     wlr-randr
     nwg-displays
     swaylock
     rpi-imager
     pavucontrol
     htop
     glib
     dracula-theme
     gnome.adwaita-icon-theme
     xdg-utils
     configure-gtk
     gnome.nautilus
     gnome.eog
     wineWowPackages.waylandFull
     winetricks
     php
  ];

  services.fprintd = {
    enable = true;
    package = pkgs.fprintd;
  };

  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };

  system.stateVersion = "23.05"; # Did you read the comment? :)
}
