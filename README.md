# 🚨 Alarme Inteligente com Sensor de Proximidade

## 📌 Descrição do Projeto
Este projeto consiste em um sistema de **alarme inteligente** que utiliza um **sensor de proximidade** para detectar objetos próximos ao dispositivo móvel. Quando o sensor é ativado:

1. **Uma foto é capturada automaticamente** usando a câmera frontal do celular.
2. **A imagem é enviada para o servidor FastAPI**.
3. **Um alarme sonoro é ativado no servidor** e continua tocando até ser desativado manualmente pelo aplicativo.

O sistema é implementado usando **Flutter para o aplicativo móvel** e **FastAPI para o servidor backend**, garantindo uma comunicação eficiente via **WebSockets (Socket.IO) e HTTP (REST API)**.

---

## ⚙️ Tecnologias Utilizadas
- **Flutter** (Dart) → Aplicativo móvel
- **FastAPI** (Python) → Servidor
- **Socket.IO** → Comunicação em tempo real
- **HTTP REST API** → Upload de imagens
- **Pygame** → Reproduzir som do alarme
- **Proximity Sensor** → Sensor de proximidade do celular
- **Camera** → Captura de imagem automática

---

## 🛠️ Instruções de Instalação e Execução

### **1️⃣ Configurar o Servidor (FastAPI)**
#### **📌 Requisitos**
- Python **3.10+**
- Pip instalado

#### **📌 Instalar Dependências**
```bash
pip install fastapi uvicorn socketio python-multipart pygame
```

#### **📌 Executar o Servidor**
```bash
uvicorn servidor:app --host 0.0.0.0 --port 8000 --reload
```

#### **📌 Endpoints da API**
| Método | Endpoint            | Descrição |
|--------|--------------------|------------|
| POST   | `/upload-image/`   | Faz o upload da imagem capturada |
| POST   | `/stop-alarm/`     | Para o alarme sonoro |

---

### **2️⃣ Configurar o Aplicativo (Flutter)**
#### **📌 Requisitos**
- Flutter **3.10+**
- Android Studio ou VS Code
- Celular com sensor de proximidade

#### **📌 Instalar Dependências do Flutter**
```bash
flutter pub get
```

#### **📌 Executar o Aplicativo no Celular**
```bash
flutter run
```

> **⚠️ Observação:** Certifique-se de que o **servidor FastAPI** está rodando antes de testar o aplicativo!

---

## 📡 Explicação do Funcionamento
### **1️⃣ Aplicativo Móvel (Flutter)**
- **Inicia um WebSocket** para enviar alertas ao servidor.
- **Monitora o sensor de proximidade** para detectar objetos próximos.
- **Captura uma imagem automaticamente** ao detectar movimento.
- **Envia a imagem para o servidor** via requisição HTTP POST.
- **Permite parar o alarme** pressionando um botão.

### **2️⃣ Servidor Backend (FastAPI + Socket.IO)**
- **Recebe alertas do WebSocket** e toca o alarme.
- **Armazena imagens enviadas pelo aplicativo**.
- **Gerencia a reprodução do alarme**, garantindo que ele possa ser desativado manualmente.

---

## 📸 Capturas de Tela

![Imagem de Exemplo](alert_server/images/CAP237331591145893780.jpg)
---

## 📂 Estrutura do Código
```
SD_TRABALHO02/
│── alert_app/          # Aplicação Flutter
│   ├── lib/            # Código principal
│   │   ├── screens/    # Telas do app
│   │   │   ├── my_home_page.dart
│   │   ├── main.dart   # Entrada do app
│   ├── pubspec.yaml    # Dependências do Flutter
│── alert_server/       # Servidor FastAPI
│   ├── servidor.py     # Código principal do servidor
│   ├── images/         # Diretório onde as imagens são salvas
│   ├── alarm.mp3       # Som do alarme
│── LICENSE            # Licença do projeto
│── README.md          # Documentação
 ┗ 📜 README.md        # Documentação do projeto
```

---

Este projeto demonstra como **sensores, WebSockets e IA podem ser usados para criar um sistema de alarme inteligente**, garantindo **segurança e resposta rápida** em tempo real! 🚀🔥


