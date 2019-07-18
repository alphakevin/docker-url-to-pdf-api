ARG CHROMIUM_VERSION=77.0.3853.0
ARG NODE_VERSION=carbon

FROM node:$NODE_VERSION AS builder
WORKDIR /temp

RUN apt-get update -y && apt-get install -yq tar

RUN wget https://github.com/alvarcarto/url-to-pdf-api/archive/master.tar.gz
RUN tar -zxf master.tar.gz

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    NODE_ENV=production

RUN cd url-to-pdf-api-master && npm i

FROM microbox/chromium-headless:$CHROMIUM_VERSION
WORKDIR /app

RUN apt-get update -y && apt-get install -yq \
  wget \
  fontconfig \
  fonts-dejavu \
  fonts-symbola \
  fonts-noto-cjk \
  fonts-ocr-b \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/node /bin/
COPY --from=builder /temp/url-to-pdf-api-master /app

ENV CHROMIUM_VERSION=$CHROMIUM_VERSION \
    NODE_VERSION=$NODE_VERSION \
    NODE_ENV=production \
    PORT=9000 \
    ALLOW_HTTP=true \
    PUPPETEER_EXECUTABLE_PATH=/bin/chromium

EXPOSE 9000

ENTRYPOINT ["/bin/node", "src/index.js"]
