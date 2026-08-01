{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  settings = import ./settings.nix {
    inherit
      config
      pkgs
      inputs
      lib
      ;
  };
  keybinds = import ./keybinds.nix {
    inherit
      config
      pkgs
      inputs
      lib
      ;
  };
  rules = import ./rules.nix {
    inherit
      config
      pkgs
      inputs
      lib
      ;
  };
  autostart = import ./autostart.nix {
    inherit
      config
      pkgs
      inputs
      lib
      ;
  };
in
  # 使用 // 合并（后面的覆盖前面的，但通常各键不同，无冲突）
  settings // keybinds // rules // autostart
