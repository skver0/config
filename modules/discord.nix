{ config, pkgs, inputs, ... }:
{
  /*
  nixpkgs.overlays = [
    (self: super: {
      discord = super.discord.override {
        withOpenASAR = true;
        withVencord = true;
      };
    })
  ];
  */
  
  home.packages = with pkgs; [
     vesktop
  ];
}
