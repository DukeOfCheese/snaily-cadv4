FROM node:18 as base

# Install pnpm and set timeout
RUN npm install -g pnpm
RUN pnpm config set httpTimeout 1200000

# Set working directory for the application
WORKDIR /snailycad
COPY . ./

# Dependencies stage
FROM base as deps
RUN pnpm install
RUN node scripts/copy-env.mjs --client --api

# API stage
FROM deps as api
ENV NODE_ENV="production"

# Expose the API port (assuming the API runs on port 3333)
EXPOSE 3333
RUN pnpm turbo run build --filter=@snailycad/api
WORKDIR /snailycad/apps/api
CMD ["pnpm", "start"]

# Client stage
FROM deps as client
ENV NODE_ENV="production"

# Expose the Client port (assuming the client runs on port 8888)
EXPOSE 8888
RUN rm -rf /snailycad/apps/client/.next
RUN pnpm create-images-domain
RUN pnpm turbo run build --filter=@snailycad/client
WORKDIR /snailycad/apps/client
CMD ["pnpm", "start"]
