{
  description = "nix-clawdbot: declarative Clawdbot packaging";

  nixConfig = {
    extra-substituters = [ "https://cache.garnix.io" ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-steipete-tools.url = "github:clawdbot/nix-steipete-tools";
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, nix-steipete-tools }:
    let
      overlay = import ./nix/overlay.nix;
      sourceInfoStable = import ./nix/sources/clawdbot-source.nix;
      sourceInfoCanary = import ./nix/sources/clawdbot-source-canary.nix;
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
        steipetePkgs = if nix-steipete-tools ? packages && builtins.hasAttr system nix-steipete-tools.packages
          then nix-steipete-tools.packages.${system}
          else {};
        packageSetStable = import ./nix/packages {
          pkgs = pkgs;
          sourceInfo = sourceInfoStable;
          steipetePkgs = steipetePkgs;
        };
        packageSetCanary = import ./nix/packages {
          pkgs = pkgs;
          sourceInfo = sourceInfoCanary;
          steipetePkgs = steipetePkgs;
        };
        dockerImages = import ./nix/images/clawdbot-docker.nix { inherit pkgs; };
        stableBundle = if pkgs.stdenv.hostPlatform.isDarwin
          then packageSetStable.clawdbot
          else packageSetStable.clawdbot-gateway;
        canaryBundle = if pkgs.stdenv.hostPlatform.isDarwin
          then packageSetCanary.clawdbot
          else packageSetCanary.clawdbot-gateway;
      in
      {
        packages = packageSetStable // {
          clawdbot-docker = dockerImages.image;
          clawdbot-docker-stream = dockerImages.stream;
          clawdbot-gateway-stable = packageSetStable.clawdbot-gateway;
          clawdbot-stable = stableBundle;
          clawdbot-gateway-canary = packageSetCanary.clawdbot-gateway;
          clawdbot-canary = canaryBundle;
          default = stableBundle;
        };

        apps = {
          clawdbot = flake-utils.lib.mkApp { drv = packageSetStable.clawdbot-gateway; };
        };

        checks = {
          gateway = packageSetStable.clawdbot-gateway;
          gateway-canary = packageSetCanary.clawdbot-gateway;
          gateway-tests = pkgs.callPackage ./nix/checks/clawdbot-gateway-tests.nix {
            sourceInfo = sourceInfoStable;
          };
          gateway-canary-tests = pkgs.callPackage ./nix/checks/clawdbot-gateway-tests.nix {
            sourceInfo = sourceInfoCanary;
          };
        };

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.git
            pkgs.nixfmt-rfc-style
            pkgs.nil
          ];
        };
      }
    ) // {
      overlays.default = overlay;
      homeManagerModules.clawdbot = import ./nix/modules/home-manager/clawdbot.nix;
      darwinModules.clawdbot = import ./nix/modules/darwin/clawdbot.nix;
    };
}
