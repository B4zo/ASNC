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
    firewall.allowedTCPPorts = [ 80 443 21 22 40000 40001 40002 40003 40004 40005 40006 40007 40008 40009 40010 587 ];
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
    mailutils
    systemd
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
      extraConfig = ''
        no_anon_password=YES
        user_sub_token=$USER
        local_root=/home/%u
        allow_writeable_chroot=YES
        pasv_enable=YES
        pasv_min_port=40000
        pasv_max_port=40010
        port_enable=YES
        pasv_address=127.0.0.1
        listen_address=0.0.0.0
      '';
    };

    postfix = {
      enable = true;
      rootAlias = "aljaz.skafar1@gmail.com";
      relayHost = "smtp.gmail.com";
      relayPort = 587;
      config = {
        smtp_use_tls = "yes";
        smtp_sasl_auth_enable ="yes";
        smtp_sasl_security_options = "noanonymus";
        smtp_sasl_password_maps = "hash:/etc/postfix/sasl_passwd";
        smtp_sasl_tls_security_options = "noanonymous";
        inet_protocols = "ipv4";
      };
    };

    openssh.enable = true;
  };

  system.copySystemConfiguration = true;
  system.stateVersion = "25.05";
}
