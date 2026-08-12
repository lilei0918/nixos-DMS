{
  outputs,
  myvars,
  ...
}:
outputs.nixosConfigurations.legion.config.home-manager.users.${myvars.username}.home.homeDirectory
