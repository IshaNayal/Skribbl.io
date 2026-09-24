const express = require("express");
var http = require("http");
const app = express();
const port = process.env.PORT || 3000;
var server = http.createServer(app);
const dns = require("dns");
const mongoose = require("mongoose");
const MongoRoom = require('./models/Room');

var io = require("socket.io")(server, {
  allowEIO3: true,
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});
const getWord = require('./api/getWord');

// Helper to generate a 6-character alphanumeric room code
function generateRoomCode(length = 6) {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

// middleware
app.use(express.json());

// In-Memory store for rooms when MongoDB is not connected
const memoryRooms = new Map();

class MemoryRoom {
  constructor(data = {}) {
    this.name = (data.name || '').toUpperCase();
    this.word = data.word || '';
    this.occupancy = data.occupancy || 4;
    this.maxRounds = data.maxRounds || 2;
    this.currentRound = data.currentRound || 1;
    this.players = data.players ? [...data.players] : [];
    this.isJoin = data.isJoin !== undefined ? data.isJoin : true;
    this.turn = data.turn || null;
    this.turnIndex = data.turnIndex || 0;
  }

  async save() {
    this.name = (this.name || '').toUpperCase();
    memoryRooms.set(this.name, this);
    return this;
  }

  static async findOne(query) {
    if (query.name) {
      const target = String(query.name).toUpperCase();
      return memoryRooms.get(target) || null;
    }
    if (query['players.socketID']) {
      const socketId = query['players.socketID'];
      for (const r of memoryRooms.values()) {
        if (r.players.some((p) => p.socketID === socketId)) {
          return r;
        }
      }
      return null;
    }
    return null;
  }

  static async find(query) {
    if (query.name) {
      const target = String(query.name).toUpperCase();
      const r = memoryRooms.get(target);
      return r ? [r] : [];
    }
    return Array.from(memoryRooms.values());
  }
}

function getRoomStorage() {
  if (mongoose.connection.readyState === 1) {
    return MongoRoom;
  }
  return MemoryRoom;
}

function createRoomInstance(data = {}) {
  const Storage = getRoomStorage();
  return new Storage(data);
}

const path = require("path");
const fs = require("fs");
const buildPath = path.join(__dirname, "../build/web");

if (fs.existsSync(buildPath)) {
  app.use(express.static(buildPath));
  console.log('Serving Flutter Web app from:', buildPath);
}

const audioPath = path.join(__dirname, "../assets/audio");
if (fs.existsSync(audioPath)) {
  app.use('/assets/audio', express.static(audioPath));
  app.use('/assets/assets/audio', express.static(audioPath));
  app.use('/audio', express.static(audioPath));
}

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    storage: mongoose.connection.readyState === 1 ? 'MongoDB' : 'In-Memory',
    message: 'Skribbl_io server is running'
  });
});

// Fallback to Flutter Web app index.html for SPA routing
app.use((req, res) => {
  const indexPath = path.join(buildPath, 'index.html');
  if (fs.existsSync(indexPath)) {
    res.sendFile(indexPath);
  } else {
    res.json({
      status: 'ok',
      storage: mongoose.connection.readyState === 1 ? 'MongoDB' : 'In-Memory',
      message: 'Skribbl_io server is running'
    });
  }
});

// Connect to MongoDB if MONGODB_URI is provided
dns.setServers(["8.8.8.8", "1.1.1.1"]);
const DB = process.env.MONGODB_URI;

if (!DB) {
  console.log('MONGODB_URI is not set; running with in-memory room store.');
} else {
  mongoose.connect(DB, { serverSelectionTimeoutMS: 5000 }).then(() => {
    console.log('MongoDB Connection Successful!');
  }).catch((e) => {
    console.warn('MongoDB connection failed:', e.message);
    console.log('Falling back to in-memory room store.');
  });
}

io.on('connection', (socket) => {
  console.log('Player connected:', socket.id);

  // CREATE GAME CALLBACK
  socket.on('create-game', async ({ nickname, name, occupancy, maxRounds }) => {
    try {
      occupancy = Number(occupancy);
      maxRounds = Number(maxRounds);
      let roomCode = (name || generateRoomCode()).toString().trim().toUpperCase();
      let playerNickname = (nickname || '').toString().trim();

      if (!playerNickname || !roomCode || !Number.isInteger(occupancy) || occupancy < 1 ||
        !Number.isInteger(maxRounds) || maxRounds < 1) {
        socket.emit('notCorrectGame', 'Please provide valid room details');
        return;
      }
      const existingRoom = await getRoomStorage().findOne({ name: roomCode });
      if (existingRoom) {
        socket.emit('notCorrectGame', 'Room with that code already exists!');
        return;
      }
      let room = createRoomInstance();
      const word = getWord();
      room.word = word;
      room.name = roomCode;
      room.occupancy = occupancy;
      room.maxRounds = maxRounds;

      let player = {
        socketID: socket.id,
        nickname: playerNickname,
        isPartyLeader: true,
        points: 0,
      };
      room.players.push(player);
      room.turn = player;
      if (room.players.length >= occupancy) {
        room.isJoin = false;
      }
      room = await room.save();
      socket.join(roomCode);
      io.to(roomCode).emit('updateRoom', room);
    } catch (err) {
      console.error('Error in create-game:', err);
    }
  });

  // JOIN GAME CALLBACK
  socket.on('join-game', async ({ nickname, name }) => {
    try {
      let roomCode = (name || '').toString().trim().toUpperCase();
      let playerNickname = (nickname || '').toString().trim();

      if (!playerNickname || !roomCode) {
        socket.emit('notCorrectGame', 'Please enter a nickname and room code');
        return;
      }
      let room = await getRoomStorage().findOne({ name: roomCode });
      if (!room) {
        socket.emit('notCorrectGame', 'Please enter a valid room code');
        return;
      }

      if (room.isJoin && room.players.length < room.occupancy) {
        let player = {
          socketID: socket.id,
          nickname: playerNickname,
          points: 0,
        };
        room.players.push(player);
        socket.join(roomCode);

        if (room.players.length === room.occupancy) {
          room.isJoin = false;
        }
        if (!room.turn) {
          room.turn = room.players[room.turnIndex || 0];
        }
        room = await room.save();
        io.to(roomCode).emit('updateRoom', room);
      } else {
        socket.emit('notCorrectGame', 'The game is in progress, please try later!');
      }
    } catch (err) {
      console.error('Error in join-game:', err);
    }
  });

  socket.on('msg', async (data) => {
    try {
      const roomCode = (data.roomName || '').toString().trim().toUpperCase();
      if (data.msg === data.word) {
        let rooms = await getRoomStorage().find({ name: roomCode });
        if (!rooms.length) return;
        let room = rooms[0];
        let userPlayer = room.players.filter(
          (player) => player.nickname === data.username
        );
        if (!userPlayer.length) return;
        if (data.timeTaken !== 0) {
          userPlayer[0].points += Math.round((200 / data.timeTaken) * 10);
        }
        room = await room.save();
        io.to(roomCode).emit('msg', {
          username: data.username,
          msg: 'Guessed it!',
          guessedUserCtr: data.guessedUserCtr + 1,
        });
        socket.emit('closeInput', "");
      } else {
        io.to(roomCode).emit('msg', {
          username: data.username,
          msg: data.msg,
          guessedUserCtr: data.guessedUserCtr,
        });
      }
    } catch (err) {
      console.error('Error in msg:', err);
    }
  });

  socket.on('change-turn', async (name) => {
    try {
      const roomCode = (name || '').toString().trim().toUpperCase();
      let room = await getRoomStorage().findOne({ name: roomCode });
      if (!room || room.players.length === 0) return;
      let idx = room.turnIndex;
      if (idx + 1 === room.players.length) {
        room.currentRound += 1;
      }
      if (room.currentRound <= room.maxRounds) {
        const word = getWord();
        room.word = word;
        room.turnIndex = (idx + 1) % room.players.length;
        room.turn = room.players[room.turnIndex];
        room = await room.save();
        io.to(roomCode).emit('change-turn', room);
      } else {
        io.to(roomCode).emit("show-leaderboard", room.players);
      }
    } catch (err) {
      console.error('Error in change-turn:', err);
    }
  });

  socket.on('updateScore', async (name) => {
    try {
      const roomCode = (name || '').toString().trim().toUpperCase();
      const room = await getRoomStorage().findOne({ name: roomCode });
      if (!room) return;
      io.to(roomCode).emit('updateScore', room);
    } catch (err) {
      console.error('Error in updateScore:', err);
    }
  });

  // White board sockets
  socket.on('paint', ({ details, roomName }) => {
    const code = (roomName || '').toString().trim().toUpperCase();
    io.to(code).emit('points', { details: details });
  });

  // Color socket
  socket.on('color-change', ({ color, roomName }) => {
    const code = (roomName || '').toString().trim().toUpperCase();
    io.to(code).emit('color-change', color);
  });

  // Stroke Socket
  socket.on('stroke-width', ({ value, roomName }) => {
    const code = (roomName || '').toString().trim().toUpperCase();
    io.to(code).emit('stroke-width', value);
  });

  // Clear Screen
  socket.on('clean-screen', (roomName) => {
    const code = (roomName || '').toString().trim().toUpperCase();
    io.to(code).emit('clear-screen', '');
  });

  socket.on('disconnect', async () => {
    try {
      let room = await getRoomStorage().findOne({ "players.socketID": socket.id });
      if (!room) return;
      for (let i = 0; i < room.players.length; i++) {
        if (room.players[i].socketID === socket.id) {
          room.players.splice(i, 1);
          break;
        }
      }
      room = await room.save();
      if (room.players.length === 1) {
        socket.broadcast.to(room.name).emit('show-leaderboard', room.players);
      } else {
        socket.broadcast.to(room.name).emit('user-disconnected', room);
      }
    } catch (err) {
      console.error('Error in disconnect:', err);
    }
  });
});

server.listen(port, () => {
  console.log('Server started and running on port ' + port);
});

server.on('error', (error) => {
  if (error.code === 'EADDRINUSE') {
    console.error(`Port ${port} is already in use. Set PORT to use another port.`);
    return;
  }
  console.error('Server failed to start:', error.message);
});