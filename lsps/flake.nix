{
  description = "A Nix-flake-based LSP support";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    in
      {
        devShells = nixpkgs.lib.genAttrs supportedSystems (system:
          let
            pkgs = import nixpkgs { inherit system; };

            kotlinLspVersion = "0.253.10629";
            kotlinLspZipUrl = "https://download-cdn.jetbrains.com/kotlin-lsp/${kotlinLspVersion}/kotlin-${kotlinLspVersion}.zip";
            kotlinLspSha256 = "0zcn89ia6czrcfadjqn51hv4zfq1ax3x3ydw4gc89zrwfjiwc8ic";

            kotlin-lsp = pkgs.stdenv.mkDerivation {
              pname = "kotlin-lsp";
              version = kotlinLspVersion;
              src = pkgs.fetchzip {
                url = kotlinLspZipUrl;
                sha256 = kotlinLspSha256;
                stripRoot = false;
              };
              nativeBuildInputs = [ pkgs.unzip pkgs.patchelf ];
              installPhase = ''
                mkdir -p $out/bin
                cp -r * $out/
                chmod +x $out/kotlin-lsp.sh
                cat > $out/bin/kotlin-lsp <<EOF
                #!${pkgs.bash}/bin/bash
                exec "$out/kotlin-lsp.sh" "\$@"
                EOF
                chmod +x $out/bin/kotlin-lsp
              '';
            };
          in
          {
            default = pkgs.mkShell {
              packages = with pkgs; [
                lua-language-server
                pyright
                typescript-language-server
                rust-analyzer
                gopls
                stylua
                black
                prettierd
                kotlin-lsp
                jdk
              ];
            };
          }
        );
      };
}
