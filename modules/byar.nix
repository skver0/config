{
  pkgs ? import <nixpkgs> { },
}:

let
  version = "1.2988.0";
  pname = "byar";
in
pkgs.appimageTools.wrapType2 {
  pname = "${pname}";
  version = "${version}";

  src = pkgs.fetchurl {
    url = "https://github.com/beyond-all-reason/BYAR-Chobby/releases/download/v${version}/Beyond-All-Reason-${version}.AppImage";
    hash = "sha256-ZJW5BdxxqyrM2TJTO0SBp4BXt3ILyi77EZx73X8hqJE=";
  };

  extraPkgs = pkgs: [ pkgs.openal ];

  meta = {
    description = "Beyond All Reason RTS";
    homepage = "https://www.beyondallreason.info";
    downloadPage = "https://www.beyondallreason.info/download";
    platforms = [ "x86_64-linux" ];
  };
}