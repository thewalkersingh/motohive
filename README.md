# Motohive

A trusted marketplace for **premium used two-wheelers (>200cc)**, starting with
verified listings for high-CC bikes and expanding to cars and other vehicles.

Motohive is a **platform**, not a reseller. Vehicles are listed by dealers or by
individual sellers whose bikes pass a platform-arranged inspection and certification.

---

## Long-term vision

| Phase | Scope |
|-------|-------|
| 1 (now) | Premium two-wheeler listings, verified inspection, viewing, reservation |
| 2 | Garage / mechanic services, parts & products marketplace |
| 3 | RTO & document services (transfer, registration, renewal) |

The data model and state-machine engine are designed so Phase 2/3 add
**capabilities and workflow definitions**, not new silos.

---

## Repository layout

```
motohive/
├── motohive-api/      Spring Boot 3 (Java 21) backend
├── motohive-web/      React (Vite) frontend
├── motohive-docs/     Design docs, roadmap, ADRs
│   ├── design/        Locked design artifacts (ER, state machines, money flow)
│   └── adr/           Architecture Decision Records
├── infra/             Local dev infrastructure (docker-compose, Postgres)
└── README.md
```

---

## Tech stack

- **Backend:** Spring Boot 3, Java 21, PostgreSQL, Flyway
- **Frontend:** React (Vite), TypeScript
- **Auth:** JWT (access + refresh); OTP for sellers/buyers, password for admin (TBD per ADR)
- **Local dev:** Docker Compose (Postgres)

---

## Core concepts (short version — full detail in motohive-docs/design)

- **Accounts hold roles:** `BUYER`, `SELLER`, `INSPECTOR`, `DEALER`, `ADMIN`.
  One account may hold multiple roles. Permissions are role-scoped.
- **Providers** (dealers, inspectors, later garages) carry **capabilities**
  (`SELLS_VEHICLES`, `INSPECTS`, later `SERVICES`, `HANDLES_DOCS`).
- **Generic-seller flow:** REQUESTED → ASSIGNED → INSPECTED → CERTIFIED →
  (OFFERED_TO_DEALERS) → LISTED → RESERVED → SOLD, with REJECTED and EXPIRED.
- **Dealer listings** are self-managed; the dealer is solely accountable and
  earns commission after a confirmed sale.
- **Inspection payout:** base fee paid by the platform on inspection; success
  bonus paid on sale (or dealer buyout).
- **Reservation:** token money held by the platform (escrow); exclusive window
  with a waitlist, no auto-break.
- **State changes are config-driven** and audited on every transition.

---

## Getting started

See `motohive-docs/roadmap.md` for build sequence.
Local setup instructions are added as each part of the stack lands
(backend, frontend, database).

---

## Status

Early bootstrap. No application logic yet — schema and project skeleton first.
