{ pkgs ? import <nixpkgs> { } }:

let
  universalPackages = [
    "hatchling"
    "pynvim"
    "ipython"
    "numpy"
    "pandas"
  ];

  # Define function to create Python environment with specified packages and universal packages
  createPythonEnv = { packages, withPackagesFn }: (withPackagesFn (ps:
    with ps; packages ++ map (p: ps.${p}) universalPackages));

  #k Create Python 3.10 environment
  python310Packages = createPythonEnv {
    packages = [
      "pandas"
    ];
    withPackagesFn = pkgs.python310.withPackages;
  };

  # Create Python 3.11 environment
  python311Packages = createPythonEnv {
    packages = [
      "nbconvert"
    ];
    withPackagesFn = pkgs.python311.withPackages;
  };

  # Combine the two environments into a larger `pythonPackages` list
  pythonPackages = [ python310Packages python311Packages ];

  # Other dependencies
  globalPackages = with pkgs; [
    bat
    brev-cli
    clippy
    cookiecutter
    copier
    direnv
    fd
    fnm # faster node version manager
    fzf
    gcc
    gfortran # needed for scipy and numpy
    github-cli
    go
    gum
    hatch
    httpie
    joplin
    lazygit
    libstdcxx5
    nodejs
    openssl
    pdd
    pkgconfig
    ripgrep
    starship
    stylua
    texlive.combined.scheme-full
    thefuck
    zoxide
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
