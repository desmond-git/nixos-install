  # Edit this configuration file to define what should be installed on
  # your system.  Help is available in the configuration.nix(5) man page
  # and in the NixOS manual (accessible by running ‘nixos-help’).

  { config, pkgs, ... }:

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
  
  # Mount tmpfs on /tmp
  boot.tmpOnTmpfs = true;
  
  # Intel microcode
  hardware.cpu.intel.updateMicrocode = true;
  
  # Enable NTFS-3G
  boot.supportedFilesystems = [ "ntfs" ];
  
  # SSD config
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
  services.fstrim.enable = true;
  
  # Nvidia drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.nvidiaSettings = true;
  
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
  
  # Enable the X11 windowing system
  services.xserver.enable = true;
    
  # Configure keymap in X11
  services.xserver = {
    layout = "se";
    xkbVariant = "";
  };
  
  # Configure console keymap
  console.keyMap = "sv-latin1";
   
  # Enable the GNOME Desktop Environment
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
 
  # Disable Gnome core packages
  services.gnome.core-utilities.enable = false;
  environment.gnome.excludePackages = [ pkgs.gnome-tour ];
  
  # Install Gnome packages
  programs.seahorse.enable = true;
  programs.gnome-disks.enable = true;
  programs.evince.enable = true;
  programs.file-roller.enable = true;
  
  # Enable Gnome stuff
  services.gnome.gnome-settings-daemon.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.gnome.sushi.enable = true;
  services.gnome.core-shell.enable = true;
  
  # Disable Xterm
  services.xserver.excludePackages = [ pkgs.xterm ];
  
  # Disable NixOS manual
  documentation.nixos.enable = false;
  
  # Fonts
  fonts = {
    enableDefaultFonts = true;
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fontconfig.enable = true;
    fonts = with pkgs; [
      corefonts
      noto-fonts
      dejavu_fonts
    ];
  };
  
  # Install packages
  environment.systemPackages = with pkgs; [
    
    # Essential
    unzip
    nix-index

    # Gnome
    gnome.gnome-tweaks
    baobab
    gnome.eog
    gnome-text-editor
    gnome.gnome-calculator
    gnome.gnome-characters
    gnome.gnome-screenshot
    gnome.gnome-font-viewer
    gnome.gnome-system-monitor
    gnome.nautilus
    gnome-console
    gnome.pomodoro
  
    # Multimedia
    ffmpeg_5-full
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
  
    # Software
    firefox
    tree
    btop
    clapper
    rhythmbox
    jdk11
  
    # Themes
    papirus-icon-theme
  ];

  # Webkit Nvidia rendering issue workaround
  environment.variables.WEBKIT_DISABLE_COMPOSITING_MODE = "1";

  # GDM monitor profile
  systemd.tmpfiles.rules = [
  "L+ /run/gdm/.config/monitors.xml - - - - ${pkgs.writeText "gdm-monitors.xml" ''
<monitors version="2">
  <configuration>
   *Paste the content of your monitor file here*.
  </configuration>
</monitors>
  ''}"
  ];
 
  # Enable mlocate
  services.locate = {
    enable = true;
    locate = pkgs.mlocate;
    interval = "hourly";
    localuser = null;
  };
 
  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 6881 ];
  networking.firewall.allowedUDPPorts = [ 6881 ];
   
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  # Users
  users.users.nixuser = {
    isNormalUser = true;
    description = "Nix User";
    hashedPassword = "";
    extraGroups = [ "networkmanager" "wheel" "mlocate" ];
  };
  }