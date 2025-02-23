FROM node:14-alpine AS base
# FROM node:14-alpine
WORKDIR /build

# Prepare for installing dependencies
# Utilise Docker cache to save re-installing dependencies if unchanged
COPY package.json yarn.lock ./
# Install dependencies
RUN yarn install --frozen-lockfile 
# Copy the rest files
# COPY . .

# Build all application
# RUN yarn build:frontend
# Install only production dependencies
# RUN yarn install --frozen-lockfile --production --ignore-scripts --prefer-offline
# RUN yarn install

# ------ stage 2 ---------
FROM ubuntu/nginx:1.18-20.04_beta
WORKDIR /etc/nginx/
# ENV NODE_ENV production

# RUN apt-get update
# RUN apt install sudo gnupg gnupg2 gnupg1 curl -y
# RUN sudo apt remove cmdtest
# RUN sudo apt remove yarn
# RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
# RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
# RUN sudo apt-get install yarn -y
# RUN yarn install

RUN apt update -y && apt upgrade -y
# RUN apt-get install -y nodejs npm

# COPY package.json yarn.lock ./
# RUN npm install

# COPY . .
# Run api update and upgrade
# RUN apt update -y && apt upgrade -y

# Install curl
RUN apt -y install curl

# Install nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
  && apt install -y nodejs \
  && apt-get install -y python3-pip python3

# Install musl-dev
# RUN apt-get install -y glibc-source
# RUN apt-get install -y glibc-source \
#   && ln -s /usr/lib/x86_64-linux-glibc/libc.so /lib/libc.glibc-x86_64.so.1
# RUN apt-get install -y musl-dev \
#   && ln -s /usr/lib/x86_64-linux-musl/libc.so /lib/libc.musl-x86_64.so.1

# Copy everything (except files that are in .dockerignore)
# WORKDIR /
# COPY --from=base /build/package.json ./package.json
COPY --from=base /build/node_modules ./node_modules
COPY . .

# RUN npm install --target_platform=linux --target_arch=x64 --target_libc=glibc
RUN apt install -y cmake
RUN apt install -y build-essential autoconf libtool pkg-config

RUN pip install grpcio grpcio-tools google protobuf

# COPY --from=base /build/dist ./dist
# COPY --from=base /build/apps ./apps
# COPY --from=base /build/libs ./libs
# COPY --from=base /build/tools ./tools

COPY start_production.sh .
RUN chmod +x start_production.sh
RUN echo '\nnginx -g "daemon off;\n"' >> start_production.sh

RUN sed -i 's/\r$//' start_production.sh  && \
  chmod +x start_production.sh

# Expose nginx port
EXPOSE 80

# # Run Start command
ENTRYPOINT ["/docker-entrypoint.sh"]
# CMD ["./node_modules/.bin/pm2", "serve", "./", "4200", "--spa"]
CMD ["./start_production.sh"]