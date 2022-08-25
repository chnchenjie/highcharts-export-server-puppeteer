FROM node:gallium as builder

# https://github.com/highcharts/node-export-server#using-in-automated-deployments
ENV ACCEPT_HIGHCHARTS_LICENSE="1"

# https://github.com/puppeteer/puppeteer#environment-variables
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Create app directory
WORKDIR /usr/src/app

# Install highcharts-export-server so it's available in the container.
RUN git clone https://github.com/highcharts/node-export-server \
    && cd node-export-server \
    && git checkout enhancement/puppeteer \
    && npm install \
    && node install.js

# Use multi-stage builds
FROM node:gallium-slim

# https://github.com/puppeteer/puppeteer#environment-variables
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome

# https://github.com/puppeteer/puppeteer/blob/main/docs/troubleshooting.md#running-puppeteer-in-docker
# Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer
# installs, work.
RUN apt-get update \
    && apt-get install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /usr/src/app/node-export-server

# Copy artifacts from builder stage
COPY --from=builder /usr/src/app/node-export-server .

# Add user so we don't need --no-sandbox.
RUN groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
    && mkdir -p /home/pptruser/Downloads \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser .

# Run everything after as non-privileged user.
USER pptruser

EXPOSE 7801
CMD [ "npm", "run", "start" ]