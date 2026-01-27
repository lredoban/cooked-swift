# Cooked — Database Schema

> Auto-documented from Supabase production state. Last updated: 2026-01-27.

## Tables

### `recipes`
| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| id | uuid | NO | `uuid_generate_v4()` | PK |
| user_id | uuid | NO | — | FK → `auth.users.id` |
| title | text | NO | — | |
| source_type | text | YES | — | CHECK: `video`, `url`, `manual` |
| source_url | text | YES | — | |
| source_name | text | YES | — | |
| image_url | text | YES | — | |
| status | text | YES | `'active'` | CHECK: `importing`, `pending_review`, `active`, `failed` |
| ingredients | jsonb | NO | `'[]'` | |
| steps | jsonb | NO | `'[]'` | |
| tags | text[] | YES | `'{}'` | |
| times_cooked | integer | YES | `0` | |
| deleted | boolean | NO | `false` | Soft-delete (Legend State) |
| created_at | timestamptz | YES | `now()` | |
| updated_at | timestamptz | YES | `now()` | |

RLS: enabled

---

### `menus`
| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| id | uuid | NO | `uuid_generate_v4()` | PK |
| user_id | uuid | NO | — | FK → `auth.users.id` |
| status | text | NO | `'planning'` | CHECK: `planning`, `to_cook`, `archived` |
| archived_at | timestamptz | YES | — | |
| deleted | boolean | NO | `false` | Soft-delete |
| created_at | timestamptz | YES | `now()` | |
| updated_at | timestamptz | YES | `now()` | |

RLS: enabled

---

### `menu_recipes`
| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| id | uuid | NO | `uuid_generate_v4()` | PK |
| menu_id | uuid | NO | — | FK → `menus.id` |
| recipe_id | uuid | NO | — | FK → `recipes.id` |
| is_cooked | boolean | YES | `false` | |
| cooked_at | timestamptz | YES | — | |
| position | integer | NO | `0` | |
| added_at | timestamptz | YES | `now()` | |
| deleted | boolean | NO | `false` | Soft-delete |
| created_at | timestamptz | YES | `now()` | |
| updated_at | timestamptz | YES | `now()` | |

RLS: enabled

---

### `grocery_lists`
| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| id | uuid | NO | `uuid_generate_v4()` | PK |
| menu_id | uuid | NO | — | FK → `menus.id`, UNIQUE |
| items | jsonb | NO | `'[]'` | |
| staples_confirmed | text[] | YES | `'{}'` | |
| deleted | boolean | NO | `false` | Soft-delete |
| created_at | timestamptz | YES | `now()` | |
| updated_at | timestamptz | YES | `now()` | |

RLS: enabled

---

### `user_settings`
| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| user_id | uuid | NO | — | PK, FK → `auth.users.id` |
| subscription_status | text | YES | `'free'` | CHECK: `free`, `pro` |
| video_imports_this_month | integer | YES | `0` | |
| video_imports_reset_at | timestamptz | YES | `now() + '1 mon'` | |
| custom_staples | text[] | YES | `'{}'` | |
| created_at | timestamptz | YES | `now()` | |
| updated_at | timestamptz | YES | `now()` | |

RLS: enabled

---

## Migrations

| Version | Name |
|---------|------|
| 20260121160045 | `fix_create_user_settings_function` |
| 20260122105610 | `add_deleted_column_for_legend_state` |
| 20260127* | `add_status_column_to_recipes` |
