{ config, pkgs, inputs, ... }:
{
  imports = [
    ../../modules/emacs.nix
    ../../modules/discord.nix
  ];

  home.username = "skver";
  home.homeDirectory = "/home/skver";

  home.stateVersion = "23.05"; 
  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    firefox
    (jetbrains.plugins.addPlugins jetbrains.idea-ultimate [ "github-copilot" "darcula-pitch-black" ])
    vscode
    easyeffects
    obsidian
    audacity
    prismlauncher
    lutris
    gimp
    vial
    sshfs
    telegram-desktop
    pavucontrol
    google-chrome
    qbittorrent
    yt-dlp
    obs-studio
    steam-run
    steam
    spotify
    pfetch
    flameshot
    picom
    pywal
    rpi-imager
    texlive.combined.scheme-full
    inputs.nix-gaming.packages.x86_64-linux.osu-stable
    waybar
    jdk17
    hyprpaper
  ];

  home.file = {
    ".config/i3".source = ../../home/i3;
    ".config/polybar".source = ../../home/polybar;
    ".config/rofi".source = ../../home/rofi;
    ".config/alacritty".source = ../../home/alacritty;
  };
  
  programs.home-manager.enable = true;
}
