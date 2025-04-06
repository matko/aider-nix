packages:
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.aider;
  yamlFormat = pkgs.formats.yaml { };
in
{
  options.programs.aider = {
    enable = mkEnableOption "aider AI coding assistant";

    package = mkOption {
      type = types.package;
      default = packages.${pkgs.system}.aider-chat.override {
        withAllFeatures = cfg.enableAllFeatures;
        withBrowser = cfg.enableBrowser;
        withHelp = cfg.enableHelp;
        withPlaywright = cfg.enablePlaywright;
      };
      description = "The aider package to use.";
    };

    enableAllFeatures = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable all optional features.";
    };

    enableBrowser = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable browser support.";
    };

    enableHelp = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable help features.";
    };

    enablePlaywright = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable playwright support.";
    };

    settings = mkOption {
      type = yamlFormat.type;
      default = { };
      description = "Configuration for aider, written to ~/.aider.conf.yml";
      example = literalExpression ''
        {
          model = "gpt-4";
          edit_format = "diff";
          auto_commits = false;
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.file.".aider.conf.yml" = mkIf (cfg.settings != { }) {
      source = yamlFormat.generate "aider.conf.yml" cfg.settings;
    };
  };
}
