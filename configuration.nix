{ config, lib, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix ];

  boot = {
    kernelModules = [ "vboxguest" "vboxsf" "vboxvideo" ];
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 80 443 ];
  };

  time.timeZone = "Europe/Ljubljana";

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    keyMap = "slovene";
    font = "lat2-16";
  };

  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "vboxsf" "vboxguest" ];
    initialPassword = "1234";
    packages = with pkgs; [
      tree 
      vim
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    firebird_3
    php83
    virtualboxGuestAdditions
  ];

  services = {
    virtualboxGuest.enable = true;

    httpd = {
      enable = true;
      enablePHP = true;
      user = "wwwrun";
      group = "wwwrun";
      virtualHosts."localhost" = {
        documentRoot = "/var/www/localhost";
      };
    };

    mysql = {
      enable = true;
      package = pkgs.mariadb;
      ensureDatabases = [ "vici" ];
    };

    vsftpd = {
      enable = true;
      localUsers = true;
      writeEnable = true;
      localRoot = "/var/ftp";
    };

    postfix = {
      enable = true;
      rootAlias = "admin";
    };

    openssh.enable = true;
  };

  system.copySystemConfiguration = true;
  system.stateVersion = "25.05";
}
