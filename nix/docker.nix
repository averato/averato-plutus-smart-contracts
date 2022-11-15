{ source-repo-override ? {}
, pkgs
, execPackages
, img ? { name = "pab"; port = "9080"; cmd = ["/bin/cardevato-pab" "--config /etc/config.yaml"]; components = [ execPackages.cardevato-pab ]; } 
}:
with pkgs;
let
#  packages = import ../. {
#    inherit source-repo-override;
#  };
#  inherit (packages) pkgs project plutus;
#  # pkgs = packages.pkgs;
#  # project = packages.project;
#  # Just the packages in the project
#  projectPackages = pkgs.haskell-nix.haskellLib.selectProjectPackages project.hsPkgs;
#  execPackages =  projectPackages.plutus-starter.components.exes;
#  img-components = if isDefaultImage then [ execPackages.plutus-starter-pab ] else [ plutus.plutus-chain-index ];
#nixFromDockerHub = dockerTools.pullImage {
#    imageName = "nixos/nix";
#    imageDigest = "sha256:85299d86263a3059cf19f419f9d286cc9f06d3c13146a8ebbb21b3437f598357";
#    sha256 = "19fw0n3wmddahzr20mhdqv6jkjn1kanh6n2mrr08ai53dr8ph5n7";
#    finalImageTag = "2.2.1";
#    finalImageName = "nix";
#  };
#  
#  baseImage = dockerTools.buildLayeredImage {
#    name = "base";
#    tag = "latest";
#    fromImage = nixFromDockerHub;
#    contents = [
#      coreutils
#      # add /bin/sh
#      bashInteractive
#      # runtime dependencies of nix
#      cacert
#      # git
#      # gnutar
#      # gzip
#      # xz
#    ]; 
#  };
#
in  
  dockerTools.buildImage {
    name = img.name;
#    fromImage = nixFromDockerHub;
    contents = img.components ;
    tag = "latest";
    created = "now";
    config = {
        Cmd = img.cmd;
        ExposedPorts = {
          "${img.port}/tcp" = {};
        };
        extraCommands = ''
        '';
        Env = [
        ];
    };
 }
