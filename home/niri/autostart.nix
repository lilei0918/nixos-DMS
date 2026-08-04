{pkgs, ...}: {
  spawn-at-startup = [
    # 🖥️ XWayland 卫星服务
    {
      command = ["xwayland-satellite"];
    }
    # 🔐 权限管理
    {
      command = ["${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"];
    }

    # ⌨️ 输入法
    {
      command = [
        "fcitx5"
        "-d"
      ];
    }

    # 📋 剪贴板监听器
    {
      command = [
        "wl-paste"
        "--type"
        "text"
        "--watch"
        "cliphist"
        "store"
      ];
    }

    # 🔵 蓝牙托盘程序
    {
      command = ["blueman-applet"];
    }

    # 📌 新增：剪贴板持久化（解决关闭源程序后无法粘贴的问题）
    {
      command = [
        "sh"
        "-c"
        ''
          sleep 2
          wl-clip-persist --clipboard regular
        ''
      ];
    }

    # 📌 新增：延迟启动的应用（如果你需要）
    # {
    #   command = [ "bash" "-c" "sleep 6 && obsidian" ];
    # }
    {
      command = [
        "bash"
        "-c"
        "sleep 10 && exec qq"
      ];
    }
    # {
    #   command = [ "bash" "-c" "sleep 6 && /path/to/siyuan" ];
    # }
  ];
}
