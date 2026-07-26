{ go-src, pkgs }:

pkgs.stdenv.mkDerivation {
  name = "forwarder";
  src = go-src;
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
}
