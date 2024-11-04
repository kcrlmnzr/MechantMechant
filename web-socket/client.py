import asyncio
import websockets

async def test():
    uri = "ws://localhost:8765"
    async with websockets.connect(uri) as websocket:
        message = "Hello, serveur !"
        print(f"Envoi : {message}")
        await websocket.send(message)
        
        response = await websocket.recv()
        print(f"Réponse du serveur : {response}")

asyncio.run(test())
