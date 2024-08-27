[
  {
    alias = "[Vrata] Otevřít celá";
    description = "";
    trigger = [
      {
        platform = "state";
        entity_id = [
          "input_button.cela_vrata"
        ];
      }
      {
        platform = "device";
        domain = "mqtt";
        device_id = "c822f8733a295e35d079407529b01d4f";
        type = "action";
        subtype = "single_left";
      }
    ];
    condition = [];

    action = [
      {
        service = "script.open_full_gate";
        data = {};
      }
    ];
    mode = "single";
  }
  {
    alias = "[Vrata] Otevřít polovinu";
    description = "";
    trigger = [
      {
        platform = "state";
        entity_id = [
          "input_button.polovina_vrat"
        ];
      }
      {
        platform = "device";
        domain = "mqtt";
        device_id = "c822f8733a295e35d079407529b01d4f";
        type = "action";
        subtype = "single_right";
      }
    ];
    condition = [];

    action = [
      {
        service = "script.open_half_gate";
        data = {};
      }
    ];
    mode = "single";
  }
]
