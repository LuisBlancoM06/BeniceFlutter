# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:3.29.2 AS build

WORKDIR /app

# Copy dependency files first for better caching
COPY pubspec.yaml pubspec.lock* ./

# Get dependencies
RUN flutter pub get

# Copy rest of the project
COPY . .

# Build Flutter web (release)
RUN flutter build web --release --base-href="/"

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built web app from build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
