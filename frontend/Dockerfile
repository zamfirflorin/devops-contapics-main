# frontend/Dockerfile
FROM docker.io/library/node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
ENV VITE_BACKEND_URL=http://localhost:8080
RUN npm run build
 
FROM docker.io/library/nginx:alpine
#RUN addgroup -S florin && adduser -S florin -G florin
#     mkdir -p /var/cache/nginx /var/run/nginx /var/log/nginx && \
#     chown -R florin:florin /var/cache/nginx /var/run/nginx /var/log/nginx /etc/nginx/conf.d

#USER florin
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]