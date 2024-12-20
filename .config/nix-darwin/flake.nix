{
  description = "rhariady nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nixpkgs-firefox-darwin }:
  let
    configuration = { config, pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
	        pkgs.git
          pkgs.emacs
          pkgs.htop
          pkgs.slack
          pkgs.glab
          pkgs.discord
          pkgs.firefox-bin
          pkgs.tmux
          pkgs.alacritty
          pkgs.google-cloud-sdk
          pkgs.kubectl
          pkgs.kubectx
          pkgs.k9s
          pkgs.uv
          pkgs.ngrok
        ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "x86_64-darwin";
      nixpkgs.config.allowUnfree = true;
      # launchd.user.envVariables.PATH = config.environment.systemPath;

      nixpkgs.overlays = [ inputs.nixpkgs-firefox-darwin.overlay ];
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#NB-DKs-MacBook-Pro
    darwinConfigurations."NB-DKs-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."NB-DKs-MacBook-Pro".pkgs;
  };
}
