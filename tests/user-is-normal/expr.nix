{
  outputs,
  myvars,
  ...
}:
outputs.nixosConfigurations.legion.config.users.users.${myvars.username}.isNormalUser
