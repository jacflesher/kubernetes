
### Angular with NGINX Dockerfile
FROM node:18-slim AS build
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build
# Serve application using NGINX Server
FROM nginx:alpine
COPY --from=build /app/dist/angular-hello-world/ /usr/share/nginx/html
EXPOSE 80

### Angular Vanilla Dockerfile
#FROM node:18-slim AS build
#WORKDIR /usr/src/app
#COPY package*.json ./
#RUN npm install
#COPY . ./
#RUN npm run build
#EXPOSE 4200
#CMD [ "npm", "start" ]
