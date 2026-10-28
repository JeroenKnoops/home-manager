{ pkgs, lib, ... }:
let
  configureWarpFont = pkgs.writeShellScript "configure-warp-font" ''
    set -e

    settings_file="$HOME/.warp/settings.toml"
    mkdir -p "$(dirname "$settings_file")"

    ${pkgs.python313}/bin/python3 - "$settings_file" <<'PY'
    import pathlib
    import sys

    path = pathlib.Path(sys.argv[1])
    section = "[appearance.text]"
    font_line = 'font_name = "Iosevka"'

    lines = path.read_text().splitlines() if path.exists() else []
    out = []
    in_section = False
    section_seen = False
    font_set = False

    for line in lines:
        stripped = line.strip()
        if stripped.startswith("[") and stripped.endswith("]"):
            if in_section and not font_set:
                out.append(font_line)
                font_set = True
            in_section = stripped == section
            section_seen = section_seen or in_section
            out.append(line)
            continue

        if in_section and stripped.startswith("font_name"):
            out.append(font_line)
            font_set = True
        else:
            out.append(line)

    if section_seen:
        if in_section and not font_set:
            out.append(font_line)
    else:
        if out and out[-1] != "":
            out.append("")
        out.extend([section, font_line])

    path.write_text("\n".join(out) + "\n")
    PY
  '';
in
{
  home.packages = with pkgs; [
    iosevka-bin
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.inconsolata
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    nerd-fonts.roboto-mono
  ];

  home.activation.configureWarpFont = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${configureWarpFont}
  '';
}
