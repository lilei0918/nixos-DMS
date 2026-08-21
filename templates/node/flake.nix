{
  description = "Node.js 项目脚手架（pnpm + direnv）";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {nixpkgs}: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        nodejs_22 # Node LTS
        corepack # 按 package.json 的 packageManager 固定 pnpm/yarn 版本
        pnpm
        just
      ];
    };
  };
}
