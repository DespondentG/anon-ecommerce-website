FROM nginx:alpine

# Remove the default Nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy your website files into the container
COPY . /usr/share/nginx/html

# Copy custom Nginx config (optional, for clean routing)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose the default HTTP port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
