{ config, ... }:

{
  #homebrew packages
  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    #onActivation.cleanup = "zap"; # Uncomment this if you want all brew packages not defined in this file to be removed when updated
    brews = [
      "bash"
      "coreutils"
      "curl"
      "git"
      "m-cli"
      "mas"
      "zsh"
    ];
    extraConfig = ''
      cask_args appdir: "~/Applications"
    '';
    taps = [
      "homebrew/cask"
      "homebrew/cask-drivers"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/core"
      "homebrew/services"
    ];
    casks = [
      "caffeine"
      "discord"
      "firefox"
      "zoom"
    ];
    masApps = {
      DaisyDisk = 411643860;
      Vimari = 1480933944;
      "WiFi Explorer" = 494803304;
      "Reeder 5." = 1529448980;
      "Okta Extension App" = 1439967473;
    };
  };
}
