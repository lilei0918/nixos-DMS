{
  pkgs,
  inputs,
  ...
}: let
  # ElyOffice 官方 flake（github:ELY-Open-Source/ElyOffice）只输出
  # packages.x86_64-linux，没有 apps 输出；每个应用由 release 里的 AppImage
  # 经 appimageTools.wrapType2 包装（自动带 vulkan-loader / wayland / libxkbcommon）。
  #
  # 包名以 nix/release.json 为准：ely-doc / ely-table / ely-show / ely-pdf /
  # ely-mail / ely-tree / ely-mark。升级走 `nix flake update elyoffice`。
  elyoffice = inputs.elyoffice.packages.${pkgs.stdenv.hostPlatform.system};
in {
  home.packages = [
    elyoffice.ely-doc # Word（DOCX / ODT）
    elyoffice.ely-table # Excel（XLSX / ODS / CSV）
    elyoffice.ely-show # PPT（PPTX / ODP）
    elyoffice.ely-pdf # PDF 阅读 / 编辑 / OCR
    elyoffice.ely-mail # 邮件（IMAP / POP3 / SMTP）
    elyoffice.ely-tree # Git 图形客户端
    elyoffice.ely-mark # Markdown 编辑器
  ];
}
