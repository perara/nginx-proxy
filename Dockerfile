FROM nginx:alpine

RUN apk add --no-cache \
  apache2-utils

# Default http protocol
ENV HTTP_PROTOCOL=http \
    FILTER_PATH=0

ADD start.sh /start.sh
RUN chmod 700 /start.sh

EXPOSE 80

CMD /bin/sh start.sh
