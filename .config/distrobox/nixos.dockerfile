FROM docker.io/nixos/nix
RUN nix-channel --update
RUN nix-env -iA nixpkgs.cached-nix-shell
COPY ./shell.nix ./default.nix
ENV NIXPKGS_ALLOW_UNFREE=1
RUN nix-build .
CMD zsh --login
