FROM node:22-bookworm-slim AS base

ENV PNPM_HOME=/pnpm
ENV PATH=$PNPM_HOME:$PATH

RUN corepack enable

WORKDIR /app

FROM base AS dependencies

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY medusa/package.json ./medusa/package.json
COPY medusa/apps/backend/package.json ./medusa/apps/backend/package.json
COPY storefront/package.json ./storefront/package.json

RUN pnpm install --frozen-lockfile

FROM dependencies AS builder

COPY medusa ./medusa

ENV NODE_ENV=production

RUN pnpm --filter @dtc/backend build

FROM base AS runner

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=9000

COPY --from=builder /app/package.json /app/pnpm-lock.yaml /app/pnpm-workspace.yaml ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/medusa/package.json ./medusa/package.json
COPY --from=builder /app/medusa/node_modules ./medusa/node_modules
COPY --from=builder /app/medusa/apps/backend/package.json ./medusa/apps/backend/package.json
COPY --from=builder /app/medusa/apps/backend/node_modules ./medusa/apps/backend/node_modules
COPY --from=builder /app/medusa/apps/backend/.medusa ./medusa/apps/backend/.medusa

RUN chown -R node:node /app

USER node

EXPOSE 9000

CMD ["pnpm", "--filter", "@dtc/backend", "start"]
