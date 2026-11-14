{inputs, ...}: {
  # NUR 经官方 overlay 接入（flake-first；旧式 `import inputs.nur {...}` shim 已弃用）
  nixpkgs.overlays = [
    inputs.nur.overlays.default
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    auto-optimise-store = true;

    substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=1"
      "https://mirrors.ustc.edu.cn/nix-channels/store?priority=2"
      "https://cache.nixos.org?priority=20"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];

    # Noctalia 官方 Cachix（预编译 nocatalia 包；follows nixpkgs 会使缓存失效）
    extra-substituters = ["https://noctalia.cachix.org"];
    extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
  };

  nix.gc = {
    automatic = true;

    dates = "daily";

    # 保留最近 7 天的旧 generation（含 store 路径），超出自动删除。
    # NixOS 内置 nix-gc.timer 带 Persistent=true，凌晨关机错过会在下次开机后补跑。
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;
}
