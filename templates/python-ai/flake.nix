{
  description = "Python AI/Data 项目脚手架（uv + direnv）";

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
        uv
        python3 # 兜底
        gcc # 部分 AI 包编译需要
        pkg-config
        just
      ];
    };
  };
}
