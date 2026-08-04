{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;

    age = {
      keyFile = "/etc/sops/age/keys.txt";
    };

    secrets = {
      deepseek_api_key = {};

      vaultwarden_admin_token = {};
    };
  };
}
