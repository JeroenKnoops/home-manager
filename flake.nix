{
  description = "Home Manager configuration of vansweej";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl.url = "github:guibou/nixGL";
    pwdc.url = "github:JeroenKnoops/pwdc";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lolcommits-flake.url = "github:JeroenKnoops/lolcommits-flake";
    _1password-shell-plugins.url = "github:1Password/shell-plugins";
    supacode = {
      url = "path:./common/supacode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ai-coding = {
      url = "github:vansweej/ai-coding";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    athenaeum = {
      url = "github:vansweej/athenaeum-mcp";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    cerebrum = {
      url = "github:vansweej/cerebrum-mcp";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    choragos = {
      url = "github:vansweej/choragos";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    agora = {
      url = "github:vansweej/agora";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    argus = {
      url = "github:vansweej/argus";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    pavo = {
      url = "github:vansweej/pavo";
      flake = false;
    };
    oh-my-posh-src = {
      url = "github:JanDeDobbeleer/oh-my-posh";
      flake = false;
    };
    hermes-agent.url = "github:NousResearch/hermes-agent";
    herdr = {
      url = "github:herdrdev/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    wentsketchy = {
      url = "github:lucax88x/wentsketchy";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      nixgl,
      ...
    }@inputs:
    let
      mkPkgs =
        meta:
        let
          isDarwin = builtins.match ".*-darwin" meta.system != null;
        in
        import nixpkgs {
          system = meta.system;
          config.allowUnfree = true;
          config.cudaSupport = meta.cudaSupport;
          # nixGL is Linux-only; applying its overlay on Darwin causes eval errors.
          overlays = if isDarwin then [ ] else [ nixgl.overlay ];
        };

      mkHomeModules =
        meta: machineModulePath:
        let
          isDarwin = builtins.match ".*-darwin" meta.system != null;
        in
        [
          # Per-machine identity — derived from the metadata file so no module
          # needs to hardcode username, homeDirectory, or stateVersion.
          {
            home.username = meta.username;
            home.homeDirectory = meta.homeDirectory;
            home.stateVersion = meta.stateVersion;
          }

          # Universal configuration shared by all machines.
          ./modules/common.nix
        ]
        # Platform module: Linux gets nixGL + .desktop; Darwin gets macOS defaults.
        ++ (if isDarwin then [ ./modules/darwin.nix ] else [ ./modules/linux.nix ])
        # Machine-specific module: Docker/systemd on oryp6, local models on M5, etc.
        ++ [ machineModulePath ];

      mkSpecialArgs = meta: {
        inherit inputs meta;
        pwdcPackage = inputs.pwdc.packages.${meta.system}.default;
      };

      # Build a standalone homeManagerConfiguration for a given machine.
      mkHome =
        machineMetaPath: machineModulePath:
        let
          meta = import machineMetaPath;
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs meta;
          extraSpecialArgs = mkSpecialArgs meta;
          modules = mkHomeModules meta machineModulePath;
        };

      # Build a nix-darwin system that wraps the same Home Manager modules.
      mkDarwin =
        machineMetaPath: machineModulePath:
        let
          meta = import machineMetaPath;
        in
        nix-darwin.lib.darwinSystem {
          system = meta.system;
          specialArgs = mkSpecialArgs meta;
          modules = [
            ./modules/darwin-system.nix
            home-manager.darwinModules.home-manager
            {
              nixpkgs = {
                hostPlatform = meta.system;
                config.allowUnfree = true;
                config.cudaSupport = meta.cudaSupport;
              };

              users.users.${meta.username} = {
                name = meta.username;
                home = meta.homeDirectory;
              };

              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = mkSpecialArgs meta;
                users.${meta.username}.imports = mkHomeModules meta machineModulePath;
              };
            }
          ];
        };

    in
    {
      homeConfigurations."oryp6" = mkHome ./machines/oryp6.nix ./modules/machines/oryp6.nix;
      homeConfigurations."M1" = mkHome ./machines/m1.nix ./modules/machines/m1.nix;
      homeConfigurations."M5" = mkHome ./machines/m5.nix ./modules/machines/m5.nix;
      homeConfigurations."parallels-ubuntu" =
        mkHome ./machines/parallels-ubuntu.nix ./modules/machines/parallels-ubuntu.nix;
      homeConfigurations."MACHXPVL4MXK7" =
        mkHome ./machines/MACHXPVL4MXK7.nix ./modules/machines/MACHXPVL4MXK7.nix;

      darwinConfigurations."MACHXPVL4MXK7" =
        mkDarwin ./machines/MACHXPVL4MXK7.nix ./modules/machines/MACHXPVL4MXK7.nix;
    };
}
