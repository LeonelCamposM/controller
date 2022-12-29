import asyncio
import websockets
import socket
import pydirectinput


def getIP():
    ip = 'NULL'
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        sock.connect(('8.8.8.8', 1))
        ip = sock.getsockname()[0]
    except Exception:
        pass
    sock.close()
    assert ip != 'NULL', "Could not get machine ip\n"
    return ip


async def response(websocket, path):
    while True:
        try:
            message = await websocket.recv()
            pressedKey = message
            if '!' in pressedKey:
                pressedKey = pressedKey.replace('!', '')
                pydirectinput.keyUp(pressedKey)
                print('up '+pressedKey)
            else:
                pydirectinput.keyDown(pressedKey)
                print('down '+pressedKey)
        except websockets.exceptions.ConnectionClosedError:
            pass
    


print('running on: ' + getIP())
start_server = websockets.serve(response, getIP(), 1234, ping_interval=None)
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
