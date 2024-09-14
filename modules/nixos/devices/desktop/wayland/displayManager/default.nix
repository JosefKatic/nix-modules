inputs: let
  gdm = import ./gdm.nix inputs;
in {imports = [gdm ./greetd.nix];}
