{
  config,
  pkgs,
  inputs,
  ...
}: {
  environment.variables = {
    XCURSOR_THEME = "Bibata-Original-Ice";
    XCURSOR_SIZE = "14";
    QT_QPA_PLATFORM = "wayland";
  };
}
