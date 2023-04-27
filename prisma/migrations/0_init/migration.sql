-- CreateTable
CREATE TABLE "account_budget_line" (
    "id" SERIAL NOT NULL,
    "account_id" INTEGER NOT NULL,
    "budget_line_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP(0),
    "updated_at" TIMESTAMP(0),

    CONSTRAINT "account_budget_line_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "accounts" (
    "id" SERIAL NOT NULL,
    "number" VARCHAR(255) NOT NULL,
    "name" VARCHAR(255),
    "description" TEXT,
    "created_at" TIMESTAMP(0),
    "updated_at" TIMESTAMP(0),

    CONSTRAINT "accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "budget_line_follow_up" (
    "id" SERIAL NOT NULL,
    "budget_line_id" INTEGER NOT NULL,
    "follow_up_id" INTEGER NOT NULL,
    "booked" INTEGER NOT NULL,
    "created_at" TIMESTAMP(0),
    "updated_at" TIMESTAMP(0),

    CONSTRAINT "budget_line_follow_up_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "budget_lines" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "income" INTEGER NOT NULL,
    "expenses" INTEGER NOT NULL,
    "created_at" TIMESTAMP(0),
    "updated_at" TIMESTAMP(0),
    "cost_centre_id" INTEGER NOT NULL,
    "type" VARCHAR(255) NOT NULL DEFAULT 'internal',
    "valid_from" TIMESTAMP(0),
    "valid_to" TIMESTAMP(0),
    "suggestion_id" INTEGER NOT NULL,
    "parent" INTEGER,

    CONSTRAINT "budget_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "committees" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMP(0),
    "updated_at" TIMESTAMP(0),
    "type" VARCHAR(255) NOT NULL DEFAULT 'committee',
    "inactive" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "committees_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cost_centres" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "committee_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP(0),
    "updated_at" TIMESTAMP(0),
    "repetitions" INTEGER NOT NULL DEFAULT 1,
    "speedledger_id" VARCHAR(255),

    CONSTRAINT "cost_centres_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "follow_ups" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255),
    "created_by" INTEGER NOT NULL,
    "created_at" TIMESTAMP(0),
    "updated_at" TIMESTAMP(0),

    CONSTRAINT "follow_ups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "migrations" (
    "id" SERIAL NOT NULL,
    "migration" VARCHAR(255) NOT NULL,
    "batch" INTEGER NOT NULL,

    CONSTRAINT "migrations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "suggestion_user" (
    "id" SERIAL NOT NULL,
    "suggestion_id" INTEGER NOT NULL,
    "user_id" INTEGER NOT NULL,
    "permission" VARCHAR(255) NOT NULL DEFAULT 'read',
    "created_at" TIMESTAMP(0),
    "updated_at" TIMESTAMP(0),

    CONSTRAINT "suggestion_user_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "suggestions" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "valid_from" TIMESTAMP(0) NOT NULL,
    "valid_to" TIMESTAMP(0) NOT NULL,
    "description" TEXT,
    "created_by" INTEGER NOT NULL,
    "created_at" TIMESTAMP(0),
    "updated_at" TIMESTAMP(0),
    "implemented_at" TIMESTAMP(0),
    "implemented_by" INTEGER,
    "public_at" TIMESTAMP(0),

    CONSTRAINT "suggestions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" SERIAL NOT NULL,
    "first_name" VARCHAR(255) NOT NULL,
    "last_name" VARCHAR(255) NOT NULL,
    "ugkthid" VARCHAR(255) NOT NULL,
    "kth_username" VARCHAR(255) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "remember_token" VARCHAR(100),
    "created_at" TIMESTAMP(0),
    "updated_at" TIMESTAMP(0),
    "verified" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_ugkthid_unique" ON "users"("ugkthid");

