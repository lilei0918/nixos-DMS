{inputs, ...}: {
  nixpkgs.overlays = [
    (_: prev: {
      nur = import inputs.nur {
        nurpkgs = prev;
        pkgs = prev;
      };
    })
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

    options = "--delete-older-than 5d";
  };

  nixpkgs.config.allowUnfree = true;
}
