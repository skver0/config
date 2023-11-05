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
    trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 2;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "ntfs" ];  

  boot.kernelPackages = pkgs.linuxPackages_zen; #pkgs.linuxPackages_latest;
  boot.kernelModules = [ "i2c-dev" "i2c-piix4" "vfio-pci" ];

  boot.blacklistedKernelModules = [ "amdgpu" "radeon" ];
  boot.kernelParams = [ "acpi_enforce_resources=lax" "pcie_acs_override=downstream,multifunction" "vfio-pci.ids=1002:6610,1002:aab0" ]; 
  #openrgb aint working without the last one

  services.postgresql.enable = true;
  services.dbus.enable = true;
  services.gnome.gnome-keyring.enable = true;

  programs.hyprland.enable = true;

  services.xserver.displayManager.gdm.enable = true;
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

  # udev rules for rgb, keyboard etc
  services.udev.packages = with pkgs; [
   via
   openrgb
  ];

  # display setup
  #  services.xserver.displayManager.setupCommands = ''
  #    ${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-0 --left-of DP-2
  #    ${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --primary --mode 1920x1080 --rate 144.00
  #'';
  
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;  
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.nvidia.modesetting.enable = true;
  
  # torrent client, wireguard, nginx
  networking.firewall.allowedTCPPorts = [ 57466 24800 80 ];
  networking.firewall.allowedUDPPorts = [ 57466 24800 80 ];

  networking.hostName = "yoi";
  time.timeZone = "Europe/Budapest";

  # man how are you going to play osu
  hardware.opentabletdriver.enable = true;

  programs.dconf.enable = true;
  programs.fish.enable = true;
  # hacky fix to auto mount ntfs partition
  fileSystems."/mnt" = {
    device = "/dev/disk/by-uuid/6A0AD5730AD53CAF";
    fsType = "auto";
    options = [ 
     "uid=1000"
     "gid=1000"
     "rw"
     "user"
     "exec"
     "umask=000" 
     "x-systemd.automount"
     "windows_names"
     "prealloc"
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

  #virtualisation.vmware.host.enable = true;
  #virtualisation.virtualbox.host.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
     swtpm.enable = true;
    };  
  };
  #virtualisation.docker.enable = true;

  system.stateVersion = "22.11"; # Did you read the comment? yes, dont change this value unless you know what you are doing
}
