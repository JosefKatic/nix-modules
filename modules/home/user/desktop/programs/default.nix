inputs: {
  imports = let
    browsers = import ./browsers inputs;
  in [browsers ./editors ./emulators ./games ./media ./productivity];
}
