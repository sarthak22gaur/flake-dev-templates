{
  description = "React Native development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, android-nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { system = system; };
    sdk = (import android-nixpkgs { inherit pkgs; }).sdk (sdkPkgs:
      with sdkPkgs; [
        build-tools-33-0-1
        build-tools-34-0-0
        build-tools-35-0-0
        cmdline-tools-latest
        platform-tools
        platforms-android-31
        platforms-android-33
        platforms-android-34
        platforms-android-35
        ndk-27-1-12297006
        cmake-3-22-1
      ]);
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        pkgs.nodejs_20
        pkgs.yarn
        pkgs.watchman
        pkgs.jdk17
        pkgs.gradle
      ];

      shellHook = ''
        echo "Entering Nix React Native shell..."
        export ANDROID_HOME="${sdk}"
        export PATH="${sdk}/bin:${sdk}/cmdline-tools/latest/bin:${sdk}/platform-tools:$PATH"
        source "${sdk}/nix-support/setup-hook"
      '';
    };
  };
}
