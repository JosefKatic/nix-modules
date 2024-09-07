{
  config,
  lib,
  ...
}: {
  home.persistence = {
    "/persist/home/${config.user.name}" = {
      allowOther = true;
      directories = [
        ".local/share/Steam"
        ".config/lutris"
        ".local/share/lutris"
        {
          # Use symlink, as games may be IO-heavy
          directory = "Games";
          method = "symlink";
        }
      ];
    };
  };
}
