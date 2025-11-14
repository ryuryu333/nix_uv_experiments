{
  description = "Python environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.uv
            pkgs.python311
            pkgs.ollama # for CPU only
            # pkgs.ollama-rocm # for AMD GPU
            # pkgs.ollama-cuda # for NVIDIA GPU
          ];
          shellHook = ''
            export UV_PYTHON=${pkgs.python311.version}
            export UV_PYTHON_DOWNLOADS=never
            # WSL 環境で ollama-cuda を使う場合に必要
            export LD_LIBRARY_PATH=/usr/lib/wsl/lib:$LD_LIBRARY_PATH
          '';
        };
      });
}
