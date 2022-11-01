{ source-repo-override }:
let
  # Pratically, the only needed dependency is the plutus repository.
  sources = import ./sources.nix { inherit pkgs; };

  # We're going to get everything from the main plutus repository. This ensures
  # we're using the same version of multiple dependencies such as nipxkgs,
  # haskell-nix, cabal-install, compiler-nix-name, etc.
  plutus = import sources.plutus-apps {};
  pkgs = plutus.pkgs;

  haskell-nix = pkgs.haskell-nix;

  plutus-starter = import ./pkgs {
    inherit pkgs haskell-nix sources plutus source-repo-override;
  };

  nixpkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/22.05.tar.gz";
  }) { };
  
  appImage = nixpkgs.dockerTools.buildImage {
    # inherit name;
    name="plutus-starter-pab-image";

    contents = [
      plutus-starter.haskell.packages.plutus-starter.components.exes.plutus-starter-pab
      nixpkgs.coreutils
#      # add /bin/sh
#      bashInteractive
#      # runtime dependencies of nix
      nixpkgs.cacert
#      git
#      gnutar
#      gzip
#      xz
    ];
    tag = "latest";
    config = {
        Cmd = [ 
          ""
        ];
        ExposedPorts = {
          "8000/tcp" = {};
        };
        extraCommands = ''
        '';
        Env = [
          "APP_MODE:production"
        ];
    };
 };
in

  pkgs.callPackage (appImage // { 
      # inherit pkgs plutus-starter;
      met = appImage.meta;  
    }
  ) { }  
