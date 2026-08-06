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

    # =============================
    # Proxy: dae / daed
    # =============================
    # 注意：不用 inputs.nixpkgs.follows，且把 daeuniverse 自己的 nixpkgs 固定到它
    # 验证过的 commit（b12141ef，pnpm 10.x）。跟随最新 nixpkgs（pnpm 11+）会导致
    # daed 的 fetchPnpmDeps(fetcherVersion=3) 断言失败、无法构建。

    daeuniverse = {
      url = "github:daeuniverse/flake.nix/42ece300b6360bab592f13c64ce1987df20475d5";

      inputs.nixpkgs.url = "github:NixOS/nixpkgs/b12141ef619e0a9c1c84dc8c684040326f27cdcc";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
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
