[
  {
    alias = "[Vysavač] Vypínač";
    description = "";
    trigger = {
      platform = "device";
      domain = "mqtt";
      device_id = "73548690249c35295436b8e681764e16";
      type = "action";
      subtype = "single";
    };
    condition = [];
    action = [
      {
        service = "switch.toggle";
        data = {};
        target = {
          entity_id = "switch.technicka_vysavac";
        };
      }
    ];
    mode = "single";
  }
]
