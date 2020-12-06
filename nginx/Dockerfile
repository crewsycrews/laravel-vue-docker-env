FROM nginx:alpine
RUN apk update && \
    apk --no-cache add shadow bash&& \
    usermod -u 1001 nginx && \
    apk del shadow
ARG APP_NAME
ENV APP_NAME=$APP_NAME

COPY configs/nginx.conf /etc/nginx/
COPY configs/conf.d/ /etc/nginx/conf.d/
# COPY configs/.htpasswd /etc/nginx/.htpasswd
COPY ssl/server.crt /etc/nginx/ssl/server.crt
COPY ssl/server.key /etc/nginx/ssl/server.key

RUN chown -R nginx /etc/nginx/ssl/server.*
RUN chmod 600 /etc/nginx/ssl/server.*