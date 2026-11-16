# Forma — DBMS Academic Project

## 1. About the Project

This repository contains the Database Management Systems (DBMS) academic project based on **Forma**, a collaborative online whiteboard application.

Forma allows users to create workspaces, manage boards, draw on interactive canvases, share boards, and collaborate with other users in real time.

The objective of this project is to analyze the database design of Forma and understand how database concepts are applied in a real-world application.

## 2. Application Repository

- **Main Application:** [Forma](https://github.com/yugrastogi/Forma)
- **Academic Project Repository:** [Forma_AP_2026](https://github.com/harshalgrover/Forma_AP_2026)

## 3. Technology Stack

- **Database:** PostgreSQL
- **ORM:** Prisma
- **Backend:** Node.js and Express
- **Application:** React

## 4. Project Checkpoints

The DBMS project consists of the following deliverables:

| No. | Deliverable | Description |
|---|---|---|
| 01 | `01_normalization.md` | Normalization of the application's data through 1NF, 2NF, 3NF and BCNF where applicable |
| 02 | `02_er_diagram.png` | ER diagram showing entities, keys and cardinalities |
| 03 | `03_schema.sql` | PostgreSQL CREATE TABLE statements |
| 04 | `04_queries.sql` | Application queries classified as READ and WRITE |
| 05 | `05_query_timings.md` | Execution timings for three runs, averages and performance analysis |
| 06 | `plans/` | Raw query execution plans |

## 5. Repository Structure

```text
Forma_AP_2026/
│
├── README.md
│
└── dbms/
    ├── 01_normalization.md
    ├── 02_er_diagram.png
    ├── 03_schema.sql
    ├── 04_queries.sql
    ├── 05_query_timings.md
    │
    └── plans/
```

*The deliverable files will be added as the respective project checkpoints are completed.*

## 6. Project Objective

The project aims to:

- Study the database structure of Forma.
- Understand database normalization and functional dependencies.
- Represent entities and their relationships using an ER diagram.
- Implement the relational schema using PostgreSQL.
- Analyze the SQL queries used by the application.
- Evaluate query execution performance.

