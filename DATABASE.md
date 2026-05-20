# Database Schema

This document outlines the database structure used in the Simogura project.

## Tables

### 1. `akun` (Accounts)
Stores user credentials and roles for the application.

| Column | Type | Constraints | Default |
| :--- | :--- | :--- | :--- |
| `id` | `bigint` | Primary Key, Identity | - |
| `created_at` | `timestamp with time zone` | Not Null | `now()` |
| `role` | `text` | - | `'Karyawan'` |
| `username` | `text` | - | - |
| `password` | `text` | - | - |
| `lastlogin_at` | `timestamp with time zone` | - | `now()` |

---

### 2. `kolam` (Pools/Ponds)
Stores information about the pools or ponds being managed.

| Column | Type | Constraints | Default |
| :--- | :--- | :--- | :--- |
| `id` | `uuid` | Primary Key | `gen_random_uuid()` |
| `created_at` | `timestamp with time zone` | Not Null | `now()` |
| `created_by` | `bigint` | Foreign Key (`akun.id`) | - |
| `lokasi` | `text` | - | - |

---

### 3. `data_sensor` (Sensor Data)
Stores historical sensor readings for each pool.

| Column | Type | Constraints | Default |
| :--- | :--- | :--- | :--- |
| `id` | `uuid` | Primary Key | `gen_random_uuid()` |
| `created_at` | `timestamp with time zone` | Not Null | `now()` |
| `ph` | `double precision` | - | - |
| `temp` | `double precision` | - | - |
| `ketinggian` | `real` | - | - |
| `amonia` | `double precision` | - | - |
| `kolam_id` | `uuid` | Foreign Key (`kolam.id`) | - |

## Relationships
- One **Account** (`akun`) can own multiple **Pools** (`kolam`).
- One **Pool** (`kolam`) has many **Sensor Data** (`data_sensor`) entries.

---
*Note: This schema is documented for development context and reflects the current state of the Supabase backend.*
