{
  hardware.graphics.enable32Bit = true;
  hardware.pulseaudio.support32Bit = true;
  imports = [./intel.nix ./amd.nix ./nvidia.nix];
}
