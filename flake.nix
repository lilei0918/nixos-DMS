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

      # 与 niri/daeuniverse 同理：hermes 源码固定 commit，其 npm 依赖从 registry.npmjs.org
      # 抓取（本机直连该源仅 ~25-200KB/s），pin 到旧 nixpkgs（624af66）可使 hermes
      # 构建完全命中旧缓存，避免每次 nixpkgs 升级都重新下载全部 npm 依赖。
      inputs.nixpkgs.url = "github:NixOS/nixpkgs/624af665418d3c65d544145b4d34ad696439570e";
    };

    # =============================
    # Secrets
    # =============================

    sops-nix = {
      url = "github:Mic92/sops-nix";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    # =============================
    # Pre-commit Hooks（提交前自动格式化/检查）
    # =============================

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";

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
    pre-commit-hooks,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    myvars = import ./vars {
      inherit lib;
    };

    # Eval 测试：nix eval .#evalTests
    evalTests = let
      tests = import ./tests {
        inherit lib myvars;
        outputs = self;
      };
    in
      lib.all (v: v) (lib.attrValues tests);

    # 把 eval 测试包装成 derivation，供 `nix flake check` 使用
    # 注意：tests/default.nix 内部用 assertMsg，测试失败会直接抛错，
    # 因此这里只需强制求值 evalTests，求值成功即代表全部通过。
    evalTestsCheck = nixpkgs.legacyPackages.x86_64-linux.runCommand "eval-tests" {} ''
      echo "all eval tests passed" > $out
      ${lib.optionalString evalTests ""}
    '';

    # pre-commit 检查（nix 格式化 + 拼写检查）
    preCommitCheck = pre-commit-hooks.lib.x86_64-linux.run {
      src = self;

      hooks = {
        alejandra = {
          enable = true;
          settings.check = true;
        };
        typos = {
          enable = true;
          settings = {
            write = true;
            configPath = ".typos.toml";
          };
        };
        # deadnix.enable = true; # 检测 *.nix 中的未使用变量
        # statix.enable = true; # nix 代码 lint
      };
    };
  in {
    # =============================
    # NixOS Host
    # =============================

    nixosConfigurations.legion = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit self inputs myvars;
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

    # Eval 测试
    inherit evalTests;

    # Checks（供 nix flake check 使用）
    checks.x86_64-linux = {
      inherit evalTestsCheck preCommitCheck;
    };

    # Dev Shells（nix develop 进入开发环境）
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      # 进入 nix develop 时自动安装 git pre-commit 钩子
      inherit (self.checks.x86_64-linux.preCommitCheck) shellHook;

      packages = [
        nixpkgs.legacyPackages.x86_64-linux.alejandra
        nixpkgs.legacyPackages.x86_64-linux.typos
      ];
    };

    # =============================
    # 项目脚手架模板
    # 用法：nix flake init -t <flake>#<name>
    #   本地：nix flake init -t ~/nixos-DMS#python
    #   GitHub：nix flake init -t github:lilei0918/nixos-DMS#python
    # 详见 templates/ 与 MEMO「十一、开发环境」
    # =============================

    templates = {
      python = {
        path = ./templates/python;
        description = "Python 项目（uv + direnv）";
      };
      python-pyside6 = {
        path = ./templates/python-pyside6;
        description = "Python + PySide6/QML 项目（uv + direnv）";
      };
      python-ai = {
        path = ./templates/python-ai;
        description = "Python AI/Data 项目（uv + direnv）";
      };
      node = {
        path = ./templates/node;
        description = "Node.js 项目（pnpm + direnv）";
      };
    };

    # =============================
    # Formatter
    # =============================

    formatter.x86_64-linux =
      nixpkgs.legacyPackages.x86_64-linux.alejandra;
  };
}
