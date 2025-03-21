{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.user.terminal.shell.fish;
  inherit (lib) mkIf;
in {
  options.user.terminal.shell.fish = {
    enable = lib.mkEnableOption "Enable Fish";
  };
  config = mkIf cfg.enable {
    programs.fish = let
      packageNames = map (p: p.pname or p.name or null) config.home.packages;
      hasPackage = name: lib.any (x: x == name) packageNames;
      hasRipgrep = hasPackage "ripgrep";
      hasExa = hasPackage "eza";
      hasSpecialisationCli = hasPackage "specialisation";
      hasNeovim = config.programs.neovim.enable;
      hasEmacs = config.programs.emacs.enable;
      hasNeomutt = config.programs.neomutt.enable;
      hasKitty = config.programs.kitty.enable;
    in {
      enable = true;
      shellAbbrs = rec {
        jqless = "jq -C | less -r";

        n = "nix";
        nd = "nix develop -c $SHELL";
        ns = "nix shell";
        nsn = "nix shell nixpkgs#";
        nb = "nix build";
        nbn = "nix build nixpkgs#";
        nf = "nix flake";

        nr = "nixos-rebuild --flake .";
        nrs = "nixos-rebuild --flake . switch";
        snr = "nixos-rebuild --flake . --use-remote-sudo";
        snrs = "nixos-rebuild --flake . switch --use-remote-sudo";
        hm = "home-manager --flake .";
        hms = "home-manager --flake . switch";

        s = mkIf hasSpecialisationCli "specialisation";

        ls = mkIf hasExa "eza";
        exa = mkIf hasExa "eza";

        e = mkIf hasEmacs "emacsclient -t";

        vrg = mkIf (hasNeomutt && hasRipgrep) "nvimrg";
        vim = mkIf hasNeovim "nvim";
        vi = vim;
        v = vim;

        mutt = mkIf hasNeomutt "neomutt";
        m = mutt;

        cik = mkIf hasKitty "clone-in-kitty --type os-window";
        ck = cik;
      };
      shellAliases = {
        # Clear screen and scrollback
        clear = "printf '\\033[2J\\033[3J\\033[1;1H'";
      };
      functions = {
        # Disable greeting
        fish_greeting = "";
        # Grep using ripgrep and pass to nvim
        nvimrg = mkIf (hasNeomutt && hasRipgrep) "nvim -q (rg --vimgrep $argv | psub)";
      };
      interactiveShellInit =
        # Open command buffer in vim when alt+e is pressed
        ''
          bind \ee edit_command_buffer
        ''
        +
        # kitty integration
        ''
          set --global KITTY_INSTALLATION_DIR "${pkgs.kitty}/lib/kitty"
          set --global KITTY_SHELL_INTEGRATION enabled
          source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
          set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"
        ''
        +
        # Use vim bindings and cursors
        ''
          fish_vi_key_bindings
          set fish_cursor_default     block      blink
          set fish_cursor_insert      line       blink
          set fish_cursor_replace_one underscore blink
          set fish_cursor_visual      block
        ''
        +
        # Use terminal colors
        ''
          set -U fish_color_autosuggestion      brblack
          set -U fish_color_cancel              -r
          set -U fish_color_command             brgreen
          set -U fish_color_comment             brmagenta
          set -U fish_color_cwd                 green
          set -U fish_color_cwd_root            red
          set -U fish_color_end                 brmagenta
          set -U fish_color_error               brred
          set -U fish_color_escape              brcyan
          set -U fish_color_history_current     --bold
          set -U fish_color_host                normal
          set -U fish_color_match               --background=brblue
          set -U fish_color_normal              normal
          set -U fish_color_operator            cyan
          set -U fish_color_param               brblue
          set -U fish_color_quote               yellow
          set -U fish_color_redirection         bryellow
          set -U fish_color_search_match        'bryellow' '--background=brblack'
          set -U fish_color_selection           'white' '--bold' '--background=brblack'
          set -U fish_color_status              red
          set -U fish_color_user                brgreen
          set -U fish_color_valid_path          --underline
          set -U fish_pager_color_completion    normal
          set -U fish_pager_color_description   yellow
          set -U fish_pager_color_prefix        'white' '--bold' '--underline'
          set -U fish_pager_color_progress      'brwhite' '--background=cyan'
        '';
    };
  };
}
