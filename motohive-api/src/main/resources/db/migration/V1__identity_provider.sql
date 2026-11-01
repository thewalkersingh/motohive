-- ============================================================
-- V1: identity + provider (users, roles, capabilities, dealers, inspectors)
-- ============================================================

-- ---------- user ----------
create table app_user (
                         id            uuid primary key default gen_random_uuid(),
                         name          varchar(120) not null,
                         email         varchar(255) not null,
                         phone         varchar(20),
                         status        varchar(20)  not null default 'ACTIVE'
                            constraint chk_user_status check (status in ('ACTIVE','SUSPENDED','CLOSED')),
                         created_at    timestamptz  not null default now(),
                         updated_at    timestamptz  not null default now(),
                         version       int          not null default 0
);
create unique index ux_user_email_lower on app_user (lower(email));
create unique index ux_user_phone       on app_user (phone) where phone is not null;

comment on table app_user is 'All accounts. Roles and capabilities are assigned separately.';

-- ---------- roles ----------
create table user_role (
                          user_id       uuid        not null references app_user(id) on delete cascade,
                          role          varchar(20) not null
                             constraint chk_role check (role in ('BUYER','SELLER','INSPECTOR','DEALER','ADMIN')),
                          created_at    timestamptz not null default now(),
                          primary key (user_id, role)
);

-- ---------- provider profile (base for dealers & inspectors; extends to garages in Phase 2) ----------
create table provider_profile (
                                 id              uuid primary key default gen_random_uuid(),
                                 user_id         uuid        not null references app_user(id),
                                 provider_type   varchar(20) not null
                                    constraint chk_provider_type check (provider_type in ('DEALER','INSPECTOR','GARAGE')),
                                 business_name   varchar(160),
                                 pincode         varchar(10),
                                 lat             numeric(9,6),
                                 lng             numeric(9,6),
                                 internal_score  numeric(5,2) not null default 0,
                                 status          varchar(20) not null default 'ACTIVE'
                                    constraint chk_provider_status check (status in ('ACTIVE','SUSPENDED','CLOSED')),
                                 created_at      timestamptz not null default now(),
                                 updated_at      timestamptz not null default now(),
                                 version         int         not null default 0
);
create unique index ux_provider_user_type on provider_profile (user_id, provider_type);
create index ix_provider_pincode           on provider_profile (pincode) where status = 'ACTIVE';

comment on table provider_profile is
'Base for any service provider. Phase 2 garages become another provider_type, not a new table.';

-- ---------- capabilities (extension point for Phase 2/3) ----------
create table provider_capability (
                                    provider_id   uuid        not null references provider_profile(id) on delete cascade,
                                    capability    varchar(30) not null
                                       constraint chk_capability check (capability in
                    ('SELLS_VEHICLES','INSPECTS','SERVICES','SELLS_PARTS','HANDLES_DOCS')),
                                    created_at    timestamptz not null default now(),
                                    primary key (provider_id, capability)
);

-- ---------- specializations (segment / subtype matching) ----------
create table provider_specialization (
                                        provider_id      uuid        not null references provider_profile(id) on delete cascade,
                                        specialization   varchar(40) not null
                                           constraint chk_specialization check (specialization in
                       ('MOTORCYCLE','SCOOTER','MOPED','E_BIKE','E_SCOOTER','PREMIUM','VINTAGE')),
                                        created_at       timestamptz not null default now(),
                                        primary key (provider_id, specialization)
);

-- ---------- dealer profile ----------
create table dealer_profile (
                               provider_id              uuid primary key references provider_profile(id) on delete cascade,
                               commission_rate_override numeric(5,2),
                               security_held            numeric(14,2) not null default 0,
                               created_at               timestamptz   not null default now(),
                               updated_at               timestamptz   not null default now(),
                               version                  int           not null default 0
);

-- ---------- inspector profile ----------
create table inspector_profile (
                                  provider_id           uuid primary key references provider_profile(id) on delete cascade,
                                  base_fee              numeric(14,2) not null default 0,
                                  success_bonus_rate    numeric(5,2)  not null default 1.0,
                                  availability          varchar(20)   not null default 'AVAILABLE'
                                     constraint chk_availability check (availability in
                            ('AVAILABLE','BUSY','OFFLINE')),
                                  created_at            timestamptz   not null default now(),
                                  updated_at            timestamptz   not null default now(),
                                  version               int           not null default 0
);