{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
let
  src = inputs.oh-my-posh-src;
  version = "git-${src.shortRev or (builtins.substring 0 7 src.rev)}";

  oh-my-posh-git = pkgs.buildGo127Module {
    pname = "oh-my-posh";
    inherit version src;

    vendorHash = "sha256-RAKpIY8s9ON2NFBy08WTTQHVy/qT6q05F81eMrasmeI=";
    sourceRoot = "source/src";

    ldflags = [
      "-s"
      "-X github.com/jandedobbeleer/oh-my-posh/src/build.Version=${version}"
      "-X github.com/jandedobbeleer/oh-my-posh/src/build.Date=1970-01-01T00:00:00Z"
    ];

    tags = [
      "netgo"
      "osusergo"
      "static_build"
    ];

    postPatch = ''
      # These tests require internet access.
      rm config/migrate_glyphs_test.go cli/upgrade/notice_test.go segments/upgrade_test.go
    '';

    postInstall = ''
      mv $out/bin/{src,oh-my-posh}
      mkdir -p $out/share/oh-my-posh
      cp -r $src/themes $out/share/oh-my-posh/
    '';

    nativeInstallCheckInputs = [ pkgs.versionCheckHook ];
    doInstallCheck = true;

    meta = {
      description = "Prompt theme engine for any shell";
      mainProgram = "oh-my-posh";
      homepage = "https://ohmyposh.dev";
      changelog = "https://github.com/JanDeDobbeleer/oh-my-posh/commits/${src.rev}";
      license = lib.licenses.mit;
    };
  };
in
{
  config = lib.mkIf config.programs.oh-my-posh.enable {
    programs.oh-my-posh.package = oh-my-posh-git;
  };
}
