{
  description = ".egg-info repro";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, poetry2nix }:
    let
      name = "sync-blocks";
      system = "x86_64-linux";
      pythonVersion = pkgs.python39;

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ poetry2nix.overlay ];
      };

      # extract common args passed to some functions below
      poetryAttrs = {
        projectDir = ./.;
        python = pythonVersion;
        overrides = [
          pkgs.poetry2nix.defaultPoetryOverrides
        ];
      };
    in

    {
      packages.${system} = {
        # nix build
        default = pkgs.poetry2nix.mkPoetryApplication poetryAttrs;

      };

      devShells.${system}.default = (pkgs.poetry2nix.mkPoetryEnv poetryAttrs).env;

      checks.${system}.tests =
        pkgs.poetry2nix.mkPoetryApplication (poetryAttrs // { checkPhase = "py.test"; });
    };
}
