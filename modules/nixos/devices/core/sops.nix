{
  inputs,
  lib,
  config,
  ...
}: let
  isEd25519 = k: k.type == "ed25519";
  getKeyPath = k: k.path;
  keys = builtins.filter isEd25519 config.services.openssh.hostKeys;
  hasOptinPersistence = config.environment.persistence ? "/persist";
in {
  sops = {
    age = {
      sshKeyPaths = map getKeyPath keys;
    };
  };
}
