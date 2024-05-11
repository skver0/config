{ config, pkgs, ... }:
{
 environment.systemPackages = with pkgs; [
    dunst
    cifs-utils
    virt-manager
    glib
    alsa-utils
    gnupg
    wget
    zip
    alacritty
    rofi-wayland
    gnome3.gnome-keyring
    gnome3.eog
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
    protonup-qt
    (pkgs.hwloc.override {
      x11Support = true;
      })
    lxqt.lxqt-policykit
  ];
}
