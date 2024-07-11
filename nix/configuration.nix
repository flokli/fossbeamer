# Machine config
{ config
, modulesPath
, pkgs
, lib
, ...
}: {
  imports = [
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];

  # configure journald to not logs to disk
  services.journald.extraConfig = ''
    Storage=volatile
  '';

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # zfs keeps breaking, removing all unneeded filesystems from the image.
  boot.supportedFilesystems =
    lib.mkForce
      [ "vfat" ];

  # HACK: sd-image-aarch64.nix sets console=ttyS0,115200n8 (and some others),
  # which breaks the device-tree provided serial config.
  boot.kernelParams = lib.mkForce [
    "systemd.log_target=console"
    "systemd.journald.forward_to_console=1"
  ];

  nix.gc.automatic = true;
  nix.settings.max-jobs = 8;

  # Configure networking
  networking.hostName = "fossbeamer";
  networking.useDHCP = true;
  networking.useNetworkd = true;
  networking.wireless.iwd.enable = true;
  networking.networkmanager.enable = false;
  services.resolved.enable = true;
  services.resolved.dnssec = "false";
  networking.nftables.enable = true;

  # Configure ssh
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    openFirewall = true;
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPTVTXOutUZZjXLB0lUSgeKcSY/8mxKkC0ingGK1whD2 flokli"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIA34k0FVKDGNdJ8uk0Ytbvh6J8v+H86F4t6BXAIoW/7xAAAABHNzaDo= flokli 20240704 14321691"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIP7rdJ1klzK8nx74QQA8jYdFwznM1klLS0C7M5lHiu+IAAAABHNzaDo= flokli 20240617 28772765"
  ];

  programs.mosh.enable = true;


  # Create a kiosk user
  users.users.kiosk = {
    isNormalUser = true;
    uid = 1000;
  };

  # And configure cage to show fossbeamer on it.
  services.cage = {
    enable = true;
    environment.GDK_BACKEND = "x11";
    user = "kiosk";
    program = "${pkgs.fossbeamer}/bin/fossbeamer https://example.com";
  };

  environment.systemPackages = [
    pkgs.htop
  ];

  users.users."root".initialPassword = "";
  system.stateVersion = "24.05";
}
