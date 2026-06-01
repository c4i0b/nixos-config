# Home-manager configuration template
#
# To use, uncomment homeConfigurations in flake.nix.
# This template uses stow for dotfile management alongside home-manager.
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  nixpkgs = {
    overlays = [
      inputs.self.overlays.additions
      inputs.self.overlays.modifications
      inputs.self.overlays.unstable-packages
    ];
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "caio";
    homeDirectory = "/home/caio";
    stateVersion = "25.11";
  };

  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      delta.enable = true;
    };
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
        set -g fish_key_bindings fish_default_key_bindings
      '';
      plugins = [
        {name = "tide"; src = pkgs.fishPlugins.tide.src;}
        {name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src;}
        {name = "done"; src = pkgs.fishPlugins.done.src;}
        {name = "sponge"; src = pkgs.fishPlugins.sponge.src;}
        {name = "autopair"; src = pkgs.fishPlugins.autopair.src;}
        {name = "replay"; src = pkgs.fishPlugins.replay.src;}
        {name = "z"; src = pkgs.fishPlugins.z.src;}
      ];
      shellAbbrs = {
        ls = "eza";
        ll = "eza -l";
        la = "eza -a";
        lla = "eza -la";
        lt = "eza --tree --level=2";
        cat = "bat";
        grep = "rg";
        find = "fd";
        ps = "procs";
        top = "btm";
      };
    };
    bat = {
      enable = true;
      config = {
        theme = "default";
        pager = "less -RF";
      };
    };
    eza = {
      enable = true;
      git = true;
      icons = true;
    };
    fzf = {
      enable = true;
      fishIntegration = true;
      tmuxIntegration = true;
    };
    tmux = {
      enable = true;
      clock24Hour = true;
      keyMode = "vi";
      mouse = true;
      baseIndex = 1;
      prefix = "C-a";
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "brave";
  };
}
