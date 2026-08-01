{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;

    age = {
      keyFile = "/etc/sops/age/keys.txt";
    };

    secrets = {
      deepseek_api_key = {};   # ← 添加这一行
    };
  };
}