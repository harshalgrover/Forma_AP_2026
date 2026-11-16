-- =====================================================
-- FORMA: APPLICATION DATABASE QUERIES
-- READ queries retrieve data; WRITE queries modify data.
-- Parameters ($1, $2, etc.) are supplied by the application.
-- =====================================================


-- =====================================================
-- 1. AUTHENTICATION
-- =====================================================

-- READ R1: Find a user by email.
-- $1 = email
SELECT *
FROM "User"
WHERE email = $1;


-- WRITE W1: Create a new user.
-- $1 = ID, $2 = name, $3 = email, $4 = hashed password
INSERT INTO "User" (
    id, name, email, password, "createdAt", "updatedAt"
)
VALUES (
    $1, $2, $3, $4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
);


-- READ R2: Get the current user's details.
-- $1 = user ID
SELECT id, name, email, "createdAt"
FROM "User"
WHERE id = $1;


-- READ R3: Get pending invitations for a user's email.
-- $1 = email
SELECT *
FROM "BoardInvitation"
WHERE email = $1
  AND status = 'PENDING';


-- WRITE W2: Add a user as a board collaborator.
-- $1 = ID, $2 = board ID, $3 = user ID, $4 = role
INSERT INTO "BoardCollaborator" (
    id, "boardId", "userId", role, "createdAt", "updatedAt"
)
VALUES (
    $1, $2, $3, $4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
);


-- WRITE W3: Delete an invitation after acceptance.
-- $1 = invitation ID
DELETE FROM "BoardInvitation"
WHERE id = $1;

-- =====================================================
-- 2. WORKSPACE
-- =====================================================

-- WRITE W4: Create a workspace.
-- $1 = ID, $2 = name, $3 = owner ID
INSERT INTO "Workspace" (
    id, name, "ownerId", "createdAt", "updatedAt"
)
VALUES (
    $1, $2, $3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
);


-- READ R4: Get all workspaces owned by a user.
-- $1 = owner ID
SELECT
    w.*,
    COUNT(b.id) AS "boardCount"
FROM "Workspace" w
LEFT JOIN "Board" b ON b."workspaceId" = w.id
WHERE w."ownerId" = $1
GROUP BY w.id
ORDER BY w."updatedAt" DESC;


-- READ R5: Get workspace details.
-- $1 = workspace ID, $2 = owner ID
SELECT *
FROM "Workspace"
WHERE id = $1
  AND "ownerId" = $2;


-- READ R6: Get boards belonging to a workspace.
-- $1 = workspace ID, $2 = owner ID
SELECT b.*
FROM "Board" b
INNER JOIN "Workspace" w ON w.id = b."workspaceId"
WHERE b."workspaceId" = $1
  AND w."ownerId" = $2
  AND b."ownerId" = $2
ORDER BY b."updatedAt" DESC;


-- WRITE W5: Update workspace name.
-- $1 = new name, $2 = workspace ID
UPDATE "Workspace"
SET
    name = $1,
    "updatedAt" = CURRENT_TIMESTAMP
WHERE id = $2;


-- WRITE W6: Delete a workspace.
-- $1 = workspace ID
DELETE FROM "Workspace"
WHERE id = $1;

-- =====================================================
-- 3. BOARDS
-- =====================================================

-- WRITE W7: Create a board.
-- $1 = ID, $2 = title, $3 = description,
-- $4 = workspace ID, $5 = owner ID
INSERT INTO "Board" (
    id, title, description, "workspaceId", "ownerId",
    elements, "appState", "createdAt", "updatedAt"
)
VALUES (
    $1, $2, $3, $4, $5,
    '[]'::jsonb, '{}'::jsonb,
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
);


-- READ R7: Check board access and retrieve collaborator role.
-- $1 = board ID, $2 = user ID
SELECT
    b.*,
    w.id AS "workspaceId",
    w.name AS "workspaceName",
    bc.role AS "collaboratorRole"
FROM "Board" b
INNER JOIN "Workspace" w ON w.id = b."workspaceId"
LEFT JOIN "BoardCollaborator" bc
    ON bc."boardId" = b.id
   AND bc."userId" = $2
WHERE b.id = $1;


-- READ R8: Get recently accessed boards.
-- $1 = user ID, $2 = result limit
SELECT DISTINCT
    b.*,
    w.name AS "workspaceName",
    bc.role AS "collaboratorRole"
FROM "Board" b
INNER JOIN "Workspace" w ON w.id = b."workspaceId"
LEFT JOIN "BoardCollaborator" bc
    ON bc."boardId" = b.id
   AND bc."userId" = $1
WHERE b."ownerId" = $1
   OR bc."userId" = $1
ORDER BY b."updatedAt" DESC
LIMIT $2;


-- READ R9: Get board details by ID.
-- $1 = board ID
SELECT
    b.*,
    w.name AS "workspaceName"
FROM "Board" b
INNER JOIN "Workspace" w ON w.id = b."workspaceId"
WHERE b.id = $1;


-- WRITE W8: Update board details.
-- $1 = title, $2 = description, $3 = isFavorite,
-- $4 = board ID
UPDATE "Board"
SET
    title = $1,
    description = $2,
    "isFavorite" = $3,
    "updatedAt" = CURRENT_TIMESTAMP
WHERE id = $4;


-- WRITE W9: Delete a board.
-- $1 = board ID
DELETE FROM "Board"
WHERE id = $1;


-- =====================================================
-- 4. CANVAS
-- =====================================================

-- READ R10: Retrieve board canvas data.
-- $1 = board ID
SELECT elements, "appState"
FROM "Board"
WHERE id = $1;


-- WRITE W10: Save canvas elements and application state.
-- $1 = elements JSON, $2 = appState JSON, $3 = board ID
UPDATE "Board"
SET
    elements = $1::jsonb,
    "appState" = $2::jsonb,
    "updatedAt" = CURRENT_TIMESTAMP
WHERE id = $3;