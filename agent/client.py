import asyncio
from fast_agent.core.fastagent import FastAgent

fast = FastAgent('osquery')

system_prompt = (
    'Use the provided MCP server to assist the user in collecting OS information. '
    'If the user does not specify which node to target for a query, call `list_hosts` and '
    'run the query on the first node listed.'
)

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