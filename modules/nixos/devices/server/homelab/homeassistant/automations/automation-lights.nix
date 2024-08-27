[
  {
    alias = "[Josef] Světlo";
    description = "";
    trigger = [
      {
        platform = "device";
        domain = "mqtt";
        device_id = "862f040a39c4c118bb16ecabfe60ec22";
        type = "action";
        subtype = "single";
      }
      {
        platform = "device";
        domain = "mqtt";
        device_id = "a8662cf324aefaff8706de9c4cb1af1a";
        type = "action";
        subtype = "single_right";
      }
    ];
    condition = [];
    action = [
      {
        service = "light.toggle";
        data = {};
        target = {
          entity_id = "light.josef_svetlo";
        };
      }
    ];
    mode = "single";
  }
]
