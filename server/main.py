from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from typing import List

app = FastAPI()

# Store active WebSocket connections
active_connections: List[WebSocket] = []

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    active_connections.append(websocket)
    print("New client connected.")

    try:
        while True:
            data = await websocket.receive_text()  # Keep connection open
            print(f"Received from client: {data}")
    except WebSocketDisconnect:
        print("Client disconnected")
    finally:
        active_connections.remove(websocket)

@app.post("/send-notification/")
async def send_notification(message: str):
    print(f"Broadcasting message: {message}")
    for connection in active_connections:
        await connection.send_text(message)
    return {"message": "Notification sent"}
