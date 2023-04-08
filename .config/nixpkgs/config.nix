let
  pkgs = import <nixpkgs> { };

  myPackages = pkgs.buildEnv {
    name = "my-packages";
    paths = [
      "victor-mono"
      "fira-code"
    ];
  };
in
{
  allowUnfree = true;
  packageOverrides = pkgs: {
    myPackages = myPackages;
  };
}
