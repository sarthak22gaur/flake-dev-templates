{
  description = "A Nix-flake-based LSP and formatter development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }:
        let
          node-pc = pkgs.writeShellScriptBin "node-pc" ''
            exec ${pkgs.nodejs-slim_latest}/bin/node --experimental-enable-pointer-compression "$@"
          '';

          typescript-language-server-pc = pkgs.writeShellScriptBin "typescript-language-server" ''
            exec ${pkgs.nodejs-slim_latest}/bin/node --experimental-enable-pointer-compression \
              ${pkgs.typescript-language-server}/lib/node_modules/typescript-language-server/lib/cli.mjs "$@"
          '';

          lsps = with pkgs; [
            lua-language-server
            nil
            pyright
            typescript-language-server
            rust-analyzer
            gopls
            ruby-lsp
            yaml-language-server
            bash-language-server
            vscode-langservers-extracted
          ];

          formatters = with pkgs; [
            stylua
            black
            prettierd
          ];

          commonPackages = [ pkgs.nodejs_latest ] ++ lsps ++ formatters;
        in
        {
          default = pkgs.mkShell {
            packages = commonPackages;
          };

          pointer-compression = pkgs.mkShell {
            packages = [
              node-pc
              typescript-language-server-pc
            ] ++ (pkgs.lib.filter (p: p != pkgs.typescript-language-server) commonPackages);
          };
        }
      );
    };
}
