{ inputs, meta, ... }:
{
  imports = [
    ../dev-tools.nix
    inputs.pwdc.homeModules.${meta.system}.default
    inputs.nix-index-database.homeModules.default
    inputs._1password-shell-plugins.hmModules.default

    ../oh-my-posh-git.nix

    ./MACHXPVL4MXK7/ai.nix
    ./MACHXPVL4MXK7/desktop.nix
    ./MACHXPVL4MXK7/editor.nix
    ./MACHXPVL4MXK7/fonts.nix
    ./MACHXPVL4MXK7/git.nix
    ./MACHXPVL4MXK7/philips-internal.nix
    ./MACHXPVL4MXK7/sketchybar.nix
    ./MACHXPVL4MXK7/terminal.nix
    ./MACHXPVL4MXK7/tools.nix
  ];
}
