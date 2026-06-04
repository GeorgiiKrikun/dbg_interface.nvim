{
    inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    outputs = { nixpkgs }: let
        system = builtins.currentSystem;
        pkgs = nixpkgs.legacyPackages.${system};
    in {
        devShells.${system}.default = pkgs.mkShell {
            buildInputs = [ pkgs.cmake ];
        };
    };
}
