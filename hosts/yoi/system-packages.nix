{ config, pkgs, ... }:
{
 environment.systemPackages = with pkgs; [
    dunst
    cifs-utils
    authy
    virt-manager
    glib
    alsa-utils
    gnupg
    wget
    zip
    alacritty
    rofi
    gnome3.gnome-keyring
    gnome3.eog
    gnome3.nautilus
    htop
    killall
    zip
    unzip
    rar
    unrar
    p7zip
    ffmpeg
    mpv
    wineWowPackages.staging
    winetricks
    lxappearance
    git
    qemu_kvm
    qjackctl
    shared-mime-info
    xdg-utils
    (pkgs.hwloc.override {
      x11Support = true;
      })
  ];
}
