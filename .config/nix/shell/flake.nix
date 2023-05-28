{
  description = "A flake for my personal dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem
    (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        universalPackages = [
          "hatchling"
          "pynvim"
          "ipython"
          "nbconvert"
          "numpy"
          "pandas"
          "pip"
          "matplotlib"
        ];

        # Define function to create Python environment with specified packages and universal packages
        createPythonEnv = { packages, withPackagesFn }: (withPackagesFn (ps:
          with ps; packages ++ map (p: ps.${p}) universalPackages));

        #k Create Python 3.10 environment
        python310 = createPythonEnv {
          packages = [
          ];
          withPackagesFn = pkgs.python310.withPackages;
        };

        python310Cmd = pkgs.stdenv.mkDerivation {
          name = "python311cmd";
          buildCommand = ''
            mkdir -p $out/bin
            ln -s ${python310}/bin/python $out/bin/py310
          '';
        };

        #k Create Python 3.10 environment
        python311 = createPythonEnv {
          packages = [
          ];
          withPackagesFn = pkgs.python311.withPackages;
        };

        python311Cmd = pkgs.stdenv.mkDerivation {
          name = "python311cmd";
          buildCommand = ''
            mkdir -p $out/bin
            ln -s ${python311}/bin/python $out/bin/py311
          '';
        };
        # Combine the two environments into a larger `pythonPackages` list
        pythonPackages = [
          python310Cmd
          # python311Cmd
        ];

        # Other dependencies
        globalPackages = with pkgs; [
          bat
          brev-cli
          clippy
          cookiecutter
          micromamba
          copier
          delta
          direnv
          distrobox
          fd
          fnm # faster node version manager
          fzf
          gcc
          # gfortran # needed for scipy and numpy
          github-cli
          git-lfs
          go
          gum
          hatch
          httpie
          hugo

          bundler
          jekyll

          joplin
          lazygit
          # libstdcxx5
          # libcxx

          # hoping that manpages show up
          man

          neovim
          nodejs
          openssl
          pdd
          pipx
          pipenv
          podman

          pkgconfig
          pre-commit
          ripgrep
          starship
          stylua
          texlive.combined.scheme-full
          thefuck
          tmux
          # tmux.man

          zoxide
          zsh
        ];

        rustPackages = with pkgs; [
          clang
          # llvmPackages.bintools
          rustup
        ];
      in
      {
        devShell = pkgs.mkShell
          {
            buildInputs = [ pythonPackages globalPackages ];
          };
        # packages = flake-utils.lib.flattenTree {
        #   all = pkgs.buildEnv {
        #     name = "all";
        #     paths = pythonPackages ++ globalPackages;
        #     # paths = pythonPackages ++ rustPackages ++ globalPackages;
        #   };
        # };
        #
        # defaultPackage = self.packages.${system}.all;
      }
    );
}
