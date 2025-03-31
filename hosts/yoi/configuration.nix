{ config, lib, pkgs, inputs, ... }: 
{
  imports =
    [
      ./hardware-configuration.nix
      ./system-packages.nix
      ../../modules/nixos.nix
      inputs.aagl.nixosModules.default
      inputs.spicetify-nix.nixosModules.default
    ];

  nix.settings = {
    substituters = ["https://nix-gaming.cachix.org" "https://ezkea.cachix.org"];
    trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="];
  };

  programs.steam.extraCompatPackages = [ pkgs.proton-ge-bin ];
  programs.steam.enable = true;

  programs.adb.enable = true;

  virtualisation.docker.enable = true;
  # virtualisation.vmware.host.enable = true;
  # virtualisation.waydroid.enable = true;

  # security is my passion, how could you tell?
  security.sudo.wheelNeedsPassword = false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 2;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];  
  /*boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_zen.override {
    argsOverride = rec {
      version = "6.13.0-zen";
      modDirVersion = "6.13.0-zen";
      src = pkgs.fetchFromGitHub {
        owner = "zen-kernel";
        repo = "zen-kernel";
        rev = "6.13/main";
        sha256 = "sha256-Ru8U0nkqFO9b8fVwz+PaV+MQB+UPZ4sPTJkE5eufKM8=";
      };
    };
  });*/
  boot.kernelPackages = pkgs.linuxPackages_zen; #pkgs.linuxKernel.packages.linux_xanmod_latest; #pkgs.linuxPackages_latest;
  boot.kernelModules = [ "i2c-dev" "i2c-piix4" "vfio-pci" "vfio" "vfio_iommu_type1" "vfio_virqfd" "nvidia_uvm" ];
  boot.kernelParams = [ "nvidia_drm.fbdev=1" "nvidia_drm.modeset=1" "amd_iommu=on" "kvm-amd.avic=1" "kvm_amd.nested=1" "kvm_amd.sev=1" "acpi_enforce_resources=lax" "pcie_acs_override=downstream,multifunction" "quiet" "udev.log_level=0" ]; 
  boot.tmp.cleanOnBoot = true;
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 0;

  hardware.cpu.amd.updateMicrocode = true;
  
  boot.extraModprobeConfig = "options vfio-pci ids=10de:0e22,10de:0beb";

  #services.postgresql.enable = true;
  services.dbus.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.gnome.at-spi2-core.enable = true;

  programs.nix-ld.enable = true;

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    portalPackage = inputs.hyprland.packages."${pkgs.system}".xdg-desktop-portal-hyprland;
  };

  #services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  programs.anime-games-launcher.enable = true;

  security.polkit.enable = true;
  /*services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "skver";
      };
      default_session = initial_session;
    };
  };*/
  
  # udev rules for rgb, keyboard etc
  services.udev.packages = with pkgs; [
   via
   openrgb
   android-udev-rules
   logitech-udev-rules
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
       nvidia-vaapi-driver
       egl-wayland
    ];
   # package = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.mesa.drivers;
    enable32Bit = true;
   # package32 = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.pkgsi686Linux.mesa.drivers;
  };  

  programs.spicetify = {
    enable = true;
    alwaysEnableDevTools = true;
    # https://github.com/BlafKing/spicetify-cat-jam-synced/tree/main/marketplace
    enabledExtensions = [
      inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system}.extensions.adblockify
      inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system}.extensions.hidePodcasts
      ({
        src = (pkgs.fetchFromGitHub {
          owner = "BlafKing";
          repo = "spicetify-cat-jam-synced";
          rev = "e7bfd49fcc13457bbc98e696294cf5cf43eb6c31";
          hash = "sha256-pyYa5i/gmf01dkEF9I2awrTGLqkAjV9edJBsThdFRv8=";
        }) + /marketplace;
        name = "cat-jam.js";
      })
    ];
    theme = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system}.themes.catppuccin;
    colorScheme = "mocha";
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
    device = "//192.168.0.104/pool";
    fsType = "cifs";
    options = let
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in ["${automount_opts},credentials=/smb-secrets"];
  };
  
  /*
  fileSystems."/mnt/share" = {
    device = "192.168.0.104:/mnt/pool";
    fsType = "nfs";
    options = [ 
       "x-systemd.automount" "noauto"
       "x-systemd.idle-timeout=600"
    ];
  };*/

  users.users.skver = {
    isNormalUser = true;
    extraGroups = [ "adbusers" "libvirtd" "cdrom" "wheel" "audio" "jackaudio" "docker" "video" "input" ];
    shell = pkgs.fish; 
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  environment.etc = {
    "ovmf/edk2-x86_64-secure-code.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
    };

    "ovmf/edk2-i386-vars.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
    };
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      runAsRoot = false;
      swtpm.enable = true;
      package = pkgs.qemu_kvm.overrideAttrs (attrs: {
        hostCpuOnly = true;
        patches = attrs.patches ++ [ ../../patches/qemu-9.2.2.patch ];
	    });
      ovmf = {
        packages = [
         (pkgs.OVMFFull.override {
             secureBoot = true;
             tpmSupport = true;
             edk2 = pkgs.edk2.overrideAttrs (attrs: {
              patches = attrs.patches ++ [ ../../patches/edk2-to-am.patch ];
            });
          }).fd
        ];
      };
    };
  };



  # more kvm fuckery, im so fucking fed up with anticheats, thank you mr corpo battleye

  boot.kernelPatches = [
    {
      name = "rdtsc";
      patch = ../../patches/rdtsc.patch;
    }
  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  services.ratbagd.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;  # printing
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };
  };

  services.zerotierone = {
    enable = true;
    joinNetworks = [
      "9F77FC393E1D110E"
    ];
  };

  hardware.keyboard.qmk.enable = true;

  hardware.logitech.wireless.enable = true;

  system.stateVersion = "22.11"; # Did you read the comment? yes, dont change this value unless you know what you are doing
}
