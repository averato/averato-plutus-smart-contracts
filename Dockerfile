# Build stages

FROM nixos/nix:2.11.0 as build

RUN echo "substituters = https://cache.nixos.org https://cache.iog.io" >> /etc/nix/nix.conf &&\
  echo "trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" >> /etc/nix/nix.conf

WORKDIR /build
COPY . .

# plutus-starter-pab 

FROM build as build-plutus-starter-pab 
RUN nix-build -A plutus-starter-pab -o plutus-starter-pab-result default.nix

FROM alpine as plutus-starter-pab
COPY --from=build-starter-pab /build/plutus-starter-pab-result/bin/plutus-starter-pab /bin/
STOPSIGNAL SIGINT
ENTRYPOINT ["plutus-starter-pab"]

