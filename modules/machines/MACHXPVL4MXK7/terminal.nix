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
