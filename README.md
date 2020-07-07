# Nginx Proxy Pass

A simple container that proxy passes to an external source.

A number of great containers for reverse proxying to containers exist (I'm a fan of [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy)) however I couldn't find any that would proxy pass to external sources on the fly.

This version supports **tcp**, **http** with **basic_auth** if needed.


### Running with docker

```bash
docker run -d -p 80:80 -e PROTOCOL=<protocol> -e LISTEN_PORT=<port> -e TARGET_SERVER=<proxy location> perara/nginx-proxy
```
### Running with docker-compose

```bash
version: "2"
services:

  example.com:
    build: .
    ports:
      - 3307:3306
    environment:
      PROTOCOL: http
      LISTEN_PORT: 3306
      TARGET_SERVER: http://example.com:80,http://hotmail.com:80
      HTTP_AUTH_USERNAME: admin
      HTTP_AUTH_PASSWORD: admin
```

### Environment Variables

| Environment        | Required | Example               | Possible Values      |
|--------------------|----------|-----------------------|----------------------|
| PROTOCOL           | x        | http                  | http,https,tcp       |
| LISTEN_PORT        | x        | 80                    | 1-65535              |
| TARGET_SERVER      | x        | http://example.com:80 | Comma Separated List |
| HTTP_AUTH_USERNAME |          | admin                 | Any                  |
| HTTP_AUTH_PASSWORD |          | admin                 | Any                  |
