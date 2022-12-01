{
  description = "Elixir project shell";
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        elixir = pkgs.beam.packages.erlangR25.elixir_1_14;
        elixir_ls = pkgs.elixir_ls.override (old: { inherit elixir; });
      in {
        devShell = pkgs.mkShell {
          nativeBuildInputs = [ elixir elixir_ls pkgs.inotify-tools ];
          buildInputs = [ ];
        };
      });
}
