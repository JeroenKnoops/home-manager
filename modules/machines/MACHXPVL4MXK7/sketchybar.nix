{
  inputs,
  pkgs,
  ...
}:
let
  wentsketchy = pkgs.callPackage ../../../packages/wentsketchy.nix {
    src = inputs.wentsketchy;
  };
in
{
  home.packages = with pkgs; [
    sketchybar-app-font
    wentsketchy
  ];

  home.file.".local/bin/wentsketchy" = {
    source = "${wentsketchy}/bin/wentsketchy";
    executable = true;
  };

  home.file.".sketchybarrc" = {
    executable = true;
    text = ''
      #!/usr/bin/env sh
      cd "$HOME/.config/sketchybar"
      exec "$HOME/.local/bin/wentsketchy" start
    '';
  };

  home.file.".config/sketchybar/sketchybarrc" = {
    executable = true;
    text = ''
      #!/usr/bin/env sh
      cd "$HOME/.config/sketchybar"
      exec "$HOME/.local/bin/wentsketchy" start
    '';
  };

  home.file.".config/sketchybar/config.yaml".text = ''
    ---
    left:
      - main_icon
      - aerospace
    right_notch:
      - front_app
    right:
      - cpu
      - battery
      - calendar
  '';
}
