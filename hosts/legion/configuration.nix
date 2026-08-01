{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [

    ./hardware-configuration.nix


    ################################
    # system modules
    ################################

    ../../system/nix.nix

    ../../system/boot.nix

    ../../system/hardware.nix

    ../../system/network.nix

    ../../system/services.nix


    ################################
    # desktop
    ################################

    ../../system/fonts.nix

    ../../system/input.nix

    ../../system/xdg.nix


    ################################
    # programs
    ################################

    ../../system/programs/nvidia-block.nix

    ../../system/mihomo.nix

    ../../system/packages.nix


    ################################
    # greeter
    ################################

    ../../system/greetd.nix


    ################################
    # secrets
    ################################

    ../../system/secrets.nix

  ];


  ################################
  # User
  ################################

  users.users.lilei = {

    isNormalUser = true;

    description = "lilei";

    shell = pkgs.zsh;


    extraGroups = [

      "wheel"

      "networkmanager"

      "video"

      "input"

      "hermes"

    ];


    hashedPassword =
      "***REMOVED***";

  };


  ################################
  # Home Manager
  ################################

  home-manager = {

    useGlobalPkgs = true;

    useUserPackages = true;


    # 给 home.nix / hermes.nix 使用 flake inputs

    extraSpecialArgs = {

      inherit inputs;

    };


    users.lilei = import ./home.nix;


    backupFileExtension = "backup";

  };


  ################################
  # dconf
  ################################

  programs.dconf.enable = true;


  ################################
  # Locale
  ################################

  time.timeZone = "Asia/Shanghai";

  console.keyMap = "us";


  ################################
  # Shell
  ################################

  programs.zsh.enable = true;


  ################################
  # NixOS version
  ################################

  system.stateVersion = "25.05";


  ################################
  # rebuild log
  ################################

  system.activationScripts.logRebuildTime = {

    text = ''

      LOG_FILE="/var/log/nixos-rebuild-log.json"

      TIMESTAMP=$(date "+%d/%m")

      GENERATION=$(readlink /nix/var/nix/profiles/system | grep -o '[0-9]\+')

      echo "{\"last_rebuild\": \"$TIMESTAMP\", \"generation\": $GENERATION}" > "$LOG_FILE"

      chmod 644 "$LOG_FILE"

    '';

  };

}