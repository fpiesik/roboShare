/**
 * server.js
 * 
 * 1) HTTP-Server auf Port 8080, der index.html ausliefert.
 * 2) WebSocket-Server, um Clients Tick-Daten zu schicken.
 * 3) UDP-Socket (Port 6000), um Tick-Daten zu empfangen 
 *    und an WebSocket-Clients zu broadcasten.
 */

const http = require('http');
const fs = require('fs');
const path = require('path');
const WebSocket = require('ws');
const dgram = require('dgram');

// HTTP-Server (Port 8080)
const server = http.createServer((req, res) => {
  if (req.url === '/') {
    // index.html ausliefern
    fs.readFile(path.join(__dirname, 'index.html'), (err, data) => {
      if (err) {
        res.writeHead(500);
        return res.end('Fehler beim Laden von index.html');
      }
      res.writeHead(200, { 'Content-Type': 'text/html' });
      res.end(data);
    });
  } else {
    // Hier könntest du ggf. noch weitere Dateien 
    // (z.B. CSS, Bilder, JS) ausliefern
    res.writeHead(404);
    res.end('Not Found');
  }
});

// WebSocket-Server an das HTTP-Server-Objekt binden
const wss = new WebSocket.Server({ server });

wss.on('connection', (ws) => {
  console.log('Neuer WebSocket-Client verbunden');
  // Optional: ws.send('Willkommen am Timeline-Server!');
});

/** 
 * Hilfsfunktion: An alle WS-Clients senden 
 */
function broadcastToWebSockets(msg) {
  wss.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(msg);
    }
  });
}

// HTTP-Server starten (Port 8080)
server.listen(8080, () => {
  console.log('HTTP- & WebSocket-Server läuft auf Port 8080');
});

// UDP-Socket (Port 6000)
const udpSocket = dgram.createSocket('udp4');

udpSocket.on('message', (msg, rinfo) => {
  console.log(`UDP von ${rinfo.address}:${rinfo.port} => ${msg.toString()}`);
  // An WebSocket-Browser verteilen
  broadcastToWebSockets(msg.toString());
});

udpSocket.on('listening', () => {
  const address = udpSocket.address();
  console.log(`UDP-Socket lauscht auf Port ${address.port}`);
});

udpSocket.bind(8099);
