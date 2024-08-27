{
  config,
  lib,
  ...
}: {
  home.persistence = {
    "/persist/home/${config.user.name}" = {
      allowOther = true;
      directories = [
        {
          # Use symlink, as games may be IO-heavy
          directory = "Games";
          method = "symlink";
        }
      ];
    };
  };
}
