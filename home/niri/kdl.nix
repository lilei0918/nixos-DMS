{
  config,
  lib,
  ...
}: let
  # 用 out-of-store 符号链接指向仓库内 KDL 文件，改配置即时生效（niri 热重载）
  mkSymlink = config.lib.file.mkOutOfStoreSymlink;
  confDir = "${config.home.homeDirectory}/nixos-DMS/home/niri/conf";
in {
  xdg.configFile = {
    "niri/config.kdl".source = mkSymlink "${confDir}/config.kdl";
    "niri/keybindings.kdl".source = mkSymlink "${confDir}/keybindings.kdl";
    "niri/windowrules.kdl".source = mkSymlink "${confDir}/windowrules.kdl";
    "niri/spawn-at-startup.kdl".source = mkSymlink "${confDir}/spawn-at-startup.kdl";
  };
}
