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
        ixy-go = import ./ixy-go { inherit pkgs; go-src = inputs.ixy-languages-go; };
      });
  };
}
