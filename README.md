This is a boilerplate for someone wanting to build a Nix-Darwin flake.

This is intended to be used as a starting point, so it would make most sense, to create a new template from this repository and modify it to fit your needs.

## Requirements:

- Relatively modern MacOS version
- Nix installed: https://nixos.org/download.html#nix-install-macos
- Nix-Darwin installed: https://github.com/LnL7/nix-darwin#install

## Quickstart:

Assuming you want to build the `m2-macbook-air` output, you'd use these commands:

```
git clone https://github.com/heywoodlh/nix-darwin-flake
cd nix-darwin-flake
darwin-rebuild switch --flake .#m2-macbook-air
``` 

## What is a Nix Flake and how does it work?

A Nix flake is a self-contained Nix configuration. In this case, we're building [Nix-Darwin](http://daiderd.com/nix-darwin/) configurations, which allow a user to configure MacOS.

The [flake.nix](./flake.nix) file consists of two parts, inputs and outputs. Inputs are resources that will be utilized by the outputs. Outputs are build targets -- in this case, our outputs are MacOS builds. This Flake is designed with the intention that each MacOS you manage should have its own output.

## The anatomy of this Flake

### Inputs

Inputs are resources that will be utilized by the build. In this Flake, we're using the following external resources to build the configuration for the machine:

- `nixpkgs` for Nix packages: https://github.com/nixos/nixpkgs
- `nix-darwin` for managing MacOS: https://github.com/LnL7/nix-darwin
- `home-manager` for managing various configurations, such as Firefox preferences and plugins: https://github.com/nix-community/home-manager
- `nur` for downloading community packages, specifically for downloading Firefox plugins: https://github.com/nix-community/NUR

This snippet shows all of the inputs in the Flake:

```
...
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
  };
...
```

### Outputs (build targets)

Each MacOS build is an output in [flake.nix](./flake.nix). This repository comes with two outputs/MacOS builds:

- `m2-macbook-air`: an example build for settings required for an M2 Macbook Air
- `intel-macbook`: an example build for settings required for an Intel Macbook

Each output/MacOS build has a corresponding file in [./hosts](./hosts) where configurations should be imported from the [./roles](./roles) directory. Any specific configuration for a particular machine should live in its file in the [./hosts](./hosts) directory.

This snippet from `flake.nix` shows the Flake's output named `m2-macbook-air` and its corresponding config file `./hosts/m2-macbook-air.nix` being imported:

```
  ...
  outputs = inputs@{ self, nixpkgs, darwin, home-manager, jovian-nixos, nur, ... }: {
    darwinConfigurations = {
      # m1-macbook 
      "m2-macbook-air" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = inputs;
        modules = [ ./hosts/m2-macbook-air.nix ];
      };
  ...
```

In `./hosts/m2-macbook-air.nix`, we can define which configurations we want to select from the `[./roles](./roles)` directory, for example:

```
...
  imports = [
    ../roles/m1.nix
    ../roles/defaults.nix
    ../roles/brew.nix
    ../roles/yabai.nix
    ../roles/network.nix
    ../roles/users/${username}.nix
    ../roles/home-manager/settings.nix
  ];
...
```

### Roles:

Currently, the Flake contains the following example configurations that are in the [./roles](./roles) directory (listed in no particular order):

- User settings: [./roles/users](./roles/users)
- Configuring preferred MacOS settings: [./roles/defaults.nix](./roles/defaults.nix)
- Homebrew packages and settings:  [./roles/brew.nix](./roles/brew.nix)
- Some network settings:  [./roles/network.nix](./roles/network.nix)
- Yabai and SKHD for tiling windows:  [./roles/yabai.nix](./roles/yabai.nix)
- Some settings for M1/M2 devices: [./roles/m1.nix](./roles/m1.nix)
- [Home-Manager](https://github.com/nix-community/home-manager) configurations: [./roles/home-manager](./roles/home-manager)

## Creating a new MacOS configuration

If you want to add a new MacOS configuration, create a new output for your new build in `flake.nix`. Suppose that we wanted to name this output `mac-mini`, we would create an output in the `darwinConfigurations` declaration like this:

```
      # M1 mac-mini
      "mac-mini" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = inputs;
        modules = [ ./hosts/mac-mini.nix ];
      };
```

Then, create a new file in `./hosts/mac-mini.nix` with the following configuration:

```
{ config, pkgs, lib, home-manager, nur, ... }:

let
  hostname = "mac-mini";
  username = "heywoodlh";
in {
  imports = [
    ../roles/m1.nix
    ../roles/defaults.nix
    ../roles/brew.nix
    ../roles/yabai.nix
    ../roles/network.nix
    ../roles/users/${username}.nix
    ../roles/home-manager/settings.nix
  ];

  # Set home-manager configs for username
  home-manager.users.${username} = import ../roles/home-manager/user.nix;

  # Set hostname
  networking.hostName = "${hostname}";

  # Always show menu bar on M2 Macbook Air 
  system.defaults.NSGlobalDomain._HIHideMenuBar = lib.mkForce false;

  system.stateVersion = 4;
}
```

Once your configuration is set, you can switch to the new `mac-mini` output with these commands (while in the root directory of this repository):

```
darwin-rebuild switch --flake .#mac-mini
```

## Add a new user configuration

By default, this example creates a user named `heywoodlh`, defined in `./roles/users/heywoodlh.nix`.

Let's say we want a new user named `example`, copy `./roles/users/heywoodlh.nix` to `./roles/users/example.nix`. Then edit any references to `heywoodlh` to `example`. 
