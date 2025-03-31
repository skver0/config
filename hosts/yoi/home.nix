{ config, pkgs, inputs, ... }:
{
  imports = [
    #../../modules/emacs.nix
    ../../modules/discord.nix
    inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger
  ];

  home.username = "skver";
  home.homeDirectory = "/home/skver";
  
  home.stateVersion = "23.05"; 
  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    #(jetbrains.plugins.addPlugins jetbrains.idea-ultimate [ "github-copilot" "darcula-pitch-black" ])
    vscode
    easyeffects
    audacity
    prismlauncher
    lutris
    vial
    sshfs
    pavucontrol
    google-chrome
    qbittorrent
    yt-dlp
    obs-studio
    steam-run
    pfetch
    pywal
    rpi-imager
    #texlive.combined.scheme-full
    #inputs.nix-gaming.packages.x86_64-linux.osu-lazer-bin
    #inputs.nix-gaming.packages.x86_64-linux.osu-stable
    waybar
    hyprpaper
    mangohud
    any-nix-shell
    kdePackages.ark
    nodejs
    nodePackages.pnpm
    gpu-screen-recorder
    gpu-screen-recorder-gtk
    obsidian
    mpvpaper
    xivlauncher
    virt-viewer
    rpcs3
    slack
    uxplay
    inputs.zen-browser.packages."${system}".default
    (import ./../../modules/byar.nix { pkgs = pkgs; })
    remmina
    xorg.xrandr
    solaar
    piper
    plexamp
    umu-launcher
    code-cursor
  ];

  programs.hyprcursor-phinger.enable = true;
  
  programs.hyprlock = {
    enable = false;
  };

  services.hypridle.enable = false;
  
/*  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };

    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
    
  };
*/  
  home.file = {
#    ".config/i3".source = ../../home/i3;
#    ".config/polybar".source = ../../home/polybar;
    ".config/rofi".source = ../../home/rofi;
    ".config/alacritty".source = ../../home/alacritty;
    ".config/hypr".source = ../../home/hypr;
    ".config/waybar".source = ../../home/waybar;
  };

  xdg.enable = true;
  xdg.mime.enable = true;
  
  programs.home-manager.enable = true;
}
