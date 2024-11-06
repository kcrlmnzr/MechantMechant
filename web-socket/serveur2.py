import asyncio
import websockets

async def echo(websocket, path):
    try:
        async for message in websocket:
            print(f"Message reçu : {message}")
            await websocket.send(f"Reçu : {message}")
    except websockets.exceptions.ConnectionClosedError:
        print("Connexion fermée proprement.")
    except Exception as e:
        print(f"Erreur : {e}")

# Change "localhost" to "0.0.0.0" to listen on all network interfaces
start_server = websockets.serve(echo, "0.0.0.0", 8765)

asyncio.get_event_loop().run_until_complete(start_server)
print("Serveur WebSocket lancé sur ws://0.0.0.0:8765")
asyncio.get_event_loop().run_forever()
