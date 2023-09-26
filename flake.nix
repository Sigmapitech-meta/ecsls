{
  description = "Epitech Coding Style Checker Language Server";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in
      {
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            python310
            banana-vera
            black
          ];
        };

        packages = {
          ecsls =
            let
              pypkgs = pkgs.python311Packages;
              vera = (import ./banana-vera-clang.nix { inherit pkgs system; });
            in
            pypkgs.buildPythonPackage {
              pname = "ecsls";
              version = "0.0.1";
              src = ./.;

              propagatedBuildInputs = [ pypkgs.pygls pypkgs.tomli ];
              nativeBuildInputs = with pkgs; [
                makeWrapper
              ];

              postFixup = ''
                wrapProgram $out/bin/ecsls_run \
                --set PATH ${pkgs.lib.makeBinPath ([ vera ])}
              '';
            };

          default = self.packages.${system}.ecsls;
        };
      });
}
