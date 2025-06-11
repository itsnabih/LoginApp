# Gunakan image nginx sebagai base
FROM nginx:alpine

# Hapus default config nginx
RUN rm -rf /usr/share/nginx/html/*

# Copy semua file dari proyek ke folder web server Nginx
COPY . /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Jalankan Nginx
CMD ["nginx", "-g", "daemon off;"]
