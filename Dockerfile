FROM node:20-alpine

WORKDIR /app

# Copy server dependencies and install production packages
COPY server/package*.json ./server/
WORKDIR /app/server
RUN npm install --omit=dev

# Copy server source code and compiled Flutter Web distribution
WORKDIR /app
COPY server/ ./server/
COPY build/web ./build/web

ENV PORT=3000
EXPOSE 3000

CMD ["node", "server/index.js"]
