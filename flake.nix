{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, rust-overlay, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        rust = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" ];
          targets = [ "wasm32-wasi" "wasm32-unknown-unknown" ];
        };
        buildWasmEdgeNoAOT = pkgs.writeShellScriptBin "build-without-aot" ''
          cmake -Bbuild -GNinja -DCMAKE_BUILD_TYPE=Debug -DWASMEDGE_BUILD_AOT_RUNTIME=OFF .
          cmake --build build
        '';
        runRustSdkTest = pkgs.writeShellScriptBin "run-rust-sdk-test" ''
          cd bindings/rust/
          export WASMEDGE_DIR="$(pwd)/../../"
          export WASMEDGE_BUILD_DIR="$(pwd)/../../build"
          export LD_LIBRARY_PATH="$(pwd)/../../build/lib/api"
          cargo test -p wasmedge-sdk --examples -- --nocapture
        '';
        runRustSdkExample = pkgs.writeShellScriptBin "run-rust-sdk-example" ''
          cd bindings/rust/
          export WASMEDGE_DIR="$(pwd)/../../"
          export WASMEDGE_BUILD_DIR="$(pwd)/../../build"
          export LD_LIBRARY_PATH="$(pwd)/../../build/lib/api"
          cargo run -p wasmedge-sdk --example $1
        '';
        runRustSysTest = pkgs.writeShellScriptBin "run-rust-sys-test" ''
          cd bindings/rust/
          export WASMEDGE_DIR="$(pwd)/../../"
          export WASMEDGE_BUILD_DIR="$(pwd)/../../build"
          export LD_LIBRARY_PATH="$(pwd)/../../build/lib/api"
          cargo test -p wasmedge-sys --examples -- --nocapture
        '';
        runRustSysExample = pkgs.writeShellScriptBin "run-rust-sys-example" ''
          cd bindings/rust/
          export WASMEDGE_DIR="$(pwd)/../../"
          export WASMEDGE_BUILD_DIR="$(pwd)/../../build"
          export LD_LIBRARY_PATH="$(pwd)/../../build/lib/api"
          cargo run -p wasmedge-sys --example $1
        '';
      in
      with pkgs;
      {
        devShell = mkShell {
          buildInputs = [
            boost
            clang
            cmake
            gcovr
            llvm_10
            ninja
            openssl
            pkg-config
            rust

            buildWasmEdgeNoAOT
            runRustSysTest
            runRustSysExample
            runRustSdkTest
            runRustSdkExample
          ];

          LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
        };
      }
    );
}
