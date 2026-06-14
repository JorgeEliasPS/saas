# GenaAPI - WhatsApp Web Gateway

GenaAPI é um gateway de WhatsApp Web moderno, leve, estável e escalável construído com **Node.js**, **TypeScript**, **Fastify**, **Baileys** e **Redis**. Inspirada em soluções como Evolution API e WAHA, a GenaAPI foi desenhada desde o início para dispensar banco de dados relacionais pesados (como PostgreSQL) e delegar todo o armazenamento de credenciais diretamente ao Redis.

---

## 🚀 Funcionalidades Principais

* **Arquitetura Multi-instância**: Crie, controle e exclua conexões de WhatsApp Web dinamicamente por requisições REST.
* **Persistência de Sessão no Redis**: Sem arquivos locais bagunçados nas instâncias — as chaves de ruído e tokens de pareamento ficam em cache distribuído no Redis.
* **Human Delay Engine**: Simule comportamentos humanos configurando ações como "Digitando" e "Gravando Áudio" com tempos definidos antes de disparar textos ou mídias.
* **Transcodificação Automática de Áudio**: Envie qualquer formato (MP3, WAV, OGG) e a API converte nativamente para o codec OGG-Opus padrão do WhatsApp (áudio PTT com botão azul).
* **Integração com n8n / Automações**: Webhooks e respostas limpas prontas para integrar com ferramentas de workflows.
* **Dashboard Flat Design**: Painel SPA moderno, rápido e bonito construído em Vanilla CSS/JS com visualização em tempo real de logs via WebSocket.
* **OpenAPI/Swagger**: Documentação interativa disponível por padrão em `/swagger`.

---

## ⚙️ Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto baseado no `.env.example`:

```env
PORT=3000
HOST=0.0.0.0
API_KEY=sua_chave_secreta_aqui

REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

LOG_LEVEL=info
UPLOADS_DIR=./uploads
SESSIONS_DIR=./sessions
```

---

## 📦 Execução com Docker (Recomendado para VPS/EasyPanel)

A GenaAPI possui suporte nativo a Docker e Docker Compose, instalando automaticamente o **FFmpeg** e isolando o Redis de cache.

### Inicialização Rápida

1. Certifique-se de ter o Docker instalado.
2. Execute o comando:
   ```bash
   docker-compose up -d --build
   ```
3. A API estará disponível em `http://localhost:3000`.
4. O Dashboard Flat Design será servido em `http://localhost:3000/`.
5. A documentação interativa Swagger estará em `http://localhost:3000/swagger`.

---

## 🛠️ Execução Local (Desenvolvimento)

Caso queira executar localmente fora de containers:

### Pré-requisitos
* Node.js v18+
* Redis rodando localmente
* FFmpeg instalado no sistema operacional e acessível no PATH

### Instalação de Dependências
```bash
npm install
```

### Compilar e Rodar
```bash
# Rodar em modo de desenvolvimento
npm run dev

# Compilar para produção
npm run build
npm start
```

---

## 🚀 Gerenciamento de Produção com PM2

Para rodar em VPS com gerenciamento de processos e balanceamento em cluster:

```bash
# Compilar projeto
npm run build

# Inicializar cluster configurado
pm2 start ecosystem.config.js
```

---

## 🌐 Exemplos de Integração & Requisições

> **Nota**: Todas as requisições privadas exigem o cabeçalho `x-api-key` com o valor definido na `.env`.

### 1. Criar e Conectar Instância
**POST** `/instance/create`
```json
{
  "instance": "vendas"
}
```

**POST** `/instance/connect`
```json
{
  "instance": "vendas"
}
```

*Obtenha o QR Code em Base64 para exibir na sua aplicação:*
**GET** `/instance/qrcode?instance=vendas`

---

### 2. Disparar Texto com Human Delay Engine
O recurso simula o usuário digitando por um determinado tempo antes de enviar a mensagem de fato.

**POST** `/human/send`
```json
{
  "instance": "vendas",
  "to": "5511999999999",
  "text": "Olá! Segue a resposta solicitada.",
  "typing": true,
  "typingTime": 4
}
```

---

### 3. Enviar Áudio MP3 convertendo para Voz PTT (Gravação)
Transcodifica o arquivo MP3 da URL externa em áudio do tipo gravado na hora.

**POST** `/message/voice`
```json
{
  "instance": "vendas",
  "to": "5511999999999",
  "audioUrl": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
  "delay": {
    "recording": true,
    "recordingTime": 6
  }
}
```

---

### 4. Integração de Webhook com n8n
Configure um webhook na GenaAPI para enviar eventos em tempo real diretamente para o seu fluxo de automação do n8n:

**POST** `/webhook/set`
```json
{
  "instance": "vendas",
  "url": "https://seu-n8n.com/webhook/c291b8a3-289c-45bc"
}
```

#### Exemplo de Payload Enviado ao n8n (Mensagem Recebida):
```json
{
  "instance": "vendas",
  "event": "message.received",
  "timestamp": "2026-06-14T21:00:00.000Z",
  "data": {
    "key": {
      "remoteJid": "5511999999999@s.whatsapp.net",
      "fromMe": false,
      "id": "A4F8B7D2E5"
    },
    "message": {
      "conversation": "Qual o valor do plano?"
    },
    "messageTimestamp": 1718398800
  }
}
```

---

## 🔌 Conexão WebSocket
A GenaAPI possui um servidor WebSocket unificado para receber todos os eventos de mensagens e conexões em tempo real.

**Endpoint WS:**
```text
ws://localhost:3000/ws?key=sua_chave_secreta_aqui
```

#### Estrutura de Mensagem WebSocket (QR Code Gerado):
```json
{
  "instance": "vendas",
  "event": "qrcode.updated",
  "timestamp": "2026-06-14T21:01:00.000Z",
  "data": {
    "qr": "data:image/png;base64,iVBORw0KGgoAAA..."
  }
}
```

---

## 📄 Licença

Este projeto é disponibilizado sob a licença MIT.
