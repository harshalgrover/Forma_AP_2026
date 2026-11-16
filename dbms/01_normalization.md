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
| password | User's password hash/value | — |
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
    → BoardCollaborator.role,
      BoardCollaborator.createdAt,
      BoardCollaborator.updatedAt
```

The combination of `boardId` and `userId` is unique, so it also determines the remaining non-key attributes.

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
    → BoardInvitation.role,
      BoardInvitation.status,
      BoardInvitation.createdAt,
      BoardInvitation.updatedAt
```

The combination of `boardId` and `email` is unique, so it also determines the remaining non-key attributes.