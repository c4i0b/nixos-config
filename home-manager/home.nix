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
      lfs.enable = true;
    };
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
        set -g fish_key_bindings fish_default_key_bindings
        fish_config theme choose "Rosé Pine Moon"
      '';
      plugins = [
        {
          name = "tide";
          src = pkgs.fishPlugins.tide.src;
        }
        {
          name = "fzf-fish";
          src = pkgs.fishPlugins.fzf-fish.src;
        }
        {
          name = "done";
          src = pkgs.fishPlugins.done.src;
        }
        {
          name = "sponge";
          src = pkgs.fishPlugins.sponge.src;
        }
        {
          name = "autopair";
          src = pkgs.fishPlugins.autopair.src;
        }
        {
          name = "replay";
          src = pkgs.fishPlugins.replay.src;
        }
        {
          name = "z";
          src = pkgs.fishPlugins.z.src;
        }
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
        vim = "nvim";
        vi = "nvim";
      };
      shellAliases = {
        update = "sudo nixos-rebuild switch --flake /home/caio/Projects/nix#Fedora";
        update-home = "home-manager switch --flake /home/caio/Projects/nix#caio@Fedora";
        nix-cleanup = "sudo nix-collect-garbage -d && nix store gc --dead";
        gc = "sudo nix-collect-garbage -d";
      };
      functions = {
        fish_prompt = {
          description = "Write out the prompt";
          body = builtins.readFile (
            pkgs.runCommandLocal "fish_prompt.fish" {} ''
              cat ${pkgs.fishPlugins.tide.src}/functions/fish_prompt.fish
            ''
          );
        };
      };
    };
    bat = {
      enable = true;
      config = {
        theme = "Rosé Pine Moon";
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
      defaultOptions = [
        "--layout=reverse"
        "--info=inline"
        "--height=80%"
      ];
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
      changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
    };
    tmux = {
      enable = true;
      clock24Hour = true;
      keyMode = "vi";
      mouse = true;
      baseIndex = 1;
      prefix = "C-a";
      extraConfig = ''
        set -g mouse on
        set -g status-position top
        set -g renumber-windows on
        set -g set-clipboard on
        bind v split-window -h -c "#{pane_current_path}"
        bind b split-window -v -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"
      '';
    };
    starship = {
      enable = true;
      enableFishIntegration = true;
    };
    btop = {
      enable = true;
    };
    chromium = {
      enable = true;
    };
  };

  home.packages = with pkgs; [
    unstablePkgs.neovim
    unstablePkgs.lazygit
    nodejs
    python3
    pipx
    nil
    nixfmt-rfc-style
   alejandra
    gh
    glow
    jq
    yq
    act
    docker-compose
    distrobox
    boxes
    charmbracelet.vhs
    yazi
    zoxide
    procs
    dogdns
    hexyl
    hyperfine
    jc
    jless
    mdcat
    ripgrep-all
    sd
    xh
  ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = "Adwaita";
      icon-theme = "Tela";
      cursor-theme = "Adwaita";
      font-name = "CaskaydiaCove Nerd Font 11";
      document-font-name = "Adwaita Sans 12";
      monospace-font-name = "Adwaita Mono 11";
      clock-format = "24h";
      show-battery-percentage = true;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-schedule-automatic = false;
      night-light-schedule-from = 20.0;
      night-light-schedule-to = 6.0;
      night-light-temperature = 4000;
    };

    "org/gnome/desktop/background" = {
      picture-uri = "file:///usr/share/backgrounds/default";
      picture-uri-dark = "file:///usr/share/backgrounds/default-dark";
    };

    "org/gnome/desktop/screensaver" = {
      lock-enabled = true;
      lock-delay = 300;
    };

    "org/gnome/desktop/sound" = {
      event-sounds = true;
      feedback-sounds = false;
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita";
    };
    iconTheme = {
      name = "Tela";
    };
    font = {
      name = "CaskaydiaCove Nerd Font";
      size = 11;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "brave";
    TERM = "xterm-256color";
  };

  programs.starship.settings = {
    add_newline = false;
    character = {
      success_symbol = "[>](bold green)";
      error_symbol = "[>](bold red)";
    };
    directory = {
      truncation_length = 3;
      truncate_to_repo = true;
    };
    git_branch.symbol = " ";
  };
}
