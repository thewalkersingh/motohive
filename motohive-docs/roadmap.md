# Motohive — Build Roadmap

Discipline: **schema first, vertical slice second, logic last.**
Each step ends with a review checkpoint before the next begins.

---

## Step 0 — Project bootstrap  ← current

- Repo layout (monorepo)
- `.gitignore`, `README.md`, this roadmap
- Spring Boot skeleton (`motohive-api`) — package tree as agreed, no logic
- React skeleton (`motohive-web`)
- `docker-compose` with Postgres
- `application.yml` profiles (local, dev, prod placeholders)
- Locked design artifacts copied into `motohive-docs/design/`

**Exit criteria:** apps boot, Postgres runs locally, folder structure matches design.

---

## Step 1 — DDL baseline (Flyway V1)

- All enums as check-constrained `varchar`
- UUID primary keys (`gen_random_uuid()` in DB)
- Tables in dependency order:
  `user` → `provider` (dealer/inspector) → `vehicle` (+ subtype) →
  `inspection` (+ checklist template/version, certificate) →
  `listing` (+ price history, featured, provenance) → `buyout` →
  `reservation` (+ waitlist, token ledger) → `viewing` →
  `transaction` (+ payout ledger) → `rating` →
  `state_machine_definition`, `state_transition`, `audit_log` →
  `commission_config`, `segment_policy`, `notification_template`, `announcement`
- Constraints, uniques, partial indexes; money as `numeric(14,2)`

**Exit criteria:** raw SQL review passes; no JPA mappings yet.

---

## Step 2 — Domain enums + state machine (typed, inert)

- Enums, `StateMachine` / `Guard` / `SideEffect` interfaces
- `StateMachineRegistry`
- Seed definitions for `VehicleListingMachine`, `ReservationMachine`
- Audit as global side-effect (wired but inert)

**Exit criteria:** a test can load a machine definition and list legal transitions.

---

## Step 3 — First vertical slice: the trust spine

- `identity` (auth + roles), `provider`, `vehicle`
- `inspection`: request → assign (proximity-suggested) → report → certify/reject
- Admin surfaces for assignment and certification
- Audit trail visible end-to-end

**Exit criteria:** a vehicle moves REQUESTED → CERTIFIED with full audit trail.

---

## Step 4 — Listing + public browse
## Step 5 — Buyout, reservation, viewing
## Step 6 — Transaction, payout ledger, rating
## Step 7 — Email notifications + templates
## Step 8 — React surfaces for each shipped slice

(Deliberately not detailed yet — expanded as each approaches.)

---

## Decisions locked (see motohive-docs/adr)

- Monorepo, `motohive-api` naming
- Check-constrained varchar enums
- UUID PKs, DB-generated
- Config-driven state machine (reusable for Phase 3 document workflows)
- Capability-based provider permissions (Phase 2/3 extension point)
- Postgres + Flyway