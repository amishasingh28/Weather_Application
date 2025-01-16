# Node.js runtime as a parent image
FROM node:18-alpine

# Setting the working directory in the container
WORKDIR /app

# Copying package.json and package-lock.json to the container
COPY package.json package-lock.json ./

# Installing project dependencies
RUN npm ci

# Copying the rest of the application code to the container
COPY . .

# Building the application for production
RUN npm run build

# Exposing the port the app runs on (default for Vite is 5173)
EXPOSE 5173

# Starting the application
CMD ["npm", "run", "preview"]

