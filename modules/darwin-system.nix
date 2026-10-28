{
  pkgs,
  meta,
  inputs,
  ...
}:
let
  wentsketchy = pkgs.callPackage ../packages/wentsketchy.nix {
    src = inputs.wentsketchy;
  };
in
{
  # Keep the existing Nix installation/daemon managed by its installer rather than
  # having nix-darwin take it over. This also keeps the profile compatible with
  # Determinate Nix installations.
  nix.enable = false;

  # Required by nix-darwin; set once for this host and do not bump casually.
  system = {
    primaryUser = meta.username;
    stateVersion = 6;
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  services.sketchybar = {
    enable = true;
    package = pkgs.sketchybar;
    extraPackages = with pkgs; [
      aerospace
      wentsketchy
    ];
    config = ''
      #!/usr/bin/env sh
      export CONFIG_DIR="${meta.homeDirectory}/.config/sketchybar"
      export PATH="${
        pkgs.lib.makeBinPath [
          pkgs.aerospace
          pkgs.sketchybar
        ]
      }:$PATH"

      cd "$CONFIG_DIR"
      exec "${meta.homeDirectory}/.config/sketchybar/sketchybarrc"
    '';
  };
}
