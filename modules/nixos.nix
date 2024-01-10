{ config, pkgs, inputs, ... }: 
{
  services.fstrim.enable = true;
  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    font-awesome
    dina-font
    terminus_font
    corefonts
    jetbrains-mono
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
  ];

  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--recreate-lock-file"
      "--no-write-lock-file"
      "-L"
    ];
    dates = "daily";
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  networking.firewall.logRefusedConnections = false;
  xdg.mime.enable = true;

  nix.gc = {
   automatic = true;
   dates = "weekly";
   options = "--delete-older-than 10d";
  };

  # nightlight
  services.geoclue2.appConfig.redshift.isAllowed = true;
  location.provider = "geoclue2";

  services.redshift = {
    enable = true;
    brightness = {
      day = "1";
      night = "1";
    };
    temperature = {
      day = 6500;
      night = 3700;
    };
  };

  # pipest wire, audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    socketActivation = true;
  };
}
