{
  open_full_gate = {
    alias = "[Vrata] Otevřít celá";
    sequence = [
      {
        service = "remote.send_command";
        data = {
          num_repeats = 1;
          delay_secs = 0.4;
          hold_secs = 0;
          device = "gate";
          command = "open_full";
        };
        target = {
          entity_id = "remote.rm4_pro";
        };
      }
    ];
    mode = "single";
    icon = "mdi:gate-open";
  };
  open_half_gate = {
    alias = "[Vrata] Otevřít polovinu";
    sequence = [
      {
        service = "remote.send_command";
        data = {
          num_repeats = 1;
          delay_secs = 0.4;
          hold_secs = 0;
          device = "gate";
          command = "open_half";
        };
        target = {
          entity_id = "remote.rm4_pro";
        };
      }
    ];
    mode = "single";
    icon = "mdi:gate-open";
  };
}
