{pkgs, ...}: {
  home.packages = [pkgs.v2ray pkgs.v2raya];

  systemd.user.services.v2raya = {
    Unit.Description = "v2rayA User Service";
    Service = {
      ExecStart = "${pkgs.v2raya}/bin/v2raya";
      Environment = [
        "V2RAYA_V2RAY_BIN=${pkgs.v2ray}/bin/v2ray"
        "V2RAYA_DATA_DIR=%h/.local/share/v2raya"
      ];
      Restart = "always";
    };
    Install.WantedBy = ["default.target"];
  };
}
