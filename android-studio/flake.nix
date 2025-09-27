{
  description = "Android development environment with SDK and NDK (optimized for Apple Silicon)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, android-nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
        android-sdk = android-nixpkgs.sdk.${system};
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs, android-sdk }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            (android-sdk (sdkPkgs: with sdkPkgs; [
              cmdline-tools-latest
              build-tools-35-0-0
              build-tools-34-0-0
              platform-tools
              platforms-android-35
              platforms-android-34
              emulator
              ndk-27-0-12077973
              cmake-3-22-1
              # Native ARM system images for emulators:
              system-images-android-35-google-apis-arm64-v8a
              system-images-android-34-google-apis-arm64-v8a
            ]))
          ];

          shellHook = ''
            echo "Android development environment loaded"
            echo "SDK location: $ANDROID_HOME"
            echo "Available tools: adb, emulator, sdkmanager"
          '';
        };
      });
    };
}
