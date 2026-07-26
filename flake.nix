{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    ixy-languages-go = {
      url = "github:ixy-languages/ixy.go/master";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, ... } @ inputs:
  let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
  in
  {
    packages = forAllSystems (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        ixy-haskell = pkgs.haskellPackages.callCabal2nix "ixy-haskell" ./ixy-haskell { };

        ixy-go = pkgs.stdenv.mkDerivation {
          name = "forwarder";
          src = inputs.ixy-languages-go;
          version = "0.1";

          nativeBuildInputs = [ pkgs.go ];

          patchPhase = ''
              cat > ./go.mod <<'EOF'
              module github.com/ixy-languages/ixy.go
          
              go 1.26


              require (
              )
              EOF
            '';

          
          buildPhase = ''
            export GOCACHE=/tmp/go-build
            mkdir -p "$GOCACHE"

            cd ./fwd/
            go build -o forwarder .
            cd ../
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp fwd/forwarder $out/bin/
          '';
        };
      });
  };
}
