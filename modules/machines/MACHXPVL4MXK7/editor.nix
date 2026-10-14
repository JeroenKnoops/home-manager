{
  pkgs,
  lib,
  config,
  ...
}:
{
  # MACHXPVL4MXK7 uses Jeroen's complete Neovim configuration rather than the
  # shared LazyVim bootstrap used by M1/M5/oryp6. Disable the shared nvim file
  # fragments and bootstrap activation from modules/common.nix, then manage the
  # whole config tree from this repository.
  home.file.".config/nvim/lua/plugins/opencode.lua".enable = lib.mkForce false;
  home.file.".config/nvim/lua/plugins/rust.lua".enable = lib.mkForce false;
  home.file.".config/nvim/lazyvim.json".enable = lib.mkForce false;
  home.activation.bootstrapNvim = lib.mkForce "";

  home.file.".config/nvim" = {
    source = lib.mkForce ../../../nvim/MACHXPVL4MXK7;
    recursive = true;
  };

  home.packages = with pkgs; [
    nil
    nixfmt
    nixpkgs-fmt
  ];

  programs.neovim = {
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withPython3 = lib.mkForce false;
    withRuby = lib.mkForce false;
  };
}
