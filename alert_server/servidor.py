from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import socketio
import os
import threading
import pygame
from pathlib import Path

app = FastAPI()

# Configurações do CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Permite todas as origens
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configurações do servidor
ALARM_SOUND = "alarm.mp3"  # Som do alarme
IMAGE_DIR = "intruders"

# Verifica se o diretório de imagens existe
Path(IMAGE_DIR).mkdir(parents=True, exist_ok=True)

# Inicializa pygame para tocar o alarme
pygame.mixer.init()

# Configuração do Socket.IO
sio = socketio.AsyncServer(async_mode='asgi', cors_allowed_origins='*')
app.mount("/socket.io", socketio.ASGIApp(sio))

def play_alarm():
    """Função para tocar o alarme."""
    print("🔊 Tocando alarme...")
    try:
        if not os.path.exists(ALARM_SOUND):
            print(f"❌ Arquivo de som não encontrado: {ALARM_SOUND}")
            return

        pygame.mixer.music.load(ALARM_SOUND)
        pygame.mixer.music.play(-1)  # Reproduzir em loop
    except Exception as e:
        print(f"❌ Erro ao tocar alarme: {e}")

@sio.event
async def connect(sid, environ):
    print(f"✅ Cliente conectado: {sid}")

@sio.event
async def disconnect(sid):
    print(f"❌ Cliente desconectado: {sid}")

@sio.event
async def alert(sid, data):
    print(f"🚨 Alerta recebido: {data}")
    threading.Thread(target=play_alarm).start()

@app.post("/upload-image/")
async def upload_image(file: UploadFile = File(...)):
    print(f"📥 Recebendo imagem: {file.filename}, tipo: {file.content_type}")
    if not file.content_type.startswith("image/"):
        print("❌ O arquivo enviado não é uma imagem.")
        raise HTTPException(status_code=400, detail="O arquivo enviado não é uma imagem.")

    file_path = os.path.join(IMAGE_DIR, file.filename)
    print(f"📤 Salvando imagem em: {file_path}")

    try:
        with open(file_path, "wb") as f:
            f.write(file.file.read())
        print("✅ Imagem salva com sucesso!")
    except Exception as e:
        print(f"❌ Erro ao salvar a imagem: {e}")
        raise HTTPException(status_code=500, detail=f"Erro ao salvar a imagem: {e}")

    return {"message": "Imagem salva!", "path": file_path}

@app.post("/stop-alarm/")
def stop_alarm():
    """Endpoint para parar o alarme."""
    if pygame.mixer.get_init() is None:
        raise HTTPException(status_code=400, detail="O alarme não está ativo.")

    pygame.mixer.music.stop()
    print("🔇 Alarme desativado!")
    return {"message": "Alarme desativado."}