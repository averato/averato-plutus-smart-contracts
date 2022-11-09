{ source-repo-override ? { } 
# NOTE: use the 'repo' branch of CHaP which contains the index
, CHaP ? (builtins.fetchTarball
    "https://github.com/input-output-hk/cardano-haskell-packages/archive/ceaae5355c81453d7cb092acadec3441bf57ed11.tar.gz")
}:
########################################################################
# default.nix -- The top-level nix build file for plutus-starter.
#
# This file defines various attributes that are used for building and
# developing plutus-starter.
#
########################################################################

let
  # Here a some of the various attributes for the variable 'packages':
  #
  # { pkgs
  #   plutus-starter: {
  #     haskell: {
  #       project # The Haskell project created by haskell-nix.project
  #       packages # All the packages defined by our project, including dependencies
  #       projectPackages # Just the packages in the project
  #     }
  #     hlint
  #     cabal-install
  #     stylish-haskell
  #     haskell-language-server
  #   }
  # }
  packages = import ./nix { inherit source-repo-override; };
  # inherit source-repo-override
  inherit (packages) pkgs plutus-starter plutus;
  project = plutus-starter.haskell.project;
#  {
#    inputMap = { "https://input-output-hk.github.io/cardano-haskell-packages" = CHaP; };
#      modules = [
#      # Set libsodium-vrf on cardano-crypto-{praos,class}. Otherwise they depend
#      # on libsodium, which lacks the vrf functionality.
#      ({ pkgs, lib, ... }:
#        # Override libsodium with local 'pkgs' to make sure it's using
#        # overriden 'pkgs', e.g. musl64 packages
#        {
#          packages.cardano-crypto-class.components.library.pkgconfig = lib.mkForce [ [ pkgs.libsodium-vrf pkgs.secp256k1 ] ];
#          packages.cardano-crypto-praos.components.library.pkgconfig = lib.mkForce [ [ pkgs.libsodium-vrf ] ];
#        }
#      )
#    ];
#  };
in
{
  inherit pkgs plutus-starter plutus;

  inherit project;

  # plutus-starter-pab = plutus-starter.haskell.packages.plutus-starter.components.exes.plutus-starter-pab;
  # Docker image buildup with error
  # plutus-starter-image = import ./nix/docker.nix { inherit  source-repo-override; };

}
