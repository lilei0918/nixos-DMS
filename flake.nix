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

      # 新 nixpkgs 把 libdisplay-info 升到 0.3 并删除 libdisplay-info_0_2，
      # 而 niri-flake 仍断言 0.2.0（其 flake.nix: assert libdisplay-info_0_2.version == "0.2.0"），
      # 故把 niri 自己的 nixpkgs 固定到验证过的旧 commit（624af66，libdisplay-info 0.2.0）。
      # 参照 daeuniverse 的写法，避免 nixpkgs 升级连带弄坏 niri。
      # 上游修复（改用 libdisplay-info 0.3）后可移除本 pin。
      inputs.nixpkgs.url = "github:NixOS/nixpkgs/624af665418d3c65d544145b4d34ad696439570e";
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
