import logging
from openai import AsyncOpenAI
from agents import Agent, Runner, set_default_openai_client, set_default_openai_api, set_tracing_disabled

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class LocalAgent:
    def __init__(
        self, 
        model_name: str = "qwen3:14b", 
        base_url: str = "http://localhost:11434/v1",
        api_key: str = "ollama",
    ) -> None:
        self.model_name = model_name
        self.base_url = base_url
        self.api_key = api_key
        
        # OpenAI 互換クライアントの設定
        set_default_openai_client(
            client = AsyncOpenAI(
                api_key = self.api_key,
                base_url = self.base_url
            )
        )
        set_default_openai_api("chat_completions")
        set_tracing_disabled(disabled = True)
        
        self._create_basic_agent()

    def _create_basic_agent(self) -> None:
        self.agent = Agent(
            model=self.model_name,
            name="my-agent"
        )

    async def get_response(self, user_input: str) -> str:
        try:
            if not user_input.strip():
                return "申し訳ありませんが、メッセージが空のようです。"
            
            result = await Runner.run(self.agent, user_input)
            return result.final_output
                
        except Exception as e:
            return f"エラーが発生しました: {str(e)}"
