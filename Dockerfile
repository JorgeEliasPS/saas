FROM node:20-alpine

# Install FFmpeg and system dependencies
RUN apk add --no-cache ffmpeg python3 make g++

WORKDIR /app

# Copy package configurations
COPY package*.json tsconfig.json ./

# Install packages
RUN npm ci

# Copy codebase
COPY src/ ./src/

# Compile TypeScript
RUN npm run build

# Remove development packages to reduce size
RUN npm prune --production

# Create required runtime directories
RUN mkdir -p sessions uploads logs

# Expose server port
EXPOSE 3000

# Set environment variables
ENV NODE_ENV=production

CMD ["npm", "start"]
