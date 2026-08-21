{
  description = "Python + PySide6/QML 项目脚手架（uv + direnv）";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {nixpkgs}: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        uv
        python3 # 兜底
        gcc
        pkg-config
        # PySide6 wheel 运行时保险（nix-ld 全局已提供，缺库时可去掉重复项）
        libGL
        libxkbcommon
        libxcb
        fontconfig
        just
      ];
    };
  };
}
