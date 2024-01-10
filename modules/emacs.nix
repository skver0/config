{ config, inputs, pkgs, ... }:
let
  copilotSrc = pkgs.fetchFromGitHub {
    owner = "copilot-emacs";
    repo = "copilot.el";
    rev = "37cb633e4d8933170471ca8e435eaf415ed69f92";
    sha256 = "sha256-VTk0UxTJOjpmU0z0lkZ8i46l68fK2p+qnQpRpLkyAho=";
  };
in
{  
  imports = [
    inputs.nix-doom-emacs.hmModule
  ];

  programs.doom-emacs = {
    enable = true;
    doomPrivateDir = ../home/doom.d;
    emacsPackage = pkgs.emacs29-pgtk;
    emacsPackagesOverlay = self: super: {
      copilot = self.trivialBuild {
        ename = "copilot";
        pname = "copilot";
        version = "1";
        src = copilotSrc;
        buildInputs = with pkgs; [ nodejs ];
        packageRequires = with self; [ s dash editorconfig ];
      };
    };
  };

  home.sessionVariables.EMACS_PATH_COPILOT = "${copilotSrc}";

  home.packages = with pkgs; [
    ripgrep
    nodejs
    ghc 
    haskell-language-server
  ];
}
