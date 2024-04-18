  # Edit this configuration file to define what should be installed on
  # your system.  Help is available in the configuration.nix(5) man page
  # and in the NixOS manual (accessible by running ‘nixos-help’).

  { config, lib, pkgs, ... }:

  {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
    
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # UEFI bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.systemd-boot.configurationLimit = "1";

  # Mount tmpfs on /tmp
  boot.tmp.useTmpfs = true;
  
  # Intel microcode
  hardware.cpu.intel.updateMicrocode = true;
  
  # Enable NTFS-3G
  boot.supportedFilesystems = [ "ntfs" ];
  
  # SSD config
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
  services.fstrim.enable = true;
  
  # Enable sound with pipewire
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };
  
  # Hostname
  networking.hostName = "nixos";
  
  # Set time zone
  time.timeZone = "Europe/Stockholm";
  
  # Enable networking
  networking.networkmanager.enable = true;
  
  # Disable Bluetooth
  hardware.bluetooth.enable = false;
  
  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  # Intel GPU
  boot.kernelParams = [ "i915.force_probe=5690" ];

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    setLdLibraryPath = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
      intel-compute-runtime
      intel-ocl
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Force intel-media-driver
    VDPAU_DRIVER = lib.mkIf config.hardware.opengl.enable (lib.mkDefault "va_gl");
  };
  
  # Enable the X11 windowing system
  services.xserver.enable = true;
    
  # Configure keymap in X11
  services.xserver.xkb.layout = "se";
  
  # Configure console keymap
  console.keyMap = "sv-latin1";
   
  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  programs.xwayland.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasma";
  xdg.portal.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = false;
  
  # Fonts
  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fontconfig.enable = true;
    packages = with pkgs; [
      corefonts
      noto-fonts
      dejavu_fonts
    ];
  };
  
  # Install packages
  environment.systemPackages = with pkgs; [
    
    # Essential / Useful
    unzip
    wget
    fd
    
    # KDE Software
    krita
    haruna
    kdePackages.ktorrent
    kdePackages.kjournald
    kdePackages.ksystemlog
    kdePackages.partitionmanager

    # Multimedia
    ffmpeg-full
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav

    # Software
    tree
    floorp

    # Themes
    papirus-folders

    # Gaming
    protonup-qt
    ryujinx
  ];

  # Environment flags
  environment.sessionVariables = {
  MOZ_ENABLE_WAYLAND = "1";
  STEAM_FORCE_DESKTOPUI_SCALING = "2";
  };

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    extest.enable = true; # For using Steam Input on Wayland
  };

  # Disable Xterm
  services.xserver.excludePackages = [ pkgs.xterm ];

  # Disable NixOS manual
  documentation.nixos.enable = false;

  # Install Firefox.
  programs.firefox.enable = false;
  
  # Install Java JRE
  programs.java = { enable = true; package = pkgs.jdk22; };
  
  # Gstreamer plugins path
  environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with pkgs.gst_all_1; [
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
  ]);
 
  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 49152 ];
  networking.firewall.allowedUDPPorts = [ 49152 8881 7881 ];
   
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  # Users
  users.users.desmond = {
    isNormalUser = true;
    description = "NixUser";
    hashedPassword = "$$$$$$";
    extraGroups = [ "networkmanager" "wheel" ];
  };
  }
