{
  description = "Lei NixOS configuration";

  inputs = {
    # =============================
    # Nixpkgs
    # =============================

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # =============================
    # Home Manager
    # =============================

    home-manager = {
      url = "github:nix-community/home-manager";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    # =============================
    # NUR
    # =============================

    nur.url = "github:nix-community/NUR";

    # =============================
    # DankMaterialShell
    # =============================

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    # =============================
    # Niri
    # =============================

    niri = {
      url = "github:sodiboo/niri-flake";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    # =============================
    # Hermes Agent
    # =============================

    hermes-agent = {
      url = "github:NousResearch/hermes-agent/1cdb8ce361e91c79cfbd6bee550ee6c09d290261";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    # =============================
    # Secrets
    # =============================

    sops-nix = {
      url = "github:Mic92/sops-nix";

      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nur,
    dms,
    niri,
    hermes-agent,
    sops-nix,
    ...
  } @ inputs: {
    # =============================
    # NixOS Host
    # =============================

    nixosConfigurations.legion = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit self inputs;
      };

      modules = [
        # 主机配置

        ./hosts/legion/configuration.nix

        # Home Manager

        home-manager.nixosModules.default

        # Hermes

        hermes-agent.nixosModules.default

        # Secrets

        sops-nix.nixosModules.sops
      ];
    };

    # =============================
    # Formatter
    # =============================

    formatter.x86_64-linux =
      nixpkgs.legacyPackages.x86_64-linux.alejandra;
  };
}
