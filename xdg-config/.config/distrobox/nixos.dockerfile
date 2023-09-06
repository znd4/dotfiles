FROM docker.io/nixos/nix as builder

WORKDIR /build

RUN nix-channel --update
RUN nix-env -iA nixpkgs.cached-nix-shell
COPY ./shell.nix ./default.nix
ENV NIXPKGS_ALLOW_UNFREE=1

RUN nix-build .

FROM docker.io/nixos/nix
COPY --from=builder /build/result ./result

RUN nix-env -i ./result


CMD zsh --login
