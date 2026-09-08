{
  description = "Supacode package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      supported_systems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      for_each_system = nixpkgs.lib.genAttrs supported_systems;
    in
    {
      packages = for_each_system (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          supacode = pkgs.stdenvNoCC.mkDerivation {
            pname = "supacode";
            version = "0.10.2";

            src = pkgs.fetchurl {
              url = "https://github.com/supabitapp/supacode/releases/download/v0.10.2/supacode.dmg";
              hash = "sha256-1plQlDdKzi4F/3T0vGrGdxLIUX4HmRprH6HSWTP0bFU=";
            };

            dontStrip = true;
            dontFixup = true;
            sourceRoot = ".";

            unpackPhase = ''
              runHook preUnpack

              mount_dir=$(TMPDIR=/tmp mktemp -d -t supacode-XXXXXXXX)
              cleanup() {
                /usr/bin/hdiutil detach "$mount_dir" -force >/dev/null 2>&1 || true
                rm -rf "$mount_dir"
              }
              trap cleanup EXIT

              /usr/bin/hdiutil attach -readonly -nobrowse -mountpoint "$mount_dir" "$src"
              cp -a "$mount_dir/Supacode.app" "$PWD/"

              runHook postUnpack
            '';

            installPhase = ''
              runHook preInstall

              mkdir -p "$out/Applications"
              cp -a Supacode.app "$out/Applications/"
              mkdir -p "$out/bin"
              ln -s "$out/Applications/Supacode.app/Contents/Resources/bin/supacode" "$out/bin/supacode"

              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "Native terminal coding agents command center";
              homepage = "https://supacode.sh";
              platforms = platforms.darwin;
            };
          };
        }
      );
    };
}
