{
  description = "Python environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-python.url = "github:cachix/nixpkgs-python";
  };

  outputs = { nixpkgs, flake-utils, nixpkgs-python, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        my_python_version = "3.12.12";
        my_uv_version = "0.9.8";
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
      in rec
      {
        packages = {
          python = nixpkgs-python.packages.${system}.${my_python_version};

          # パターン1：cargo を用いてビルド
          # uv = pkgs.rustPlatform.buildRustPackage (finalAttrs: {
          #   pname = "uv";
          #   version = "0.9.8";
          #   src = pkgs.fetchFromGitHub {
          #     owner = "astral-sh";
          #     repo = "uv";
          #     tag = finalAttrs.version;
          #     # hash = lib.fakeHash;
          #     hash = "sha256-e7yvEQggfBLq4akqnVoZTfvcpZLlbQRWr2fruGfF/N4=";
          #   };
          #   # cargoHash = lib.fakeHash;
          #   cargoHash = "sha256-lEGhXwzotvCuDAvVyrt22e/ReotWT7m1lt6d2GL8lFU=";
          #   doCheck = false;
          #   cargoBuildFlags = [ "--package" "uv" ];
          # });

          # パターン2：Github release からバイナリを取得
          uv = pkgs.stdenv.mkDerivation (finalAttrs: {
            pname = "uv";
            version = my_uv_version;
            src =
              if system == "x86_64-linux" then
                pkgs.fetchzip {
                  url  = "https://github.com/astral-sh/uv/releases/download/${my_uv_version}/uv-x86_64-unknown-linux-gnu.tar.gz";
                  hash = "sha256-0iyRn6x5I1KRejoT/OrC/jaQLkFEK50+OCG/un4x36g=";
                }
              # 他のプラットフォーム用のURLとハッシュをここに追加
              # 初回のみ nix develop した後、エラーが出るので、以下の部分を探して hash を書き換える
              # specified: sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
              # got:    sha256-0iyRn6x5I1KRejoT/OrC/jaQLkFEK50+OCG/un4x36g=
              else if system == "aarch64-darwin" then
                pkgs.fetchzip {
                  url  = "";
                  hash = lib.fakeHash;
                }
              else
                throw "Unsupported platform: ${system}";
            installPhase = ''
              mkdir -p $out/bin
              cp uv $out/bin
            '';
          });
        };

        devShells.default = pkgs.mkShell {
          packages = [
            packages.python
            packages.uv
          ];
          shellHook = ''
            export UV_PYTHON=${my_python_version}
            export UV_PYTHON_DOWNLOADS=never
          '';
        };
      });
}
