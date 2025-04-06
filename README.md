# aider-nix: alternative nix packaging for aider-chat

This provides an alternative nix packaging for [aider-chat](https://aider.chat/). Although aider-chat is in nixpkgs, its packaging depends on the standard python packaging practices of nixpkgs, which means all dependencies must be part of nixpkgs already, in a compatible version for aider-chat to make use of.

This project instead packages aider-chat using [pyproject.nix](https://github.com/pyproject-nix/pyproject.nix) and [uv2nix](https://github.com/pyproject-nix/uv2nix), using my own [uvpart](https://github.com/matko/uvpart) flake-part wrappers to make this a little easier for myself. This is much more like what you'd get if you were to pipx-install, but still nixified, with all the reproducible-buildy goodness that comes with that.

As a result, it's easier, in principle, to keep this up to date with upstream aider-chat. Whether or not I'll actually keep it updated though will depend on my available time and whether or not I'll actually keep using aider.

Another big advantage is that unlike the version in nixpkgs, this packaging of aider-chat is able to run python code within a virtual environment. The nixpkgs packaging unfortunately wraps aider-chat in such a way that if aider-chat itself runs python, it'll use the python binary that aider-chat itself uses, which completely ignores the virtual environment you may have started aider-chat in. As a result, running any scripts or tests through aider-chat will likely result in missing packages errors. The version from aider-nix on the other hand doesn't hide the virtual environment, and therefore is able to call python project code without any issues.

## Try it out

Assuming you have nix installed, and have enabled the `nix-command` and `flakes` experimental features, you should just be able to run

```bash
nix run github:matko/aider-nix
```

## Install

This project exposes aider-chat as a flake package. If you use nix profiles you can install it with

```bash
nix profile install github:matko/aider-nix
```

If you use a flake-based home-manager or system configuration, You can add this flake as an extra input, and get `aider-chat` from the exposed package set.

## Home Manager Module

This project includes a Home Manager module that allows you to easily install aider and configure it with a `.aider.conf.yml` file in your home directory.

### Usage

Add the flake to your Home Manager configuration:

```nix
{
  inputs = {
    # ... your other inputs
    aider-nix.url = "github:matko/aider-nix";
  };

  outputs = { self, nixpkgs, home-manager, aider-nix, ... }: {
    # ... your other outputs
    homeConfigurations = {
      "yourusername" = home-manager.lib.homeManagerConfiguration {
        # ... your other configuration
        modules = [
          aider-nix.homeManagerModules.default
          {
            programs.aider = {
              enable = true;
              settings = {
                # Your aider configuration
                model = "gpt-4";
                edit_format = "diff";
                auto_commits = false;
                # Add any other settings you want in your .aider.conf.yml
              };
            };
          }
        ];
      };
    };
  };
}
```

### Configuration Options

The module provides the following options:

- `enable`: Boolean to enable/disable aider (default: false)
- `package`: The aider package to use (defaults to the package in this project, but you can override this with pkgs.aider-chat or similar if you like)
- `settings`: Configuration for aider, written to ~/.aider.conf.yml

### Example Configuration

Here's an example of a more complete configuration:

```nix
programs.aider = {
  enable = true;
  settings = {
    model = "gpt-4-turbo";
    temperature = 0.0;
    edit_format = "simple";
    auto_commits = false;
    context_window = 32000;
    max_tokens = 4000;
    openai_api_base = "https://api.openai.com/v1";
    # You can add your API key here, but it's better to use environment variables.
    # IMPORTANT: secrets included here will go unencrypted into your nix store!!
    # openai_api_key = "your-api-key";
  };
};
```

Note: It's generally better to set your API key as an environment variable rather than in the configuration file. Any secrets included here (even if commented out) will go unencrypted into your nix store, and they'll be readable to any user on your system or any system where the resulting nix closure gets copied to.
