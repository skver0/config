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
    (jetbrains.plugins.addPlugins jetbrains.idea-ultimate [ "github-copilot" ])
    vscode
    obsidian
    gimp
    pavucontrol
    chromium
    discord
    spotify
    pfetch
    flameshot
    picom
    pywal
    rpi-imager
    texlive.combined.scheme-full
    ripgrep
    nodejs
    nodePackages.pnpm
    waybar
    wofi
    kanshi
  ];
  home.file = {
    ".config/i3".source = ../../home/i3;
    ".config/polybar".source = ../../home/polybar;
    ".config/rofi".source = ../../home/rofi;
    ".config/alacritty".source = ../../home/alacritty;
  };
  programs.home-manager.enable = true;
}
