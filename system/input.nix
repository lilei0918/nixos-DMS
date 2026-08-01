{pkgs, ...}: {
  i18n.inputMethod = {
    enable = true;

    type = "fcitx5";

    fcitx5 = {
      waylandFrontend = true;

      addons = with pkgs; [
        fcitx5-rime

        fcitx5-gtk

        fcitx5-material-color

        qt6Packages.fcitx5-chinese-addons

        qt6Packages.fcitx5-configtool
      ];
    };
  };
}
