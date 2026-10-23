# 1. Use an ultra-lightweight, production-grade web server base layer
FROM nginx:alpine

# 2. Clear out the default welcome page provided by the image framework
RUN rm -rf /usr/share/nginx/html/*

# 3. Inject our local application code straight into the server's public distribution folder
COPY index.html /usr/share/nginx/html/
