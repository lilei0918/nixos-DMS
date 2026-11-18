{config, ...}: {
  # Luciole 接管默认文件管理器（Thunar 包保留，见 thunar.nix）
  xdg.mimeApps.defaultApplications = {
    "inode/directory" = "dev.noctalia.luciole.desktop";
  };

  # 让应用"在文件管理器中显示"（org.freedesktop.FileManager1）走 Luciole：
  # 复制其服务文件到用户级 D-Bus 目录（用户目录优先于系统目录，覆盖 thunar）。
  home.file.".local/share/dbus-1/services/org.freedesktop.FileManager1.service" = {
    source = "${config.programs.luciole.package}/share/dbus-1/services/dev.noctalia.luciole.FileManager1.service";
  };
}
