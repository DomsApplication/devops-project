# Use Node.js image
FROM node:18

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json package-lock.json ./
RUN npm install
ENV NODE_OPTIONS="--openssl-legacy-provider"
# Copy the rest of the frontend code
COPY . .

# Build the React app
RUN npm run build

# Install and use `serve` to serve the built frontend
RUN npm install -g serve

# Expose port
EXPOSE 80

# Start frontend
CMD ["serve", "-s", "build", "-l", "80", "--no-clipboard"]
