# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:3.35.6 AS build

# Build arguments (set these in Coolify > Build Variables)
ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY
ARG SUPABASE_SERVICE_ROLE_KEY=""
ARG STRIPE_SECRET_KEY=""
ARG STRIPE_PUBLISHABLE_KEY=""
ARG STRIPE_WEBHOOK_SECRET=""
ARG RESEND_API_KEY=""
ARG FROM_EMAIL="ventas@beniceflutter.com"
ARG PUBLIC_SITE_URL="https://victoriafp.online"
ARG CLOUDINARY_CLOUD_NAME=""
ARG CLOUDINARY_API_KEY=""
ARG CLOUDINARY_API_SECRET=""
ARG GOOGLE_PLACES_API_KEY=""

WORKDIR /app

# Copy dependency files first for better caching
COPY pubspec.yaml pubspec.lock* ./

# Get dependencies
RUN flutter pub get

# Copy rest of the project
COPY . .

# Generate .env file from build arguments
RUN echo "SUPABASE_URL=${SUPABASE_URL}" > .env \
    && echo "SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}" >> .env \
    && echo "SUPABASE_SERVICE_ROLE_KEY=${SUPABASE_SERVICE_ROLE_KEY}" >> .env \
    && echo "STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY}" >> .env \
    && echo "STRIPE_PUBLISHABLE_KEY=${STRIPE_PUBLISHABLE_KEY}" >> .env \
    && echo "STRIPE_WEBHOOK_SECRET=${STRIPE_WEBHOOK_SECRET}" >> .env \
    && echo "RESEND_API_KEY=${RESEND_API_KEY}" >> .env \
    && echo "FROM_EMAIL=${FROM_EMAIL}" >> .env \
    && echo "PUBLIC_SITE_URL=${PUBLIC_SITE_URL}" >> .env \
    && echo "CLOUDINARY_CLOUD_NAME=${CLOUDINARY_CLOUD_NAME}" >> .env \
    && echo "CLOUDINARY_API_KEY=${CLOUDINARY_API_KEY}" >> .env \
    && echo "CLOUDINARY_API_SECRET=${CLOUDINARY_API_SECRET}" >> .env \
    && echo "GOOGLE_PLACES_API_KEY=${GOOGLE_PLACES_API_KEY}" >> .env

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
