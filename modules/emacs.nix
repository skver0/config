{ config, inputs, pkgs, ... }:
{
  imports = [
    inputs.nix-doom-emacs.hmModule
  ];
  programs.doom-emacs = {
    enable = true;
    doomPrivateDir = ../home/doom.d;
  };

  services.emacs.enable = true;

  home.packages = with pkgs; [
    ripgrep
    nodejs
    ghc 
    haskell-language-server
  ];
}