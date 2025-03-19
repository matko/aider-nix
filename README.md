# aider-nix: alternative nix packaging for aider-chat
This provides an alternative nix packaging for [aider-chat](https://aider.chat/). Although aider-chat is in nixpkgs, its packaging depends on the standard python packaging practices of nixpkgs, which means all dependencies must be part of nixpkgs already, in a compatible version for aider-chat to make use of.

This project instead packages aider-chat using [pyproject.nix](https://github.com/pyproject-nix/pyproject.nix) and [uv2nix](https://github.com/pyproject-nix/uv2nix), using my own [uvpart](https://github.com/matko/uvpart) flake-part wrappers to make this a little easier for myself. This is much more like what you'd get if you were to pipx-install, but still nixified, with all the reproducible-buildy goodness that comes with that.

As a result, it's easier, in principle, to keep this up to date with upstream aider-chat. Whether or not I'll actually keep it updated though will depend on my available time and whether or not I'll actually keep using aider.

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
