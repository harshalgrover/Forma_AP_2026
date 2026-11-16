-- Forma Database Schema (PostgreSQL)

-- Drop existing tables and types if re-running the script
DROP TABLE IF EXISTS "BoardInvitation" CASCADE;
DROP TABLE IF EXISTS "BoardCollaborator" CASCADE;
DROP TABLE IF EXISTS "Board" CASCADE;
DROP TABLE IF EXISTS "Workspace" CASCADE;
DROP TABLE IF EXISTS "User" CASCADE;

DROP TYPE IF EXISTS "InvitationStatus";
DROP TYPE IF EXISTS "BoardRole";

-- Custom enum types
CREATE TYPE "BoardRole" AS ENUM (
    'EDITOR',
    'VIEWER'
);

CREATE TYPE "InvitationStatus" AS ENUM (
    'PENDING',
    'ACCEPTED',
    'REJECTED'
);

-- Registered users
CREATE TABLE "User" (
    "id"        TEXT         NOT NULL,
    "name"      TEXT         NOT NULL,
    "email"     TEXT         NOT NULL,
    "password"  TEXT         NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "User_pkey"      PRIMARY KEY ("id"),
    CONSTRAINT "User_email_key" UNIQUE ("email")
);

-- Workspaces owned by users
CREATE TABLE "Workspace" (
    "id"        TEXT         NOT NULL,
    "name"      TEXT         NOT NULL,
    "ownerId"   TEXT         NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Workspace_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "Workspace_ownerId_fkey"
        FOREIGN KEY ("ownerId")
        REFERENCES "User"("id")
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Whiteboard canvases inside workspaces
CREATE TABLE "Board" (
    "id"          TEXT         NOT NULL,
    "title"       TEXT         NOT NULL,
    "description" TEXT,
    "workspaceId" TEXT         NOT NULL,
    "ownerId"     TEXT         NOT NULL,
    "elements"    JSONB        NOT NULL DEFAULT '[]'::jsonb, -- Excalidraw shapes/drawings
    "appState"    JSONB        NOT NULL DEFAULT '{}'::jsonb, -- Canvas zoom/theme settings
    "isFavorite"  BOOLEAN      NOT NULL DEFAULT FALSE,
    "createdAt"   TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt"   TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Board_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "Board_workspaceId_fkey"
        FOREIGN KEY ("workspaceId")
        REFERENCES "Workspace"("id")
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT "Board_ownerId_fkey"
        FOREIGN KEY ("ownerId")
        REFERENCES "User"("id")
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Tracks which users have access to which boards
CREATE TABLE "BoardCollaborator" (
    "id"        TEXT         NOT NULL,
    "boardId"   TEXT         NOT NULL,
    "userId"    TEXT         NOT NULL,
    "role"      "BoardRole"  NOT NULL DEFAULT 'EDITOR',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "BoardCollaborator_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "BoardCollaborator_boardId_userId_key" UNIQUE ("boardId", "userId"),
    CONSTRAINT "BoardCollaborator_boardId_fkey"
        FOREIGN KEY ("boardId")
        REFERENCES "Board"("id")
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT "BoardCollaborator_userId_fkey"
        FOREIGN KEY ("userId")
        REFERENCES "User"("id")
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Email invites sent to join a board
CREATE TABLE "BoardInvitation" (
    "id"        TEXT               NOT NULL,
    "boardId"   TEXT               NOT NULL,
    "email"     TEXT               NOT NULL,
    "role"      "BoardRole"        NOT NULL DEFAULT 'EDITOR',
    "status"    "InvitationStatus" NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3)       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3)       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "BoardInvitation_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "BoardInvitation_boardId_email_key" UNIQUE ("boardId", "email"),
    CONSTRAINT "BoardInvitation_boardId_fkey"
        FOREIGN KEY ("boardId")
        REFERENCES "Board"("id")
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Indexes on foreign keys and lookup columns to speed up queries
CREATE INDEX "Workspace_ownerId_idx"        ON "Workspace"("ownerId");
CREATE INDEX "Board_workspaceId_idx"        ON "Board"("workspaceId");
CREATE INDEX "Board_ownerId_idx"            ON "Board"("ownerId");
CREATE INDEX "BoardCollaborator_userId_idx" ON "BoardCollaborator"("userId");
CREATE INDEX "BoardInvitation_email_idx"    ON "BoardInvitation"("email");
