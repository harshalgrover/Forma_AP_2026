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