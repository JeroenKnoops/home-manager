{
  pkgs,
  config,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    any-nix-shell
    fastfetch
    fzf
    tmux
    yazi
    zellij
    zsh
    zsh-syntax-highlighting
  ];

  home.sessionPath = [ "$HOME/.local/bin" ];

  home.sessionVariables = {
    DIRENV_LOG_FORMAT = "";
  };

  programs.starship.enable = lib.mkForce false;
  programs.starship.enableBashIntegration = lib.mkForce false;
  programs.starship.enableZshIntegration = lib.mkForce false;

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    settings = lib.importJSON ./custom.omp.json;
  };

  programs._1password-shell-plugins = {
    enable = true;
    plugins = with pkgs; [
      awscli2
      gh
    ];
  };

  programs.yazi = {
    enable = true;
    shellWrapperName = "y";
  };

  programs.pwdc.enable = true;
  programs.bat.enable = true;

  programs.eza = {
    enable = true;
    git = true;
  };

  programs.tmux.enable = true;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.nix-index-database.comma.enable = true;

  home.file.".local/bin/darwin-switch-machxpvl4mxk7" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      flake="${config.home.homeDirectory}/workspace/jeroenknoops/home-manager#darwinConfigurations.MACHXPVL4MXK7.system"

      # Build as the normal user so GitHub/1Password credentials from the login
      # session are available for private flake inputs. Only the profile switch
      # and activation run as root.
      system_config="$(nix build --no-link --print-out-paths "$flake" | tail -n 1)"

      sudo /bin/sh -c '
        set -eu
        system_config="$1"
        user="$2"

        export PATH="/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin"

        nix-env -p /nix/var/nix/profiles/system --set "$system_config"

        if [ -x "$system_config/activate-user" ] && ! grep -q "^# nix-darwin: deprecated$" "$system_config/activate-user"; then
          sudo --user="$user" --set-home -- "$system_config/activate-user"
        fi

        "$system_config/activate"
      ' sh "$system_config" "$USER"
    '';
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "gh"
        "wd"
        "history"
        "z"
      ];
    };
    shellAliases = {
      "@@" = "echo $(fc -ln -1) |& tail -1";
      "@@e" = "$($(fc -ln -1) |& tail -1)";
      ":q" = "exit";
      aerohelp = "cat ~/.config/aerohelp";
      drs = "darwin-switch-machxpvl4mxk7";
      gbrm = "git branch --merged | grep -v \"\\*\" | xargs -n 1 git branch -d";
      glog = "git log --pretty=format:'%C(yellow)%h%C(reset) %C(green)%ar%C(reset) %C(bold blue)%an%C(reset) %C(red)%d%C(reset) %s' --graph --abbrev-commit --decorate";
      t = "toilet -f mono12  -F metal $(date +'%T')";
      yhelp = "cat ~/.config/yabai/yhelp";
    };
    dirHashes = {
      BLURK = "/Users/Shared/PhilipsDev/synergy/synergy-base";
      JK = "${config.home.homeDirectory}/workspace/jeroenknoops";
      MGL = "/Users/Shared/PhilipsDev/synergy/synergy-mgl-base";
      PD = "/Users/Shared/PhilipsDev";
      PEG = config.home.homeDirectory;
      PF = "${config.home.homeDirectory}/workspace/philips-forks";
      PI = "${config.home.homeDirectory}/workspace/philips-internal";
      PS = "${config.home.homeDirectory}/workspace/philips-software";
      SA = "/Users/Shared/PhilipsDev/synergy/synergy-auth";
      SB = "/Users/Shared/PhilipsDev/synergy/synergy-base";
      SD = "/Users/Shared/PhilipsDev/synergy/synergy-doc";
      SYN = "/Users/Shared/PhilipsDev/synergy";
      SYB = "/Users/Shared/PhilipsDev/synergy/synergy-yocto-build";
      SYMS = "/Users/Shared/PhilipsDev/synergy/synergy-yocto-meta-synergy";
      WSB = "/Users/Shared/PhilipsDev/synergy/worktrees/synergy-base";
      WSYB = "/Users/Shared/PhilipsDev/synergy/worktrees/synergy-yocto-build";
      WSYMS = "/Users/Shared/PhilipsDev/synergy/worktrees/synergy-yocto-meta-synergy";
      crypt = "/Users/Shared/PhilipsDev/crypt";
    };
    initContent = lib.mkAfter ''
      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
      }

      toilet -f mono12 -F metal $(date +'%T')
      fastfetch
      any-nix-shell zsh --info-right | source /dev/stdin
      cat ~/.config/aerohelp
    '';
  };
}
