import asyncio
import logging
from local_agent import LocalAgent

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def main() -> None:
    logger.info("Ollama Agent を起動中...")
    agent = LocalAgent()

    print("チャットを開始します。終了するには 'exit' または 'quit' を入力してください。")
    while True:
        try:
            user_input = input("あなた: ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nチャットを終了します。")
            break

        if not user_input:
            print("システム: メッセージを入力してください。")
            continue

        if user_input.lower() in {"exit", "quit"}:
            logger.info("ユーザー操作によりチャットを終了します。")
            break

        response = asyncio.run(agent.get_response(user_input))
        print("エージェント:", response)

if __name__ == "__main__":
    main()
