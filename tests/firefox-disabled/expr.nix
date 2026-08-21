{outputs, ...}:
# Firefox 当前未启用（hosts/legion/home.nix 中 firefox.nix 的 import 被注释）
outputs.nixosConfigurations.legion.config.programs.firefox.enable
