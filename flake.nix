{
  description = "aider-nix";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uvpart = {
      url = "github:matko/uvpart";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.pyproject-build-systems.follows = "pyproject-build-systems";
    };
    uvpart-fixups = {
      url = "github:matko/uvpart-fixups";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      debug = true;
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.uvpart.flakeModule
        inputs.uvpart-fixups.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          self',
          pkgs,
          lib,
          config,
          ...
        }:
        {
          treefmt = {
            programs = {
              nixfmt.enable = true;
              black.enable = true;
              mdformat.enable = true;
              taplo.enable = true;
            };
            settings = {
              global.excludes = [
                ".envrc"
                ".python-version"
              ];
            };
          };
          uvpart = {
            python = pkgs.python312;
            workspaceRoot = ./.;
            publishPackage = false;
            publishApps = false;
          };

          packages =
            let
              package = pkgs.callPackage (
                {
                  withAllFeatures ? false,
                  withBrowser ? false,
                  withHelp ? false,
                  withPlaywright ? false,
                }:
                let
                  dependencyGroups =
                    if withAllFeatures then
                      "all"
                    else
                      (lib.optional withBrowser "browser")
                      ++ (lib.optional withHelp "help")
                      ++ (lib.optional withPlaywright "playwright");
                  environment = config.uvpart.outputs.environment.override { inherit dependencyGroups; };
                in
                pkgs.runCommand "aider-chat" { } ''
                  mkdir -p $out/bin
                  ln -s ${environment}/bin/aider $out/bin/aider
                ''
              ) { };
            in
            {
              aider-chat = package;
              aider-chat-full = package.override { withAllFeatures = true; };
              default = package;
              env = config.uvpart.outputs.environment;
            };

          apps = rec {
            aider = {
              type = "app";
              program = "${self'.packages.aider-chat}/bin/aider";
            };
            aider-full = {
              type = "app";
              program = "${self'.packages.aider-chat-full}/bin/aider";
            };
            default = aider;
          };
        };
      flake = {
        homeModules = {
          aider = import ./home-module.nix self.packages;
        };
      };
    };
}
