# 输入法：仅保留 fcitx5 + rime（默认英文输入）
#
# ⚠️ 说明：曾尝试"分程序输入法状态"（fcitx5-input-state 脚本按 app_id 强制中/英文），
# 实测不可靠（依赖 niri event-stream 的 WindowOpenedOrChanged 事件，但当前 niri 只发
# WindowFocusChanged；且 -o/-c 只切换激活状态、不切 rime/keyboard-us，行为混乱）。
# 已整体移除：所有程序默认英文输入（fcitx5 inactive），需要中文时手动切 rime。
# 环境变量（GTK/QT_IM_MODULE 等）与 rime 部署见 home/programs/rime.nix。
_: {}
