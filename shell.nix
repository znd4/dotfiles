{ pkgs ? import <nixpkgs> { } }:

let
  universalPackages = [
    "hatchling"
  ];

  # Define function to create Python environment with specified packages and universal packages
  createPythonEnv = { packages, withPackagesFn }: (withPackagesFn (ps:
    with ps; packages ++ map (p: ps.${p}) universalPackages));

  #k Create Python 3.10 environment
  python310Packages = createPythonEnv {
    packages = [
      "numpy"
      "pandas"
    ];
    withPackagesFn = pkgs.python310.withPackages;
  };

  # Create Python 3.11 environment
  python311Packages = createPythonEnv {
    packages = [
      "nbconvert"
      "ipython"
    ];
    withPackagesFn = pkgs.python311.withPackages;
  };

  # Combine the two environments into a larger `pythonPackages` list
  pythonPackages = [ python310Packages python311Packages ];

  # Other dependencies
  globalPackages = with pkgs; [
    clippy
    direnv
    fd
    fzf
    gcc
    github-cli
    go
    gum
    hatch
    httpie
    lazygit
    joplin
    nodejs
    openssl
    pkgconfig
    ripgrep
    starship
    stylua
    thefuck
    zsh
  ];

  rustPackages = with pkgs; [
    clang
    llvmPackages.bintools
    rustup
  ];

in
pkgs.mkShell rec {
  name = "my-env";

  buildInputs = with pkgs;
    [
      globalPackages
      rustPackages
      pythonPackages
    ];
}
