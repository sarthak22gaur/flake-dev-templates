{
  description = "A Nix-flake-based Python development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          venvDir = ".venv";
          packages = with pkgs; [ python311 ] ++
            (with pkgs.python311Packages; [
              pip
              venvShellHook
            ]);

          # Explicitly activate the virtual environment in the shellHook
          shellHook = ''
            # If the .venv directory doesn't exist, create it
            if [ ! -d ".venv" ]; then
              python3 -m venv .venv
            fi

            # Activate the virtual environment
            source .venv/bin/activate

            # Ensure PYTHONPATH includes the current project directory
            export PYTHONPATH=$PYTHONPATH:$(pwd)

            echo "Virtual environment activated, using Python from .venv"
          '';
        };
      });
    };
}
