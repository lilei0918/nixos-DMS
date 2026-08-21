{myvars, ...}: {
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = myvars.theme.gtk;
      icon-theme = myvars.theme.icon;
      cursor-theme = myvars.theme.cursor;

      monospace-font-name = "JetBrainsMono Nerd Font 10";
    };

    "org/gnome/desktop/wm/preferences" = {
      titlebar-font = "Sans Bold 10";
      theme = myvars.theme.gtk;
    };
  };
}
