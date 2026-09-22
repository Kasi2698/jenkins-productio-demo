# ---- Build stage: has npm, used only to install deps ----
FROM node:22-alpine AS build

WORKDIR /app

COPY package*.json ./

RUN npm install -g npm@latest \
 && npm ci --omit=dev --ignore-scripts

# ---- Runtime stage: no npm/yarn/corepack, just node + your app ----
FROM node:22-alpine

RUN apk update && apk upgrade --no-cache

WORKDIR /app

COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package*.json ./
COPY app.js ./

# Remove the npm CLI, yarn, and corepack from the runtime image —
# production only needs the `node` binary to run app.js
RUN rm -rf /usr/local/lib/node_modules/npm \
           /usr/local/lib/node_modules/corepack \
           /opt/yarn-v* \
           /usr/local/bin/npm \
           /usr/local/bin/npx \
           /usr/local/bin/corepack \
           /usr/local/bin/yarn \
           /usr/local/bin/yarnpkg

EXPOSE 3000

USER node

CMD ["node", "app.js"]
