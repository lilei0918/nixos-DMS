{
  config,
  pkgs,
  lib,
  ...
}:
{

  fonts = {

    # 开启 fontconfig
    fontDir.enable = true;

    # 字体包
    packages =
      with pkgs;
      [

        # 中文字体
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif

        # Emoji
        noto-fonts-color-emoji

        # 英文 UI
        inter

        # 编程字体
        fira-code

        # Nerd Fonts
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
        nerd-fonts.hack

      ]

      # Material Symbols
      ++ (lib.optionals (pkgs ? material-symbols) [
        pkgs.material-symbols
      ])

      ++ (lib.optionals (!(pkgs ? material-symbols) && (pkgs ? material-design-icons)) [
        pkgs.material-design-icons
      ]);

    fontconfig = {

      enable = true;

      defaultFonts = {

        # 普通 UI 字体
        sansSerif = [
          "Inter"
          "Noto Sans CJK SC"
        ];

        # 文档/阅读
        serif = [
          "Noto Serif CJK SC"
        ];

        # 终端/代码
        monospace = [
          "JetBrainsMono Nerd Font"
        ];

        # Emoji
        emoji = [
          "noto-fonts-color-emoji"
        ];

      };

    };

  };

}
