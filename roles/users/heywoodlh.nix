{ config, pkgs, lib, ... }:

let
  username =  "heywoodlh";
in {
  users.users."${username}" = {
    description = "${username}";
    home = "/Users/${username}";
    name = "${username}";
    shell = pkgs.bash;
    packages = [
      pkgs.bash
      pkgs.gcc
      pkgs.git
      pkgs.gnupg
    ];
  };
}
