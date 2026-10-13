# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    # Use latest kernel.
    kernelPackages = pkgs.linuxPackages;

    initrd.kernelModules = [ "nvidia" "nvidiafb" "i915" "nvidia_modeset" "nvidia_drm" "nvidia_uvm" ];
    extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
    kernelParams = [ "nvidia-drm.fbdev=1" "nvidia.NVreg_TemporaryFilePath=/var/tmp" ];
  }; 
  
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Mexico_City";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable Bluetooth hardware.
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  # Enable OpenGl / Graphics 
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Tell XOrg/Wayland to use the nvidia driver 
  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware.nvidia = {
    # Modesetting is required for Wayland modern setups
    modesetting.enable = true;

    # Enable the Nvidia setting menu (access via `nvidia-settings`)
    nvidiaSettings = true;

    # Pick a driver package (e.g. stable, production or legacy)
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

    # Optional: Use nvidia's open-source kernel modules (Turing architecture or newer: RTX+)
    open = false;

    # Try fixing the suspend/resume corruption issues 
    powerManagement.enable = true;
  };

  # Enable blueman, for lightweight DEs.
  # services.blueman.enable = true;

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."tamal" = {
    isNormalUser = true;
    description = "Tamal Bot";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      blender
      godot
      godot3
      helix
      jetbrains.rider
      kdePackages.kate
      rio
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Install niri
  # programs.niri.enable = true;

  # NixOS otherwise injects a stripped PATH via Environment= on the niri.service
  # unit which shadows the imported user-manager PATH. Disabling the default 
  # lets niri inherit the full PATH set up by niri-session.
  # systemd.user.services.niri.enableDefaultPath = false;
  
  # security.polkit.enable = true; # polkit
  # services.gnome.gnome-keyring.enable = true; # secret service
  # security.pam.services.swaylock = {};

  # programs.waybar.enable = true; # top bar

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    alacritty
    btop
    deskflow
    fastfetch
    kdePackages.filelight
    #fuzzel
    ghostty
    git
    kitty
    #mako
    neovim
    #swayidle
    #swaylock
    thunderbird
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    zed-editor
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Ollama
  services.ollama = {
    enable = true;
    # Optional: preload models, see https://ollama.com/library
    # loadModels = [ "llama3.2:3b" "deepseek-r1:8b" "deepseek-coder:6.7b" "gemma4:e4b"];
    package = pkgs.ollama-vulkan;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}
