import asyncio
from fast_agent.core.fastagent import FastAgent

fast = FastAgent('osquery')

system_prompt = 'Use the provided MCP server to assist the user perform IT tasks.'

@fast.agent(
    instruction = system_prompt,
    model = 'gpt-4.1',
    servers = ['osquery'],
    use_history = True,
)

async def main():
    async with fast.run() as agent:
        try:
            await agent.interactive()
        except Exception:
            return

if __name__ == '__main__':
    asyncio.run(main())