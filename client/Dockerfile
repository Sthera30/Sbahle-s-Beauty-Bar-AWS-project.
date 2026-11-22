
# Start on an image that already has node 22 on a tiny linux system and nickname it builder
FROM node:22-alpine AS builder

# Docker will create a folder called app
WORKDIR /app 

# It will copy our package.json file and our package-lock.json file
COPY package*.json ./ 

# It will read our Package.json file and install all the dependencies needed to run our react app
RUN npm install

# It will copy our entire react app into the /app folder
COPY . .

# Vite will create a folder called dist, which turns our React code into plain HTML, CSS and javaScript
RUN npm run build

# Start on a brand new stage that already has nginx on a tiny linux system
FROM nginx:alpine

# Go to builder, take this finished dist folder into nginx's display folder
COPY --from=builder /app/dist /usr/share/nginx/html

# Our container will be listening on port 80
EXPOSE 80

# start nginx in the foreground so that the container keeps running
CMD ["nginx", "-g", "daemon off;"]

# Docker packages your App with everything it needs (Node, Nginx, Libraries) so that it behaves the same everywhere. 
# Your image is the package.
# Your container is your image running