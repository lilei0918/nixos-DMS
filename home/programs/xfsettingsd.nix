{
  pkgs,
  ...
}: {

  systemd.user.services.xfsettingsd = {
    Unit = {
      Description = "XFCE Settings Daemon";
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.xfce.xfsettingsd}/bin/xfsettingsd";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

}