FROM node:18-alpine
WORKDIR /app
COPY package.json ./
RUN npm install
COPY server ./server
COPY web ./web
COPY prisma ./prisma
COPY .env ./
RUN npm --prefix web install && npm --prefix server install && npx prisma generate
RUN npm --prefix web run build
EXPOSE 3000
EXPOSE 3001
CMD npm --prefix server run start & npm --prefix web run start
