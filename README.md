# nix_uv_experiments

## SetUp

```bash
git clone git@github.com:ryuryu333/nix_uv_experiments.git
cd nix_uv_experiments
```

`flake.nix` から、利用する ollama をコメントアウトして選択。
ollama-cuda の場合、初回の起動は時間がかかる（筆者環境で 20 分ほど）ので注意。

```nix
devShells.default = pkgs.mkShell {
  packages = [
    packages.python
    packages.uv
    # pkgs.ollama # for CPU only
    # pkgs.ollama-rocm # for AMD GPU
    pkgs.ollama-cuda # for NVIDIA GPU
  ];
```

環境を起動する。
これ以降、direnv によりプロジェクトルートを開くと自動的に nix devshell が起動される。

```bash
direnv allow
```

ollama のモデルを準備する。

9.3GB のモデルなので、GPU RAM 12 GB or RAM 32 GB なら動くはず。
（src/local_agent.py にて model_name: str = "qwen3:14b" とモデル名を指定しています。）

```
ollama pull qwen3:14b
```


## Usage
ollama を起動する。

```bash
ollama serve
```

新しいターミナルを開き、src/main.py を実行する。
エージェントとの会話が始まる。

```bash
$ uv run src/main.py
INFO:__main__:Ollama Agent を起動中...
チャットを開始します。終了するには 'exit' または 'quit' を入力してください。
あなた: こんにちは
INFO:httpx:HTTP Request: POST http://localhost:11434/v1/chat/completions "HTTP/1.1 200 OK"
エージェント: こんにちは！どのようにお手伝いできますか？😊
あなた: exit
INFO:__main__:ユーザー操作によりチャットを終了します。
```
