let
  pkgs = import <nixpkgs> { };

  kmonadPath = "${builtins.getEnv "HOME"}/.config/nixpkgs/kmonad.nix";
  kmonad = import kmonadPath;
  myPackages = pkgs.buildEnv {
    name = "my-packages";
    paths = [
      "victor-mono"
      "fira-code"
      kmonad
    ];
  };
in
{
  allowUnfree = true;
  packageOverrides = pkgs: {
    myPackages = myPackages;
  };
}
