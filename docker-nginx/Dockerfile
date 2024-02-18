FROM nginx:latest

# Use this to test static files
# COPY index.html /usr/share/nginx/html/

# Remove the default configuration file
RUN rm /etc/nginx/conf.d/default.conf

# Copy the nginx configuration file
COPY default.conf /etc/nginx/conf.d/default.conf
