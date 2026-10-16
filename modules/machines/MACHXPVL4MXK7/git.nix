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
in
{
  home.packages = with pkgs; [
    git
    github-copilot-cli
    jujutsu
    lolcommits
  ];

  home.file.".ssh/allowed_signers".text = ''
    jeroen.knoops@philips.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6uhyzK5oy4CHVGAadwbop1m2hOIQZWLuTqvLXG3PY+
  '';

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

  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        signOff = true;
        branchLogCmd = "git log --first-parent --oneline --pretty=format:'%Cgreen%ad%Creset %C(auto)%h%d %s %C(bold black)<%aN>%Creset' --date=format-local:'%Y-%m-%d %H:%M'";
      };
    };
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
}
