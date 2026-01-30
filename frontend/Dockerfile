# Use --platform=$BUILDPLATFORM to run Node natively on your Mac
FROM --platform=$BUILDPLATFORM docker.io/library/node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# The final stage will be the target architecture (amd64)
FROM --platform=linux/amd64 docker.io/library/nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]