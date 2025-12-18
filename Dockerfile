# Use a small, secure base
FROM nginx:alpine

RUN apk add --no-cache gzip brotli findutils


# Copy our Nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the Godot export (adjust the path if your folder is different)
# This will be served from http://localhost/ by default
COPY builds/web/ /usr/share/nginx/html/

RUN cd /usr/share/nginx/html \
    && find . -type f \( -name "*.js" -o -name "*.wasm" \) -print0 \
        | xargs -0 -I{} sh -c 'gzip -k -f -9 "{}"' \
    && find . -type f \( -name "*.js" -o -name "*.wasm" \) -print0 \
        | xargs -0 -I{} sh -c 'brotli -f -k -q 11 "{}"'


# Make sure permissions are sane (nginx user can read)
RUN chown -R nginx:nginx /usr/share/nginx/html

# Expose HTTP
EXPOSE 80

# Run Nginx in the foreground (container entrypoint)
CMD ["nginx", "-g", "daemon off;"]
