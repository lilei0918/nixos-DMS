{pkgs, ...}: let
  edgeTTSPkg = pkgs.python3Packages.edge-tts;
  speechd = pkgs.speechd;
in {
  home.packages = [
    edgeTTSPkg # Microsoft Edge 在线 TTS 服务（edge-tts / edge-playback 命令）
    speechd # speech-dispatcher 守护进程 + spd-say 客户端
  ];

  ############################################
  # speech-dispatcher 用户服务
  # Foliate 朗读（Read Aloud）通过 speech-dispatcher 调用 TTS。
  # 以用户级服务运行，mpv 才能访问本用户音频会话（PipeWire）。
  ############################################

  systemd.user.services.speech-dispatcher = {
    Unit = {
      Description = "Speech Dispatcher with Microsoft Edge TTS backend";
      After = ["graphical-session.target" "pipewire.target"];
      PartOf = ["graphical-session.target"];
    };

    Service = {
      Type = "simple";
      # -s：run-single，使用 systemd socket 激活传入的监听 fd
      #     （配合 speechd 包自带的 speech-dispatcher.socket，连接即拉起）；
      # -t 0：禁止空闲超时自动退出，首次激活后守护进程常驻。
      # 之前不带参数运行有两个问题：空闲 5s 即退出；socket 激活时未用传入的
      # fd 而去自建 socket，与 systemd socket 冲突导致守护进程起不来。
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %t/speech-dispatcher";
      ExecStart = "${speechd}/bin/speech-dispatcher -s -t 0";
      Restart = "on-failure";
      RestartSec = 3;
    };

    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  ############################################
  # speech-dispatcher 配置：加载 edge-tts generic 模块并设为默认
  # 用户配置位于 ~/.config/speech-dispatcher/，会覆盖系统默认配置。
  ############################################

  xdg.configFile."speech-dispatcher/speechd.conf".text = ''
    AddModule "edge-tts-generic" "sd_generic" "edge-tts-generic.conf"
    DefaultModule "edge-tts-generic"
  '';

  xdg.configFile."speech-dispatcher/modules/edge-tts-generic.conf".text = ''
    # generic 输出模块：文本经 edge-tts 转 MP3，再用 mpv 播放。
    # edge-tts 偶发 NoAudioReceived（微软服务端限流），加三重试 + 间隔。
    GenericExecuteSynth "export XDATA='$DATA'; TEXT=$(echo \"$XDATA\" | ${pkgs.gnused}/bin/sed -z 's/\\n/ /g'); for i in 1 2 3; do printf '%s' \"$TEXT\" | ${edgeTTSPkg}/bin/edge-tts --file - --voice $VOICE --write-media - && break; sleep 1; done | ${pkgs.mpv}/bin/mpv --no-terminal --keep-open=no -"

    # --- zh-CN female voices ---
    AddVoice "zh-CN" "FEMALE1" "zh-CN-XiaoxiaoNeural"
    AddVoice "zh-CN" "FEMALE2" "zh-CN-XiaoyiNeural"
    AddVoice "zh-CN" "FEMALE3" "zh-CN-XiaochenNeural"
    AddVoice "zh-CN" "FEMALE4" "zh-CN-XiaohanNeural"
    AddVoice "zh-CN" "FEMALE5" "zh-CN-XiaomengNeural"
    AddVoice "zh-CN" "FEMALE6" "zh-CN-XiaomoNeural"
    AddVoice "zh-CN" "FEMALE7" "zh-CN-XiaoshuangNeural"

    # --- zh-CN male voices ---
    AddVoice "zh-CN" "MALE1" "zh-CN-YunxiNeural"
    AddVoice "zh-CN" "MALE2" "zh-CN-YunyangNeural"
    AddVoice "zh-CN" "MALE3" "zh-CN-YunjianNeural"
    AddVoice "zh-CN" "MALE4" "zh-CN-YunfengNeural"

    # --- zh-TW traditional Chinese ---
    AddVoice "zh-TW" "FEMALE1" "zh-TW-HsiaoChenNeural"
    AddVoice "zh-TW" "FEMALE2" "zh-TW-HsiaoYuNeural"
    AddVoice "zh-TW" "MALE1" "zh-TW-YunJheNeural"

    # --- zh-HK Cantonese ---
    AddVoice "zh-HK" "FEMALE1" "zh-HK-HiuGaaiNeural"
    AddVoice "zh-HK" "FEMALE2" "zh-HK-HiuMaanNeural"
    AddVoice "zh-HK" "MALE1" "zh-HK-WanLungNeural"

    # --- en-US female voices ---
    AddVoice "en-US" "FEMALE1" "en-US-AriaNeural"
    AddVoice "en-US" "FEMALE2" "en-US-JennyNeural"
    AddVoice "en-US" "FEMALE3" "en-US-AvaMultilingualNeural"
    AddVoice "en-US" "FEMALE4" "en-US-EmmaMultilingualNeural"

    # --- en-US male voices ---
    AddVoice "en-US" "MALE1" "en-US-GuyNeural"
    AddVoice "en-US" "MALE2" "en-US-AndrewMultilingualNeural"
    AddVoice "en-US" "MALE3" "en-US-BrianMultilingualNeural"

    # Default voice (Xiaoxiao handles zh-CN + en mixed reading)
    DefaultVoice "zh-CN-XiaoxiaoNeural"
  '';
}
