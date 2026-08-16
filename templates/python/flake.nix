{
  description = "Python 项目脚手架（uv + direnv）";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        uv # Python 版本 + .venv + 依赖 + lock
        python3 # 兜底（uv 会为项目另装版本）
        gcc # 编译 C 扩展需要
        pkg-config
        just
      ];
    };
  };
}
