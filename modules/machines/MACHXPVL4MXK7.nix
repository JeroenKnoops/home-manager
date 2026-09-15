{
  pkgs,
  lib,
  config,
  inputs,
  meta,
  ...
}:
let
  lolcommits = inputs.lolcommits-flake.packages.${meta.system}.default;
  hermes-agent = inputs.hermes-agent.packages.${meta.system}.default;
  herdr = inputs.herdr.packages.${meta.system}.default;
  supacode = inputs.supacode.packages.${meta.system}.supacode;
  kas-changes = builtins.getFlake "git+ssh://git@github.com/philips-internal/synergy-build-analyse?dir=kas-changes&rev=d4864aac6af04b0209de16bc3117e2b2bd0e76cc";
  binary-table = builtins.getFlake "git+ssh://git@github.com/philips-internal/synergy-build-analyse?dir=binary-table&rev=446faf6c237c2636814e67fc670bee20f6d98e08";
  group-git-logs = builtins.getFlake "git+ssh://git@github.com/philips-internal/synergy-build-analyse?dir=group-git-logs&rev=f6aaeefb6f082a5186d82e2c287f295be4aedb3a";
  dot-analyse-rs = builtins.getFlake "git+ssh://git@github.com/philips-internal/synergy-dotfile?rev=87677d758e4873d5151efaccdc111b9c5f308a38";
  github-uses = builtins.getFlake "git+ssh://git@github.com/philips-internal/synergy-build-analyse?dir=workflow-overview&rev=a9e8eff559f11eb0615485d0cecd24d1dc3bd2e6";
  tag-prs = builtins.getFlake "git+ssh://git@github.com/philips-internal/synergy-build-analyse?dir=tag-prs&rev=94b562e526c8400cb2680e926658e85e18f26ff4";
  pn-buildlist-tool = builtins.getFlake "git+ssh://git@github.com/philips-internal/synergy-build-analyse?dir=pn-buildlist-tool&rev=29f721b3602e0a51788ff6c7bfd258fe7c22e910";
  sslConfigDir = "${config.home.homeDirectory}/.config/ssl";

  # Read the upstream opencode.json from the pinned ai-coding Nix store path and
  # overlay both the M5-specific provider block and the athenaeum-mcp server
  # registration onto it. All other settings — model, compaction, permission —
  # are inherited from the upstream file so they can never drift out of sync with
  # the other machines.
  #
  # Merge order: upstream base ← Ollama provider ← athenaeum overlay ← cerebrum overlay.
  # The overlays touch disjoint top-level keys (provider.* vs mcp.* / tools.* /
  # agent.*), so there is no collision. This stays a single merge feeding the
  # single lib.mkForce write below — adding a second opencode.json definition
  # would conflict with that mkForce.
  #
  # lib.recursiveUpdate merges attrsets deeply but replaces lists wholesale. The
  # current schema has no lists at overlapping keys under provider / mcp / tools
  # / agent, so there is no collision risk. If that changes, revisit.
  aiCodingPkg = inputs.ai-coding.packages.${meta.system}.default;
  baseConfig = builtins.fromJSON (builtins.readFile "${aiCodingPkg}/opencode.json");
  modelOverlay = {
    agent = {
      brainstorm = { model = "github-copilot/claude-opus-4.8"; };
      spar       = { model = "github-copilot/claude-opus-4.8"; };
      teach      = { model = "github-copilot/claude-opus-4.8"; };
      plan       = { model = "github-copilot/claude-opus-4.8"; };
      explore    = { model = "github-copilot/claude-opus-4.8"; };
    };
  };
  m5OpencodeConfig = builtins.toJSON (lib.recursiveUpdate
    (lib.recursiveUpdate
      (lib.recursiveUpdate
        (lib.recursiveUpdate
          (lib.recursiveUpdate baseConfig {
            provider = {
              ollama = {
                npm = "@ai-sdk/openai-compatible";
                name = "Ollama (local)";
                options = {
                  baseURL = "http://localhost:11434/v1";
                };
                models = {
                  "gemma4:26b" = {
                    name = "Gemma 4 26B (local)";
                    limit = {
                      context = 32768;
                      output = 8192;
                    };
                  };
                };
              };
            };
          })
          config.programs.athenaeum.opencodeOverlay)
        config.programs.cerebrum.opencodeOverlay)
      config.programs.choragos.opencodeOverlay)
    modelOverlay);
in
{
  imports = [
    ../argus.nix
    ../pavo.nix
    ../athenaeum.nix
    ../cerebrum.nix
    ../choragos.nix
    ../claude.nix
    ../claude-mcp.nix
    ../dev-tools.nix
    inputs.pwdc.homeModules.${meta.system}.default
    inputs.nix-index-database.homeModules.default
    inputs._1password-shell-plugins.hmModules.default
  ];

  # MACHXPVL4MXK7 uses Jeroen's complete Neovim configuration rather than the
  # shared LazyVim bootstrap used by M1/M5/oryp6. Disable the shared nvim file
  # fragments and bootstrap activation from modules/common.nix, then manage the
  # whole config tree from this repository.
  home.file.".config/nvim/lua/plugins/opencode.lua".enable = lib.mkForce false;
  home.file.".config/nvim/lua/plugins/rust.lua".enable = lib.mkForce false;
  home.file.".config/nvim/lazyvim.json".enable = lib.mkForce false;
  home.activation.bootstrapNvim = lib.mkForce "";

  home.file.".config/nvim" = {
    source = lib.mkForce ../../nvim/MACHXPVL4MXK7;
    recursive = true;
  };

  home.file.".ssh/allowed_signers".text = ''
    jeroen.knoops@philips.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6uhyzK5oy4CHVGAadwbop1m2hOIQZWLuTqvLXG3PY+
  '';

  home.file.".aerospace.toml".text = ''
    # Start AeroSpace at login
    start-at-login = true

    # Normalization settings
    enable-normalization-flatten-containers = true
    enable-normalization-opposite-orientation-for-nested-containers = true

    # Accordion layout settings
    accordion-padding = 30

    # Default root container settings
    default-root-container-layout = 'tiles'
    default-root-container-orientation = 'auto'

    # Mouse follows focus settings
    on-focused-monitor-changed = ['move-mouse monitor-lazy-center']
    on-focus-changed = ['move-mouse window-lazy-center']

    # Automatically unhide macOS hidden apps
    automatically-unhide-macos-hidden-apps = true

    # Key mapping preset
    [key-mapping]
    preset = 'qwerty'

    # Gaps settings
    [gaps]
    inner.horizontal = 6
    inner.vertical =   6
    outer.left =       6
    outer.bottom =     6
    outer.top =        6
    outer.right =      6

    # Main mode bindings
    [mode.main.binding]
    alt-shift-enter = 'exec-and-forget open -na alacritty'
    alt-shift-b = 'exec-and-forget open -a "Edge Browser"'

    alt-q = "close"
    alt-slash = 'layout tiles horizontal vertical'
    alt-comma = 'layout accordion horizontal vertical'
    alt-m = 'fullscreen'

    alt-h = 'focus left'
    alt-j = 'focus down'
    alt-k = 'focus up'
    alt-l = 'focus right'

    alt-shift-h = 'move left'
    alt-shift-j = 'move down'
    alt-shift-k = 'move up'
    alt-shift-l = 'move right'

    alt-shift-minus = 'resize smart -50'
    alt-shift-equal = 'resize smart +50'

    alt-1 = 'workspace 1'
    alt-2 = 'workspace 2'
    alt-3 = 'workspace 3'
    alt-4 = 'workspace 4'
    alt-5 = 'workspace 5'
    alt-6 = 'workspace 6'

    alt-shift-1 = 'move-node-to-workspace 1'
    alt-shift-2 = 'move-node-to-workspace 2'
    alt-shift-3 = 'move-node-to-workspace 3'
    alt-shift-4 = 'move-node-to-workspace 4'
    alt-shift-5 = 'move-node-to-workspace 5'

    alt-tab = 'workspace-back-and-forth'
    alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'

    alt-shift-semicolon = 'mode service'

    [mode.service.binding]
    esc = ['reload-config', 'mode main']
    r = ['flatten-workspace-tree', 'mode main']
    f = ['layout floating tiling', 'mode main']
    backspace = ['close-all-windows-but-current', 'mode main']
    alt-shift-h = ['join-with left', 'mode main']
    alt-shift-j = ['join-with down', 'mode main']
    alt-shift-k = ['join-with up', 'mode main']
    alt-shift-l = ['join-with right', 'mode main']
  '';

  home.file.".config/aerohelp".text = ''
    AeroSpace shortcuts
    -------------------
    alt-shift-enter  open Alacritty
    alt-shift-b      open Edge
    alt-q            close focused window
    alt-h/j/k/l      focus left/down/up/right
    alt-shift-h/j/k/l move window left/down/up/right
    alt-1..6         switch workspace
    alt-shift-1..5   move window to workspace
    alt-m            fullscreen
    alt-shift-;      service mode
    alt-slash        layout tiles horizontal vertical 
    alt-comma        layout accordion horizontal vertical
  '';

  home.file.".config/borders/bordersrc" = {
    executable = true;
    text = ''
      #!/usr/bin/env sh
      borders active_color=0xffe1e3e4 inactive_color=0xff494d64 width=6.0
      echo "borders started or updated"
    '';
  };

  home.packages = with pkgs; [
    aerospace
    any-nix-shell
    awscli2
    cacert
    cargo
    chafa
    devbox
    direnv
    docker
    docker-buildx
    fd
    fh
    fly
    fzf
    git
    gnugrep
    graphviz
    gti
    hermes-agent
    herdr
    jq
    jujutsu
    kubo
    lolcommits
    maccy
    fastfetch
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.inconsolata
    nerd-fonts.jetbrains-mono
    nerd-fonts.roboto-mono
    libiconv
    nil
    nixfmt
    nodejs
    pi-coding-agent
    pipenv
    protobuf
    python313
    python313Packages.pip
    qemu
    ratchet
    ripgrep
    secretspec
    stack
    stow
    tmux
    (toilet.overrideAttrs (old: {
      preferLocalBuild = true;
      allowSubstitutes = false;
    }))
    typescript
    virtualenv
    vscode
    watch
    wget
    yazi
    yq-go
    zellij
    zld
    zsh
    zsh-syntax-highlighting

    kas-changes.packages.${meta.system}.default
    binary-table.packages.${meta.system}.default
    group-git-logs.packages.${meta.system}.default
    dot-analyse-rs.packages.${meta.system}.recipe-grep
    dot-analyse-rs.packages.${meta.system}.recipe-neighbour
    github-uses.packages.${meta.system}.default
    tag-prs.packages.${meta.system}.default
    pn-buildlist-tool.packages.${meta.system}.default
  ];

  home.sessionVariables = {
    DIRENV_LOG_FORMAT = "";
  };

  home.activation.installHerdrIntegrations = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$HOME/.config/opencode" "$HOME/.hermes"
    run ${herdr}/bin/herdr integration install opencode
    run ${herdr}/bin/herdr integration install hermes
  '';

  programs.starship.enable = lib.mkForce false;
  programs.starship.enableBashIntegration = lib.mkForce false;
  programs.starship.enableZshIntegration = lib.mkForce false;

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    settings = lib.importJSON ./MACHXPVL4MXK7/custom.omp.json;
  };

  programs.git = {
    enable = true;
    ignores = [
      ".DS_Store"
      ".idea"
      ".vs"
      ".vsc"
      ".vscode"
      "node_modules"
      "npm-debug.log"
    ];
    signing = {
      signByDefault = true;
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6uhyzK5oy4CHVGAadwbop1m2hOIQZWLuTqvLXG3PY+";
      signer = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };
    settings = {
      user = {
        email = lib.mkForce "jeroen.knoops@philips.com";
        name = lib.mkForce "Jeroen Knoops";
      };
      alias = {
        build-current = "for-each-ref --sort=-creatordate --format '%(refname:short) %(color:yellow)%(objectname:short) %(color:yellow)%(*objectname:short) %(color:blue)%(creatordate:iso) %(color:green)(%(creatordate:relative))%(color:reset)' --count=10 'refs/tags/synergy-yocto-build-current*'";
        build-release = "for-each-ref --sort=-creatordate --format '%(refname:short) %(color:yellow)%(objectname:short) %(color:yellow)%(*objectname:short) %(color:blue)%(creatordate:iso) %(color:green)(%(creatordate:relative))%(color:reset)' --count=10 'refs/tags/synergy-yocto-build-v*'";
        build-stable = "for-each-ref --sort=-creatordate --format '%(refname:short) %(color:yellow)%(objectname:short) %(color:yellow)%(*objectname:short) %(color:blue)%(creatordate:iso) %(color:green)(%(creatordate:relative))%(color:reset)' --count=10 'refs/tags/synergy-yocto-build-stable*'";
        ca = "commit --amend --no-edit";
        cm = "commit";
        fpl = "log --first-parent --oneline --decorate-refs-exclude=refs/tags --decorate-refs-exclude=refs/remotes --decorate-refs-exclude=refs/heads --decorate-refs-exclude=HEAD --pretty=format:'%Cgreen%ad%Creset %C(auto)%h%d %s %C(bold black)<%aN>%Creset' --date=format-local:'%Y-%m-%d %H:%M'";
        fplt = "log --first-parent --oneline --pretty=format:'%Cgreen%ad%Creset %C(auto)%h%d %s %C(bold black)<%aN>%Creset' --date=format-local:'%Y-%m-%d %H:%M'";
        pf = "push --force-with-lease";
        ps = "push";
        st = "status -sb";
      };
      core = {
        editor = "nvim";
        hooksPath = "${config.home.homeDirectory}/.local/share/lolcommits-git-hooks";
        pager = "";
      };
      gpg = {
        format = "ssh";
        ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      };
      init.defaultBranch = "main";
      pull = {
        commit = false;
        ff = false;
        rebase = true;
      };
      remote.origin.fetch = [
        "+refs/notes/*:refs/notes/*"
      ];
    };
  };

  home.sessionPath = [ "$HOME/.local/bin" ];

  home.file.".local/bin/git-find-build" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      if [ "$#" -lt 1 ]; then
        echo "Usage: git find-build key=value [key=value ...]" >&2
        echo "Example: git find-build target=qemuarm64 variant=vnv build_id addd9c90227a092fb7f1ef86a017552a67ab49ae" >&2
        exit 1
      fi

      NOTES_REF="refs/notes/commits"
      JQ_FILTER="true"

      for arg in "$@"; do
        if [[ "$arg" != *=* ]]; then
          echo "Invalid argument: $arg (expected key=value)" >&2
          exit 1
        fi
        key="''${arg%%=*}"
        value="''${arg#*=}"
        JQ_FILTER="$JQ_FILTER and .[\"$key\"] == \"$value\""
      done

      git notes --ref "$NOTES_REF" list | awk '{print $2}' | while read -r sha; do
        git notes --ref "$NOTES_REF" show "$sha" 2>/dev/null \
          | jq -e "$JQ_FILTER" >/dev/null \
          && echo "$sha"
      done
    '';
  };

  programs._1password-shell-plugins = {
    enable = true;
    plugins = with pkgs; [
      awscli2
      gh
    ];
  };

  programs.gh = {
    enable = true;
    settings = {
      aliases = {
        co = "pr checkout";
        explain = "copilot explain";
        pv = "pr view";
        suggest = "copilot suggest";
      };
      editor = "nvim";
      git_protocol = "ssh";
      pager = "cat";
      prompt = "enable";
    };
  };

  programs.neovim = {
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withPython3 = lib.mkForce false;
    withRuby = lib.mkForce false;
  };

  programs.yazi = {
    enable = true;
    shellWrapperName = "y";
  };

  programs.pwdc.enable = true;
  programs.bat.enable = true;

  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        signOff = true;
        branchLogCmd = "git log --first-parent --oneline --pretty=format:'%Cgreen%ad%Creset %C(auto)%h%d %s %C(bold black)<%aN>%Creset' --date=format-local:'%Y-%m-%d %H:%M'";
      };
    };
  };

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

  home.file.".local/share/lolcommits-git-hooks/post-commit" = {
    text = ''
      #!/bin/sh
      export LOLCOMMITS_DELAY=2.5
      export LOLCOMMITS_FORK=1
      lolcommits --capture
    '';
    executable = true;
  };

  home.sessionVariables = {
    AI_CODING_MODEL_PROFILE = "bedrock-sonnet";
  };

  # Override the shared opencode.json symlink (deployed by opencode.nix) with a
  # static file that merges the Ollama provider onto the upstream config. All
  # other settings (model, compaction, permission) are inherited from ai-coding.
  # NOTE: if ~/.config/opencode/opencode.json already exists as a plain file
  # (e.g. written by OpenCode before the first home-manager switch), remove it
  # before running home-manager switch:
  #   rm ~/.config/opencode/opencode.json
  home.file.".config/opencode/opencode.json".source = lib.mkForce
    (pkgs.writeText "m5-opencode.json" m5OpencodeConfig);

  # Create the mutable athenaeum data dir before any file writes. It is used as
  # the corpus-watcher unit's WorkingDirectory and log location below (the
  # athenaeum-mcp-server binary and athenaeum-ingest CLI self-locate their own
  # LanceDB store beneath this same path in-binary, so this mkdir no longer
  # needs to pre-create the /data subdirectory — the binary creates it lazily
  # on first write). The path comes from the athenaeum.nix option so it stays
  # in sync with what the watcher unit references. The old store under
  # ~/Projects/athenaeum-mcp is NOT migrated — re-ingest after switching.
  home.activation.createAthenaeumDataDir =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p "${config.programs.athenaeum.dataDir}"
      run mkdir -p "${config.programs.athenaeum.watchDir}"
    '';

  # Long-running corpus watcher (macOS). launchd keeps watchexec resident; it
  # invokes the short-lived athenaeum-ingest CLI on each debounced change.
  # ProgramArguments wraps watchCommand in `sh -lc` because launchd needs a list
  # and watchCommand is one string; -l (login shell) yields a sane PATH.
  # WorkingDirectory = dataDir is this unit's own cwd (for logs, below) — the
  # ingest subprocess itself no longer depends on cwd, since it self-locates its
  # LanceDB store in-binary. RunAtLoad + KeepAlive keep it running and relaunch
  # on exit. launchd has no journal, so stdout/stderr go to log files under
  # dataDir — kept out of watchDir so log writes cannot trigger the watcher.
  launchd.agents.athenaeum-watch = {
    enable = true;
    config = {
      ProgramArguments = [ "/bin/sh" "-lc" config.programs.athenaeum.watchCommand ];
      WorkingDirectory = config.programs.athenaeum.dataDir;
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "${config.programs.athenaeum.dataDir}/watch.log";
      StandardErrorPath = "${config.programs.athenaeum.dataDir}/watch.err.log";
    };
  };
}
