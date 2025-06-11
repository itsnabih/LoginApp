# Gunakan nginx untuk serve static files
FROM nginx:alpine

# Copy semua file ke nginx html directory
COPY index.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/
COPY script.js /usr/share/nginx/html/
COPY glassmorphism-login.markdown /usr/share/nginx/html/
COPY README.md /usr/share/nginx/html/

# Copy nginx config (optional, untuk custom config)
# COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]