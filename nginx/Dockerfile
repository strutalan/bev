FROM nginx:alpine

# Copy the template
COPY nginx.conf.template /etc/nginx/templates/default.conf.template

# Create startup script that handles variable substitution
RUN echo '#!/bin/sh' > /docker-entrypoint.sh && \
    echo 'sed "s/\${SERVER_NAME}/$SERVER_NAME/g" /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf' >> /docker-entrypoint.sh && \
    echo 'exec nginx -g "daemon off;"' >> /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh

CMD ["/docker-entrypoint.sh"]