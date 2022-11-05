{ source-repo-override ? {} }:
let
  packages = import ../. {
    inherit source-repo-override;
  };
  pkgs = packages.pkgs;
  project = packages.project;
  # Just the packages in the project
  projectPackages = pkgs.haskell-nix.haskellLib.selectProjectPackages project.hsPkgs;

in  
  pkgs.dockerTools.buildImage {
    # shell = (import ./shell.nix { inherit source-repo-override; });

    # inherit name;
    name="plutus-starter-pab-image";

    contents = [
      pkgs.coreutils
      # add /bin/sh
      pkgs.bashInteractive
      # runtime dependencies of nix
      pkgs.cacert
      pkgs.git
      pkgs.gnutar
      pkgs.gzip
      pkgs.xz
      projectPackages.plutus-starter.components.exes.plutus-starter-pab
    ];
    tag = "latest";
    config = {
        Cmd = [ 
          ""
        ];
        ExposedPorts = {
          "9080/tcp" = {};
        };
        extraCommands = ''
        '';
        Env = [
        ];
    };
 }
# in
#  appImage { }  
