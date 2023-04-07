{ pkgs ? import <nixpkgs> { } }:
let
  # Python dependencies
  pythonPackages = with pkgs.python3Packages; [
    nbconvert
    ipython
  ];

  globalPackages = with  pkgs; [
    # Note: to use use stable, just replace `nightly` with `stable`
    # latest.rustChannels.nightly.rust
    # latest.rustChannels.stable.rust


    # use 1passsword for git credentials
    git-credential-1password

    # Add some extra dependencies from `pkgs`
    clippy
    direnv
    fd
    fzf
    gcc
    github-cli
    go
    gum
    hatch
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
    # cargo
    # rust-analyzer
    # rustc
    # rustfmt
    clang
    llvmPackages.bintools
    rustup
  ];

in
pkgs.mkShell rec {
  name = "rust-env";

  # RUSTC_VERSION = pkgs.lib.readFile ./rust-toolchain;
  RUSTC_VERSION = "stable";
  # https://github.com/rust-lang/rust-bindgen#environment-variables
  LIBCLANG_PATH = pkgs.lib.makeLibraryPath [ pkgs.llvmPackages_latest.libclang.lib ];
  shellHook = ''
    export PATH=$PATH:''${CARGO_HOME:-~/.cargo}/bin
    export PATH=$PATH:''${RUSTUP_HOME:-~/.rustup}/toolchains/$RUSTC_VERSION-x86_64-unknown-linux-gnu/bin/
  '';
  # Add libvmi precompiled library to rustc search path
  RUSTFLAGS = (builtins.map (a: ''-L ${a}/lib'') [
    pkgs.libvmi
  ]);
  # Add libvmi, glibc, clang, glib headers to bindgen search path
  BINDGEN_EXTRA_CLANG_ARGS =
    # Includes with normal include path
    (builtins.map (a: ''-I"${a}/include"'') [
      pkgs.libvmi
      pkgs.glibc.dev
    ])
    # Includes with special directory paths
    ++ [
      ''-I"${pkgs.llvmPackages_latest.libclang.lib}/lib/clang/${pkgs.llvmPackages_latest.libclang.version}/include"''
      ''-I"${pkgs.glib.dev}/include/glib-2.0"''
      ''-I${pkgs.glib.out}/lib/glib-2.0/include/''
    ];
  depsBuildBuild = with pkgs; [ python3Packages.nbconvert ];

  buildInputs = with pkgs;
    [
      rustPackages
      globalPackages

      pythonPackages
    ];
  # Add some extra dependencies to buildInputs from `pkgs.python3Packages`

  # Set Environment Variables
  RUST_BACKTRACE = 1;
}
