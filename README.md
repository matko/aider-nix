# aider-nix: alternative nix packaging for aider-chat
This provides an alternative nix packaging for [aider-chat](https://aider.chat/). Although aider-chat is in nixpkgs, its packaging depends on the standard python packaging practices of nixpkgs, which means all dependencies must be part of nixpkgs already, in a compatible version for aider-chat to make use of.

This project instead packages aider-chat using [pyproject.nix](https://github.com/pyproject-nix/pyproject.nix) and (uv2nix)[https://github.com/pyproject-nix/uv2nix], using my own [uvpart](https://github.com/matko/uvpart) flake-part wrappers to make this a little easier for myself. This is much more like what you'd get if you were to pipx-install, but still nixified, with all the reproducible-buildy goodness that comes with that.

As a result, it's easier, in principle, to keep this up to date with upstream aider-chat. Whether or not I'll actually keep it updated though will depend on my available time and whether or not I'll actually keep using aider.
