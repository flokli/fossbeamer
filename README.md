# Fossbeamer

WIP

This provides an application, as well as the tooling around a single full-screen
application running on displays at [wip.bar](https://wip.bar/).

## Development setup
[Nix] is used to pin dependencies, and [Direnv] to enter a development
environment automatically, from which you can use `cargo` to build the project,
taking care of all necessary system dependencies.

[Install Nix](https://nixos.org/download/) and
[hook direnv into your shell][hook-direnv] to get started.

## Nix+Rust
For "release builds" we use `crate2nix` to build Rust crates incrementally and
in isolation.

You can build fossbeamer for your current system using `nix-build nix -A
fossbeamer`, and then invoke it via `result/bin/fossbeamer`.

Whenever there's a change in the crate dependencies, run
`crate2nix generate --all-features` to re-generate `Cargo.nix`.

### Machine configuration
A NixOS machine config is provided in `nix/configuration.nix`.
It describes running fossbeamer in a wayland compositor, cage.

The system closure can be built with:
`nix-build nix -A machine.toplevel`

An SD-card image can be built with:
`nix-build nix -A machine.sdImage`

If you invoke the build from `x86_64-linux`, it'll cross-compile the sdcard
image. If you build on an `aarch64-linux` box, it'll natively compile. Both
works.

--
[wip.bar]: https://wip.bar
[Nix]: https://nixos.org
[Direnv]: https://direnv.net/docs/hook.html
[hook-direnv]: https://direnv.net/docs/hook.html
