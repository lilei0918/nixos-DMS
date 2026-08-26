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
    ];
  };

  nix.gc = {
    automatic = true;

    dates = "daily";

    # 保留最近 3 天的旧 generation（含 store 路径），超出自动删除。
    # NixOS 内置 nix-gc.timer 带 Persistent=true，凌晨关机错过会在下次开机后补跑。
    options = "--delete-older-than 3d";
  };

  nixpkgs.config.allowUnfree = true;
}
