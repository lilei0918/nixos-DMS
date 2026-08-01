{
  config,
  pkgs,
  lib,
  ...
}: {
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = "WhiteSur-Dark";
      icon-theme = "WhiteSur";
      cursor-theme = "macOS-White";

      monospace-font-name = "JetBrainsMono Nerd Font 10";
    };

    "org/gnome/desktop/wm/preferences" = {
      titlebar-font = "Sans Bold 10";
      theme = "WhiteSur-Dark";
    };
  };
}
