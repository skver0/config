{ config, lib, pkgs, inputs, ... }: 
{
  imports =
    [
      ./hardware-configuration.nix
      ./system-packages.nix
      ../../modules/nixos.nix
      inputs.aagl.nixosModules.default
    ];

  nix.settings = {
    substituters = ["https://nix-gaming.cachix.org" "https://ezkea.cachix.org"];
    trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="];
  };

#  nixpkgs.overlays = [
#      (_: prev: {
#          steam = prev.steam.override {
#              extraProfile = "export STEAM_EXTRA_COMPAT_TOOLS_PATHS='${inputs.nix-gaming.packages.${pkgs.system}.proton-ge}'";
#          };
#      }) 
#  ];

  programs.steam.extraCompatPackages = [ pkgs.proton-ge-bin ];
  programs.steam.enable = true;


  programs.adb.enable = true;

  virtualisation.docker.enable = true;
#  virtualisation.vmware.host.enable = true;
  virtualisation.waydroid.enable = true;

  # security is my passion, how could you tell?
  security.sudo.wheelNeedsPassword = false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 2;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];  
  boot.kernelPackages = pkgs.linuxPackages_zen; #pkgs.linuxPackages_latest;
  boot.kernelModules = [ "i2c-dev" "i2c-piix4" "vfio-pci" "vfio" "vfio_iommu_type1" "vfio_virqfd" "nvidia_uvm" ];
  boot.kernelParams = [ "nvidia_drm.fbdev=1" "nvidia_drm.modeset=1" "amd_iommu=on" "kvm-amd.avic=1" "kvm_amd.nested=1" "kvm_amd.sev=1" "acpi_enforce_resources=lax" "pcie_acs_override=downstream,multifunction" "quiet" "udev.log_level=0" ]; 
  boot.tmp.cleanOnBoot = true;
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 0;

  hardware.cpu.amd.updateMicrocode = true;
  
  boot.extraModprobeConfig = "options vfio-pci ids=10de:1381,10de:0fbc";

  services.postgresql.enable = true;
  services.dbus.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.gnome.at-spi2-core.enable = true;

  programs.nix-ld.enable = true;

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    portalPackage = inputs.hyprland.packages."${pkgs.system}".xdg-desktop-portal-hyprland;
  };

  programs.anime-games-launcher.enable = true;

  security.polkit.enable = true;
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

  services.mullvad-vpn.enable = true;

  # udev rules for rgb, keyboard etc
  services.udev.packages = with pkgs; [
   via
   openrgb
   android-udev-rules
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
       nvidia-vaapi-driver
       egl-wayland
    ];
  };  
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  hardware.nvidia.open = true;

  # torrent client, wireguard, nginx
  networking.firewall.allowedTCPPorts = [ 57466 24800 25565 80 ];
  networking.firewall.allowedUDPPorts = [ 57466 24800 25565 80 ];

  networking.hostName = "yoi";
  time.timeZone = "Europe/Budapest";

  # man how are you going to play osu
  hardware.opentabletdriver.enable = true;

  programs.dconf.enable = true;
  programs.xfconf.enable = true;
  programs.thunar.enable = true;
  services.gvfs.enable = true; 
  services.tumbler.enable = true;

  programs.fish.enable = true;

  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/48AA28D3AA28BF76";
    fsType = "ntfs";
  };

  fileSystems."/mnt/ssd" = {
    device = "/dev/disk/by-uuid/911c6e23-3919-48b4-bc73-c6e3a73a0d1c";
    fsType = "btrfs";
    options = [ "compress=zstd" ];
  };

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
    extraGroups = [ "adbusers" "libvirtd" "cdrom" "wheel" "audio" "jackaudio" "docker" "storage" ];
    shell = pkgs.fish; 
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      runAsRoot = false;
      swtpm.enable = true;
      #package = pkgs.qemu_kvm.overrideAttrs (attrs: {
      #  hostCpuOnly = true;
      #  patches = attrs.patches ++ [ ../../patches/qemu-8.2.0.patch ];
	    #});
      ovmf = {
        packages = [
         (pkgs.OVMFFull.override {
             secureBoot = true;
             tpmSupport = true;
            # edk2 = pkgs.edk2.overrideAttrs (attrs: {
            #  patches = attrs.patches ++ [ ../../patches/edk2-to-am.patch ];
            #});
          }).fd
        ];
      };
    };
  };

  environment.etc = {
    "ovmf/edk2-x86_64-secure-code.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
    };

    "ovmf/edk2-i386-vars.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
    };
  };

  # more kvm fuckery, im so fucking fed up with anticheats, thank you mr corpo battleye

#  boot.kernelPatches = [
#     {
#        name = "rdtsc";
#        patch = ../../patches/rdtsc.patch;
#     }
#  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  system.stateVersion = "22.11"; # Did you read the comment? yes, dont change this value unless you know what you are doing
}
