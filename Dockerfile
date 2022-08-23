FROM nginx:latest
LABEL maintainer="Mark Coleman <mark@breakthrough-workshop.com>"

COPY _site /usr/share/nginx/html/
