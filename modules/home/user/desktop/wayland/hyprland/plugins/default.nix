inputs: {
  imports = let
    hyprsplit = import ./hyprsplit inputs;
  in [hyprsplit];
}
