{
  description = "Android 34 Nix dev env (Apple Silicon, all stable dependencies, no duplicates)";

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
              # Core tools
              cmdline-tools-latest
              build-tools-36-0-0
              platform-tools
              platforms-android-36
              sources-android-36
              emulator

              # NDK & CMake (latest stable)
              ndk-29-0-14033849
              cmake-3-22-1

              # Extras for legacy & maven support
              # extras-google-m2repository
              # extras-android-m2repository

              # --- SYSTEM IMAGES (ARM64, API 34) ---
              # Default
              # system-images-android-36-default-arm64-v8a
              # Google APIs
              # system-images-android-36-google-apis-arm64-v8a
              # Google APIs Play Store
              # system-images-android-36-google-apis-playstore-arm64-v8a
            ]))
          ];

          shellHook = ''
            export ANDROID_HOME=$ANDROID_SDK_ROOT
            export PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH
            echo "Android 34 Nix dev env loaded"
            echo "SDK location: $ANDROID_SDK_ROOT"
            echo "Available tools: adb, emulator, sdkmanager, avdmanager"
          '';
        };
      });
    };
}
