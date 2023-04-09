let
  pkgs = import <nixpkgs> { };

  myPackages = pkgs.buildEnv {
    name = "my-packages";
    paths = [
      "victor-mono"
      "fira-code"
      "cached-nix-shell"
      "vscode"
      "neovim"
    ];
  };
in
{
  allowUnfree = true;
  packageOverrides = pkgs: {
    myPackages = myPackages;
  };
}
