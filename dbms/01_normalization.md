# Database Normalization of Forma

## 1. Introduction

Forma is a collaborative online whiteboard application that allows users to create workspaces, manage boards, draw on interactive canvases, and collaborate with other users in real time.

The application uses PostgreSQL as its database and Prisma as its Object-Relational Mapping (ORM) tool.

The purpose of this document is to analyze the existing database structure of Forma and study how its data is organized through different stages of database normalization:

- Unnormalized Form (UNF)
- First Normal Form (1NF)
- Second Normal Form (2NF)
- Third Normal Form (3NF)
- Boyce-Codd Normal Form (BCNF)

The analysis is based on the existing Prisma database schema of the Forma application.

## 2. Existing Database Structure

The current database schema consists of five main models:

1. User
2. Workspace
3. Board
4. BoardCollaborator
5. BoardInvitation

It also contains two enumerated types:

- **BoardRole:** EDITOR, VIEWER
- **InvitationStatus:** PENDING, ACCEPTED, REJECTED

### 2.1 User

Stores information about registered users.

| Attribute | Description | Key |
|---|---|---|
| id | Unique user identifier | Primary Key |
| name | User's name | — |
| email | User's email address | Unique |
| password | User's stored password credential | — |
| createdAt | Account creation timestamp | — |
| updatedAt | Last update timestamp | — |

### 2.2 Workspace

Stores workspaces created by users.

| Attribute | Description | Key |
|---|---|---|
| id | Unique workspace identifier | Primary Key |
| name | Workspace name | — |
| ownerId | ID of the workspace owner | Foreign Key → User(id) |
| createdAt | Workspace creation timestamp | — |
| updatedAt | Last update timestamp | — |

### 2.3 Board

Stores boards belonging to workspaces.

| Attribute | Description | Key |
|---|---|---|
| id | Unique board identifier | Primary Key |
| title | Board title | — |
| description | Board description (optional) | — |
| workspaceId | ID of the associated workspace | Foreign Key → Workspace(id) |
| ownerId | ID of the board owner | Foreign Key → User(id) |
| elements | Excalidraw canvas elements stored as JSON | — |
| appState | Canvas application state stored as JSON | — |
| isFavorite | Indicates whether the board is a favorite | — |
| createdAt | Board creation timestamp | — |
| updatedAt | Last update timestamp | — |

### 2.4 BoardCollaborator

Stores the relationship between users and boards they can collaborate on.

| Attribute | Description | Key |
|---|---|---|
| id | Unique collaboration identifier | Primary Key |
| boardId | Associated board ID | Foreign Key → Board(id) |
| userId | Associated user ID | Foreign Key → User(id) |
| role | Collaborator's role (EDITOR/VIEWER) | — |
| createdAt | Collaboration creation timestamp | — |
| updatedAt | Last update timestamp | — |

The combination of `boardId` and `userId` is also unique.

### 2.5 BoardInvitation

Stores invitations sent to users to collaborate on boards.

| Attribute | Description | Key |
|---|---|---|
| id | Unique invitation identifier | Primary Key |
| boardId | Associated board ID | Foreign Key → Board(id) |
| email | Email address of the invited user | — |
| role | Assigned role (EDITOR/VIEWER) | — |
| status | Invitation status | — |
| createdAt | Invitation creation timestamp | — |
| updatedAt | Last update timestamp | — |

The combination of `boardId` and `email` is also unique.

## 3. Database Relationships

The existing database has the following relationships:

- One User can own multiple Workspaces.
- One User can own multiple Boards.
- One Workspace can contain multiple Boards.
- One Board can have multiple Collaborators.
- One User can collaborate on multiple Boards.
- One Board can have multiple Invitations.

The BoardCollaborator model connects Users and Boards, while BoardInvitation stores pending or completed collaboration invitations.

## 4. Functional Dependency Analysis

A functional dependency describes a relationship between attributes where one attribute or a group of attributes uniquely determines another attribute.

It is represented as:

`X → Y`

This means that X uniquely determines Y.

Based on the existing Forma database schema, the functional dependencies are:

### 4.1 User

```text
User.id → User.name, User.email, User.password,
          User.createdAt, User.updatedAt

User.email → User.id, User.name, User.password,
             User.createdAt, User.updatedAt
```

Both `id` and `email` uniquely identify a user because `id` is the primary key and `email` has a unique constraint.

### 4.2 Workspace

```text
Workspace.id → Workspace.name, Workspace.ownerId,
               Workspace.createdAt, Workspace.updatedAt
```

The workspace ID uniquely determines all other attributes of that workspace.

### 4.3 Board

```text
Board.id → Board.title, Board.description,
           Board.workspaceId, Board.ownerId,
           Board.elements, Board.appState,
           Board.isFavorite, Board.createdAt,
           Board.updatedAt
```

The board ID uniquely determines all other attributes of that board.

### 4.4 BoardCollaborator

```text
BoardCollaborator.id → BoardCollaborator.boardId,
                       BoardCollaborator.userId,
                       BoardCollaborator.role,
                       BoardCollaborator.createdAt,
                       BoardCollaborator.updatedAt
```

Additionally:

```text
(BoardCollaborator.boardId, BoardCollaborator.userId)
    → BoardCollaborator.id,
      BoardCollaborator.role,
      BoardCollaborator.createdAt,
      BoardCollaborator.updatedAt
```

The combination of `boardId` and `userId` is unique, so it also determines the collaboration ID and the remaining attributes.

### 4.5 BoardInvitation

```text
BoardInvitation.id → BoardInvitation.boardId,
                     BoardInvitation.email,
                     BoardInvitation.role,
                     BoardInvitation.status,
                     BoardInvitation.createdAt,
                     BoardInvitation.updatedAt
```

Additionally:

```text
(BoardInvitation.boardId, BoardInvitation.email)
    → BoardInvitation.id,
      BoardInvitation.role,
      BoardInvitation.status,
      BoardInvitation.createdAt,
      BoardInvitation.updatedAt
```

The combination of `boardId` and `email` is unique, so it also determines the invitation ID and the remaining attributes.

## 5. Unnormalized Form (UNF)

Unnormalized Form (UNF) refers to a database structure in which data may contain repeating groups, multiple values in a single attribute, or nested collections.

To understand the need for normalization in Forma, consider a hypothetical table that stores board information along with all its collaborators and invitations in a single record.

### 5.1 Example of an Unnormalized Table

| BoardID | BoardTitle | OwnerName | Collaborators | Invitations |
|---|---|---|---|---|
| B101 | Project Design | Rahul | [(U02, Editor), (U03, Viewer)] | [(a@example.com, Pending), (b@example.com, Accepted)] |
| B102 | Meeting Notes | Priya | [(U04, Editor)] | [(c@example.com, Pending)] |

In this example:

- The Collaborators attribute contains multiple user IDs and roles.
- The Invitations attribute contains multiple email addresses and statuses.
- Multiple values are stored within individual attributes.

### 5.2 Problems with UNF

The above structure has the following problems:

1. **Repeating Groups:** Multiple collaborators and invitations are stored in the same record.
2. **Data Redundancy:** Board and owner information may be repeated when a board has multiple collaborators.
3. **Update Anomaly:** Updating collaborator or invitation information may require modifying nested data.
4. **Insertion Anomaly:** Adding a collaborator or invitation independently becomes difficult.
5. **Deletion Anomaly:** Removing information from a combined record may unintentionally remove other related information.

Therefore, this structure is difficult to maintain and does not follow the requirements of First Normal Form.

## 6. First Normal Form (1NF)

A relation is in First Normal Form (1NF) if:

- Every attribute contains a single value from its domain.
- Each row can be uniquely identified.
- There are no repeating groups or multivalued attributes within a relational column.

### 6.1 Conversion of UNF into 1NF

To remove repeating groups, the hypothetical combined structure can be separated into individual relations.

For example, collaborator information can be stored separately:

**Board Table**

| BoardID | BoardTitle | OwnerID |
|---|---|---|
| B101 | Project Design | U01 |
| B102 | Meeting Notes | U05 |

**BoardCollaborator Table**

| CollaborationID | BoardID | UserID | Role |
|---|---|---|---|
| C01 | B101 | U02 | EDITOR |
| C02 | B101 | U03 | VIEWER |
| C03 | B102 | U04 | EDITOR |

**BoardInvitation Table**

| InvitationID | BoardID | Email | Status |
|---|---|---|---|
| I01 | B101 | a@example.com | PENDING |
| I02 | B101 | b@example.com | ACCEPTED |
| I03 | B102 | c@example.com | PENDING |

Each row now represents one individual collaborator or invitation, and each relational attribute contains a single value.

### 6.2 How Forma Implements 1NF

The actual Forma database already separates information into different models:

- `User` stores user information.
- `Workspace` stores workspace information.
- `Board` stores board information.
- `BoardCollaborator` stores individual user-board collaboration records.
- `BoardInvitation` stores individual board invitations.

This separation avoids storing multiple collaborators or invitations in a single relational column.

**Note on JSON attributes:** The `elements` and `appState` attributes in the Board model store structured canvas data as JSON. Although each is stored as one database column value, its contents can contain nested objects and arrays. These are intentionally treated as canvas document payloads by the application. If individual drawing elements needed to be managed as separate relational records, they would require a separate relational design.

Thus, the relational structure separates repeating collaborator and invitation records, while the canvas data remains stored as JSON.

## 7. Second Normal Form (2NF)

A relation is in Second Normal Form (2NF) if:

- It is already in First Normal Form (1NF).
- It has no partial functional dependencies, meaning every non-prime attribute must depend on the entire candidate key, not just a part of it.

A partial dependency occurs when a non-key attribute depends on only a part of a composite candidate key.

### 7.1 Analysis of Forma Tables

The existing Forma database uses the following candidate keys:

| Table | Candidate Key(s) |
|---|---|
| User | id, email |
| Workspace | id |
| Board | id |
| BoardCollaborator | id, (boardId, userId) |
| BoardInvitation | id, (boardId, email) |

In the User, Workspace, and Board tables, the candidate keys are single attributes. Therefore, partial dependencies cannot occur in these tables.

In the BoardCollaborator and BoardInvitation tables, composite candidate keys also exist. Their non-key attributes depend on the complete composite key.

**BoardCollaborator:**

The combination of `boardId` and `userId` uniquely identifies a collaboration and determines its role and timestamps. Neither `boardId` alone nor `userId` alone is declared unique.

**BoardInvitation:**

The combination of `boardId` and `email` uniquely identifies an invitation and determines its role, status, and timestamps. Neither `boardId` alone nor `email` alone is declared unique.

### 7.2 Result of 2NF Analysis

Based on the candidate keys and functional dependencies defined in the existing Prisma schema:

- No partial dependencies are identified.
- Every non-prime attribute depends on a complete candidate key.
- All five relational models satisfy the requirements of Second Normal Form.

Therefore, the existing Forma database schema is in **Second Normal Form (2NF)**, based on the declared constraints and functional dependencies.

## 8. Third Normal Form (3NF)

A relation is in Third Normal Form (3NF) if:

- It is already in Second Normal Form (2NF).
- It has no transitive dependency of non-prime attributes on candidate keys.
- Every non-prime attribute must depend directly on a candidate key, the whole key, and nothing but the key.

A transitive dependency occurs when a non-key attribute depends on another non-key attribute instead of depending directly on a candidate key.

### 8.1 Analysis of Forma Tables

Based on the existing Prisma schema, the following observations can be made:

1. **User:** User details such as name, email, password, and timestamps are determined by the user's ID. The email address is also unique. No transitive dependency is identified.

2. **Workspace:** Workspace name, owner ID, and timestamps are determined by the workspace ID. No transitive dependency is identified.

3. **Board:** Board title, description, workspace ID, owner ID, canvas data, and timestamps are determined by the board ID. No transitive dependency is identified among the declared attributes.

4. **BoardCollaborator:** The collaboration ID and the composite key `(boardId, userId)` determine the remaining collaboration attributes. No transitive dependency is identified.

5. **BoardInvitation:** The invitation ID and the composite key `(boardId, email)` determine the remaining invitation attributes. No transitive dependency is identified.

Foreign key relationships between these models represent associations between tables. They do not, by themselves, establish transitive dependencies among attributes within a table.

### 8.2 Result of 3NF Analysis

Based on the functional dependencies declared by the existing Prisma schema:

- No transitive dependencies among non-key attributes are identified.
- Non-key attributes depend directly on candidate keys.
- All five relational models satisfy the requirements of Third Normal Form.

Therefore, the existing Forma database schema is in **Third Normal Form (3NF)**, based on the declared constraints and functional dependencies.

**Note:** If the application enforces an additional business rule that a board's owner must always be the same as its workspace's owner, the relationship between `workspaceId` and `ownerId` may need further analysis. This dependency is not enforced by the current Prisma schema.

## 9. Boyce-Codd Normal Form (BCNF)

Boyce-Codd Normal Form (BCNF) is a stronger version of Third Normal Form (3NF).

A relation is in BCNF if, for every non-trivial functional dependency `X → Y`, X must be a superkey.

In simple terms, every determinant must be a candidate key or a superkey.

### 9.1 Analysis of Forma Tables

Based on the candidate keys and functional dependencies identified in the existing Prisma schema:

| Table | Candidate Key(s) | BCNF Analysis |
|---|---|---|
| User | id, email | Both determinants are candidate keys. |
| Workspace | id | The determinant is a candidate key. |
| Board | id | The determinant is a candidate key. |
| BoardCollaborator | id, (boardId, userId) | Both determinants are candidate keys. |
| BoardInvitation | id, (boardId, email) | Both determinants are candidate keys. |

In each table, the declared non-trivial functional dependencies have candidate keys or superkeys as their determinants.

Therefore, no BCNF violation is identified in the existing relational schema.

### 9.2 Result of BCNF Analysis

Based on the functional dependencies and unique constraints declared in the Prisma schema:

- Every determinant identified is a candidate key or a superkey.
- No BCNF violation is identified.
- All five relational models satisfy the requirements of BCNF under the declared functional dependencies.

Thus, the existing Forma database schema appears to be in **Boyce-Codd Normal Form (BCNF)**.

**Note:** This conclusion is based on the dependencies represented by the current Prisma schema. Additional business rules not enforced by the schema may require further analysis. The structured JSON canvas payloads in the Board model are outside this relational BCNF analysis.