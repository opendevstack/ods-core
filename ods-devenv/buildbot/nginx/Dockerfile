FROM nginx:latest

COPY nginx.conf /etc/nginx
COPY data/ /data/
RUN ["chown", "--recursive", "nginx:nginx", "/data"]

CMD ["nginx", "-g", "daemon off;"]
