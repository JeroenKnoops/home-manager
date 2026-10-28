{
  lib,
  buildGoModule,
  src,
}:

buildGoModule {
  pname = "wentsketchy";
  version = "git-${src.shortRev or (builtins.substring 0 7 src.rev)}";

  inherit src;

  postPatch = ''
    substituteInPlace cmd/cli/config/settings/settings.go \
      --replace-fail 'BarBackgroundColor:  colors.WhiteA40,' 'BarBackgroundColor:  "0xff206169",'
  '';

  vendorHash = "sha256-ak9sSeL4m1NIaqVzVZBezQbkF/efhmmj/HQoNStq7vQ=";

  subPackages = [ "cmd/cli" ];

  postInstall = ''
    mv "$out/bin/cli" "$out/bin/wentsketchy"
  '';

  meta = {
    description = "SketchyBar building blocks with AeroSpace integration";
    homepage = "https://github.com/jeroenknoops/wentsketchy";
    mainProgram = "wentsketchy";
    platforms = lib.platforms.darwin;
  };
}
