FROM node:lts-alpine3.18 AS base
FROM base AS builder


WORKDIR /app

ENV PATH /app/node_modules/.bin:$PATH
COPY package*.json ./

RUN npm ci

COPY . .

RUN npx prisma generate

RUN ls

FROM base AS runner
WORKDIR /app

COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src


EXPOSE 3000
CMD ["sh", "-c", "npx ts-node src/app.ts"]

