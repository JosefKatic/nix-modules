{
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;

    # see https://github.com/fufexan/nix-gaming/#pipewire-low-latency
    lowLatency.enable = true;
  };
}
