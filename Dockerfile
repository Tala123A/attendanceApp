# Use official PHP image
FROM php:8.2-cli

# Set working directory
WORKDIR /app

# Copy all files into container
COPY . /app

# Expose port 8080
EXPOSE 8080

# Start PHP built-in server
CMD ["php", "-S", "0.0.0.0:8080", "-t", "."]
