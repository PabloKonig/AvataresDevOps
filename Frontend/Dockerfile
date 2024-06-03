FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
ENV VITE_HOST=0.0.0.0
ENV VITE_PORT=5000
EXPOSE 5173
CMD ["npm", "run", "dev"]