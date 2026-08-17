# medusa_astro

Medusa 2 backend with an optionally linked Astro storefront repository. The storefront is an independent application and can be deployed separately from the backend.

## Requirements

- Node.js 22.13 or newer
- pnpm 11 (`corepack enable`)
- PostgreSQL
- Redis

## Local development

1. Clone the repository together with the storefront submodule:

   ```bash
   git clone --recurse-submodules https://github.com/pfulara/medusa-astro.git
   cd medusa_astro
   ```

   For an existing clone, run `git submodule update --init --recursive`.

2. Install the dependencies:

   ```bash
   corepack enable
   pnpm install --frozen-lockfile
   ```

3. Copy `medusa/apps/backend/.env.template` to `medusa/apps/backend/.env` and configure at least:

   ```dotenv
   DATABASE_URL=postgres://user:password@localhost:5432/medusa
   REDIS_URL=redis://localhost:6379
   JWT_SECRET=change-me
   COOKIE_SECRET=change-me
   STORE_CORS=http://localhost:8000
   ADMIN_CORS=http://localhost:9000
   AUTH_CORS=http://localhost:8000,http://localhost:9000
   ```

4. Start the backend and storefront in separate terminals:

   ```bash
   pnpm dev:medusa
   pnpm dev:storefront
   ```

The backend runs at `http://localhost:9000`, the admin dashboard at `http://localhost:9000/app`, and the storefront at `http://localhost:8000`.

## Production — backend

Build the image from the repository root:

```bash
docker build -t medusa-astro-backend .
```

The container requires `DATABASE_URL`, `REDIS_URL`, `JWT_SECRET`, `COOKIE_SECRET`, `STORE_CORS`, `ADMIN_CORS`, and `AUTH_CORS`. Before starting a new release, run the migrations using the same image version:

```bash
docker run --rm --env-file .env.production medusa-astro-backend \
  pnpm --filter @dtc/backend exec medusa db:migrate

docker run --rm -p 9000:9000 --env-file .env.production medusa-astro-backend
```

`STORE_CORS` and `AUTH_CORS` must include the full public storefront origin, for example `https://shop.example.com` without a path. `ADMIN_CORS` must include the admin dashboard origin. Separate multiple origins with commas.

In production, the backend should run behind an HTTPS reverse proxy. PostgreSQL and Redis are not included in the image and should be provided as external services.

## Independent storefront

The storefront does not import code or local packages from this repository. The `medusa-astro-starter` repository can be cloned and deployed on its own; see [storefront/README.md](storefront/README.md) for details. In addition to the backend URL and publishable API key, the backend must allow the storefront domain through CORS, and the key must be associated with the sales channel containing the published products.

## Useful commands

```bash
pnpm build          # build the backend and linked storefront
pnpm lint           # lint the backend
pnpm test           # run backend unit tests
pnpm start:medusa   # start the built backend
```
