FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY tailwind.config.js postcss.config.js ./

# Install dependencies
RUN npm ci

# Copy source
COPY src ./src
COPY index.html ./
COPY vite.config.js ./

# Build for production
RUN npm run build -- --mode production

# Production server
FROM node:18-alpine

WORKDIR /app

# Install serve to run the built app
RUN npm install -g serve

# Copy built app from builder
COPY --from=builder /app/dist ./dist

EXPOSE 3000

CMD ["serve", "-s", "dist", "-l", "3000"]
