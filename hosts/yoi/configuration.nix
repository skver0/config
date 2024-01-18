{ config, pkgs, inputs, ... }: 
{
  imports =
    [
      ./hardware-configuration.nix
      ./system-packages.nix
      ../../modules/nixos.nix
    ];

  nix.settings = {
    substituters = ["https://nix-gaming.cachix.org"];
    trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  nixpkgs.overlays = [
      (_: prev: {
          steam = prev.steam.override {
              extraProfile = "export STEAM_EXTRA_COMPAT_TOOLS_PATHS='${inputs.nix-gaming.packages.${pkgs.system}.proton-ge}'";
          };
      })
  ];

  virtualisation.docker.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 2;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];  
  boot.kernelPackages = pkgs.linuxPackages_zen; #pkgs.linuxPackages_latest;
  boot.kernelModules = [ "i2c-dev" "i2c-piix4" "vfio-pci" ];
  boot.blacklistedKernelModules = [ "amdgpu" "radeon" ];
  boot.kernelParams = [ "acpi_enforce_resources=lax" "pcie_acs_override=downstream,multifunction" "quiet" "udev.log_level=0" ]; 
  boot.tmp.cleanOnBoot = true;

  boot.initrd.verbose = false;
  boot.consoleLogLevel = 0;

  services.postgresql.enable = true;
  services.dbus.enable = true;
  services.gnome.gnome-keyring.enable = true;
  # services.xserver.displayManager.gdm.enable = true;

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    portalPackage = inputs.hyprland.packages."${pkgs.system}".xdg-desktop-portal-hyprland;
  };

  services.xserver = {
    enable = true;
    layout = "hu";
    libinput = {
      enable = true;
      mouse = {
        accelProfile = "flat";
      };
    };
  };

  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "skver";
      };
      default_session = initial_session;
    };
  };

  # udev rules for rgb, keyboard etc
  services.udev.packages = with pkgs; [
   via
   openrgb
  ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;  
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.nvidia.modesetting.enable = true;
#  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.production;
#  hardware.nvidia.open = true;

  # torrent client, wireguard, nginx
  networking.firewall.allowedTCPPorts = [ 57466 24800 25565 80 ];
  networking.firewall.allowedUDPPorts = [ 57466 24800 25565 80 ];

  networking.hostName = "yoi";
  time.timeZone = "Europe/Budapest";

  # man how are you going to play osu
  hardware.opentabletdriver.enable = true;

  programs.dconf.enable = true;
  programs.fish.enable = true;
  # hacky fix to auto mount ntfs partition
#  fileSystems."/mnt/hdd" = {
#    device = "/dev/disk/by-uuid/6A0AD5730AD53CAF";
#    fsType = "auto";
#    options = [ 
#     "uid=1000"
#     "gid=1000"
#     "rw"
#     "user"
#     "exec"
#     "umask=000" 
#     "x-systemd.automount"
#     "windows_names"
#     "prealloc"
#     "big_writes"
#    ];
#  };

  fileSystems."/mnt/share" = {
    device = "192.168.0.104:/mnt/pool";
    fsType = "nfs";
    options = [ 
       "x-systemd.automount" "noauto"
       "x-systemd.idle-timeout=600"
    ];
  };

  users.users.skver = {
    isNormalUser = true;
    extraGroups = [ "libvirtd" "wheel" "audio" "jackaudio" "storage" ];
    shell = pkgs.fish; 
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
     swtpm.enable = true;
#     ovmf.packages = [ pkgs.OVMFFull ];
    };  
  };

  system.stateVersion = "22.11"; # Did you read the comment? yes, dont change this value unless you know what you are doing
}
