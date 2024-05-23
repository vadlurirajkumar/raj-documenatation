FROM node:22

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# Build the Next.js application
RUN npm run build

EXPOSE 3000

# Define the command to run your Node.js application
CMD ["npm", "start"]

