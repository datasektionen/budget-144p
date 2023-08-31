FROM node:lts-alpine3.18 AS base
FROM base AS builder


WORKDIR /app

ENV PATH /app/node_modules/.bin:$PATH
COPY package*.json /

RUN npm ci --only=production

COPY . .

RUN npx prisma generate


FROM base AS runner
WORKDIR /app

COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src


EXPOSE 7050
CMD ["sh", "-c", "./node_modules/.bin/prisma migrate deploy && npx ts-node src/app.ts"]

