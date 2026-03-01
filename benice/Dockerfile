# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:3.35.6 AS build

# Build arguments - names must match Coolify environment variables
ARG PUBLIC_SUPABASE_URL=""
ARG PUBLIC_SUPABASE_ANON_KEY=""
ARG SUPABASE_SERVICE_ROLE_KEY=""
ARG STRIPE_SECRET_KEY=""
ARG STRIPE_PUBLISHABLE_KEY=""
ARG STRIPE_WEBHOOK_SECRET=""
ARG RESEND_API_KEY=""
ARG FROM_EMAIL="onboarding@resend.dev"
ARG PUBLIC_SITE_URL="https://benicetiendanimal.victoriafp.online"
ARG GOOGLE_PLACES_API_KEY=""

WORKDIR /app

# Copy dependency files first for better caching
COPY pubspec.yaml pubspec.lock* ./

# Get dependencies
RUN flutter pub get

# Copy rest of the project
COPY . .

# Generate .env file from build arguments
# Note: app_constants.dart reads SUPABASE_URL / SUPABASE_ANON_KEY (without PUBLIC_ prefix)
RUN echo "SUPABASE_URL=${PUBLIC_SUPABASE_URL}" > .env \
    && echo "SUPABASE_ANON_KEY=${PUBLIC_SUPABASE_ANON_KEY}" >> .env \
    && echo "SUPABASE_SERVICE_ROLE_KEY=${SUPABASE_SERVICE_ROLE_KEY}" >> .env \
    && echo "STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY}" >> .env \
    && echo "STRIPE_PUBLISHABLE_KEY=${STRIPE_PUBLISHABLE_KEY}" >> .env \
    && echo "STRIPE_WEBHOOK_SECRET=${STRIPE_WEBHOOK_SECRET}" >> .env \
    && echo "RESEND_API_KEY=${RESEND_API_KEY}" >> .env \
    && echo "FROM_EMAIL=${FROM_EMAIL}" >> .env \
    && echo "PUBLIC_SITE_URL=${PUBLIC_SITE_URL}" >> .env \
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
