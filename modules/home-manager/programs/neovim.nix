# Neovim. Import from home/caio.nix to enable.
{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };
}
