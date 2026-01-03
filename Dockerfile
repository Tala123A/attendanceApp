# Use official PHP image with CLI
FROM php:8.2-cli

# Install mysqli extension so PHP can connect to MySQL
RUN docker-php-ext-install mysqli

# Set working directory inside the container
WORKDIR /app

# Copy all project files into the container
COPY . /app

# Expose port 8080
EXPOSE 8080

# Start PHP built-in server
CMD ["php", "-S", "0.0.0.0:8080", "-t", "."]
