{ pkgs, ... }:
{
  home.packages = with pkgs; [
    aerospace
    maccy
    vscode
  ];

  home.file.".aerospace.toml".text = ''
    # Start AeroSpace at login
    start-at-login = true

    # Normalization settings
    enable-normalization-flatten-containers = true
    enable-normalization-opposite-orientation-for-nested-containers = true

    # Accordion layout settings
    accordion-padding = 30

    # Default root container settings
    default-root-container-layout = 'tiles'
    default-root-container-orientation = 'auto'

    # Mouse follows focus settings
    on-focused-monitor-changed = ['move-mouse monitor-lazy-center']
    on-focus-changed = ['move-mouse window-lazy-center']

    # Automatically unhide macOS hidden apps
    automatically-unhide-macos-hidden-apps = true

    # Key mapping preset
    [key-mapping]
    preset = 'qwerty'

    # Gaps settings
    [gaps]
    inner.horizontal = 6
    inner.vertical =   6
    outer.left =       6
    outer.bottom =     6
    outer.top =        6
    outer.right =      6

    # Main mode bindings
    [mode.main.binding]
    alt-shift-enter = 'exec-and-forget open -na alacritty'
    alt-shift-b = 'exec-and-forget open -a "Edge Browser"'

    alt-q = "close"
    alt-slash = 'layout tiles horizontal vertical'
    alt-comma = 'layout accordion horizontal vertical'
    alt-m = 'fullscreen'

    alt-h = 'focus left'
    alt-j = 'focus down'
    alt-k = 'focus up'
    alt-l = 'focus right'

    alt-shift-h = 'move left'
    alt-shift-j = 'move down'
    alt-shift-k = 'move up'
    alt-shift-l = 'move right'

    alt-shift-minus = 'resize smart -50'
    alt-shift-equal = 'resize smart +50'

    alt-1 = 'workspace 1'
    alt-2 = 'workspace 2'
    alt-3 = 'workspace 3'
    alt-4 = 'workspace 4'
    alt-5 = 'workspace 5'
    alt-6 = 'workspace 6'

    alt-shift-1 = 'move-node-to-workspace 1'
    alt-shift-2 = 'move-node-to-workspace 2'
    alt-shift-3 = 'move-node-to-workspace 3'
    alt-shift-4 = 'move-node-to-workspace 4'
    alt-shift-5 = 'move-node-to-workspace 5'

    alt-tab = 'workspace-back-and-forth'
    alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'

    alt-shift-semicolon = 'mode service'

    [mode.service.binding]
    esc = ['reload-config', 'mode main']
    r = ['flatten-workspace-tree', 'mode main']
    f = ['layout floating tiling', 'mode main']
    backspace = ['close-all-windows-but-current', 'mode main']
    alt-shift-h = ['join-with left', 'mode main']
    alt-shift-j = ['join-with down', 'mode main']
    alt-shift-k = ['join-with up', 'mode main']
    alt-shift-l = ['join-with right', 'mode main']
  '';

  home.file.".config/aerohelp".text = ''
    AeroSpace shortcuts
    -------------------
    alt-shift-enter  open Alacritty
    alt-shift-b      open Edge
    alt-q            close focused window
    alt-h/j/k/l      focus left/down/up/right
    alt-shift-h/j/k/l move window left/down/up/right
    alt-1..6         switch workspace
    alt-shift-1..5   move window to workspace
    alt-m            fullscreen
    alt-shift-;      service mode
    alt-slash        layout tiles horizontal vertical 
    alt-comma        layout accordion horizontal vertical
  '';

  home.file.".config/borders/bordersrc" = {
    executable = true;
    text = ''
      #!/usr/bin/env sh
      borders active_color=0xffe1e3e4 inactive_color=0xff494d64 width=6.0
      echo "borders started or updated"
    '';
  };
}
