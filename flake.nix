{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "flake:nixpkgs";
  inputs.flake-utils.url = "flake:flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShell = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.bashInteractive
            pkgs.kube3d
            pkgs.terraform
            pkgs.jq
            pkgs.vault
            pkgs.awscli2
          ];
          buildInputs = [
            pkgs.k9s
          ];
        };
      });
}
