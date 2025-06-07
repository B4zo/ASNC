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
    firewall.allowedTCPPorts = [ 80 443 21 22 ];
  };

  time.timeZone = "Europe/Ljubljana";

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    keyMap = "slovene";
    font = "lat2-16";
  };

  virtualisation.virtualbox.guest.enable = true;

  users.users = { 
    admin = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" "vboxsf" "vboxguest" ];
      initialPassword = "1234";
      openssh.authorizedKeys.keys = [ "ssh-25519 AAAAC3NzaC1lZDI1NTE5AAAAIO9aoRyQAW1uCSMEsjkAkx6yLVAwZ+MY4qXtGojUarbi admin@nixos" ];
      packages = with pkgs; [
          inetutils
      ];
    };
    ftpuser = {
      isNormalUser = true;
      initialPassword = "1234";     
    };
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    firebird_3
    php83
    git
  ];

  services = {
    httpd = {
      enable = true;
      enablePHP = true;
      user = "wwwrun";
      group = "wwwrun";
      virtualHosts."localhost" = { 
         documentRoot = "/var/www/localhost";
         extraConfig = ''
           <Directory "/var/www/localhost">
             Options Indexes FollowSymLinks
             AllowOverride All
             Require all granted
           </Directory>
         '';
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
