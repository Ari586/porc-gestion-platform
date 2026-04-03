/* eslint-disable no-console */
const express = require('express');
const http = require('http');
const cors = require('cors');
const { Server } = require('socket.io');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => {
  res.status(200).json({
    ok: true,
    uptimeSec: Math.round(process.uptime()),
    connectedUsers: connectedUsers.size,
    rooms: rooms.size,
  });
});

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

// socket.id -> { userId, username, status, connectedAt }
const connectedUsers = new Map();
// roomId -> Set(socket.id)
const rooms = new Map();

function leaveAllRoomsForSocket(socketId) {
  for (const [roomId, clients] of rooms.entries()) {
    if (!clients.has(socketId)) continue;
    clients.delete(socketId);
    if (clients.size === 0) {
      rooms.delete(roomId);
    }
  }
}

io.on('connection', (socket) => {
  console.log(`[+] New socket connected: ${socket.id}`);

  socket.on('register_user', (payload = {}) => {
    const userId = String(payload.userId || '').trim();
    const username = String(payload.username || '').trim() || 'Anonymous';
    if (!userId) {
      return;
    }
    connectedUsers.set(socket.id, {
      userId,
      username,
      status: 'online',
      connectedAt: new Date().toISOString(),
    });
    io.emit('user_status_change', { userId, status: 'online' });
    console.log(`User registered: ${username} (${userId}) -> ${socket.id}`);
  });

  socket.on('join_room', (rawRoomId) => {
    const roomId = String(rawRoomId || '').trim();
    if (!roomId) {
      return;
    }
    socket.join(roomId);
    if (!rooms.has(roomId)) {
      rooms.set(roomId, new Set());
    }
    rooms.get(roomId).add(socket.id);
    console.log(`${socket.id} joined room: ${roomId}`);
  });

  socket.on('send_message', (payload = {}) => {
    const roomId = String(payload.roomId || '').trim();
    const senderId = String(payload.senderId || '').trim();
    const text = String(payload.text || '').trim();
    if (!roomId || !text) {
      return;
    }

    const message = {
      id: `MSG-${Date.now()}-${Math.floor(Math.random() * 100000)}`,
      roomId,
      senderId: senderId || socket.id,
      text,
      timestamp: new Date().toISOString(),
    };

    socket.to(roomId).emit('receive_message', message);
    console.log(`[MSG] room=${roomId} sender=${message.senderId} text=${text}`);
  });

  socket.on('webrtc_offer', (payload = {}) => {
    const roomId = String(payload.roomId || '').trim();
    if (!roomId || !payload.offer) {
      return;
    }
    socket.to(roomId).emit('webrtc_offer', {
      offer: payload.offer,
      senderId: socket.id,
    });
  });

  socket.on('webrtc_answer', (payload = {}) => {
    const roomId = String(payload.roomId || '').trim();
    if (!roomId || !payload.answer) {
      return;
    }
    socket.to(roomId).emit('webrtc_answer', {
      answer: payload.answer,
      senderId: socket.id,
    });
  });

  socket.on('webrtc_ice_candidate', (payload = {}) => {
    const roomId = String(payload.roomId || '').trim();
    if (!roomId || !payload.candidate) {
      return;
    }
    socket.to(roomId).emit('webrtc_ice_candidate', {
      candidate: payload.candidate,
      senderId: socket.id,
    });
  });

  socket.on('webrtc_hangup', (payload = {}) => {
    const roomId = String(payload.roomId || '').trim();
    if (!roomId) {
      return;
    }
    socket.to(roomId).emit('webrtc_hangup', {
      senderId: socket.id,
      timestamp: new Date().toISOString(),
    });
  });

  socket.on('disconnect', () => {
    const user = connectedUsers.get(socket.id);
    if (user) {
      io.emit('user_status_change', {
        userId: user.userId,
        status: 'offline',
        lastSeen: new Date().toISOString(),
      });
      connectedUsers.delete(socket.id);
      console.log(`[-] User disconnected: ${user.username} (${socket.id})`);
    } else {
      console.log(`[-] Socket disconnected: ${socket.id}`);
    }
    leaveAllRoomsForSocket(socket.id);
  });
});

const port = Number(process.env.PORT || 3001);
server.listen(port, '0.0.0.0', () => {
  console.log(`Socket server running on port ${port}`);
  console.log(`Health: http://localhost:${port}/health`);
});
