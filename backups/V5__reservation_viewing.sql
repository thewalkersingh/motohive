-- ============================================================
-- V5: reservation (token escrow) + waitlist + viewing appointments
-- ============================================================

-- ---------- reservation (exclusive hold via token) ----------
create table reservation (
                            id                uuid primary key default gen_random_uuid(),
                            listing_id        uuid        not null references listing(id),
                            buyer_user_id     uuid        not null references app_user(id),
                            token_amount      numeric(14,2) not null,
                            status            varchar(20) not null default 'HELD'
                               constraint chk_reservation_status check (status in
                        ('HELD','REFUNDED','FORFEITED','CONVERTED','CANCELLED')),
                            held_at           timestamptz not null default now(),
                            expires_at        timestamptz not null,
                            released_at       timestamptz,
                            converted_sale_id uuid,                    -- FK added in V6 after sale table exists
                            created_at        timestamptz not null default now(),
                            updated_at        timestamptz not null default now(),
                            version           int         not null default 0,

                            constraint chk_reservation_token_positive check (token_amount > 0),
                            constraint chk_reservation_expiry_after_hold check (expires_at > held_at)
);
create index ix_reservation_listing  on reservation (listing_id);
create index ix_reservation_buyer    on reservation (buyer_user_id);
create index ix_reservation_expiry   on reservation (expires_at) where status = 'HELD';

-- At most one HELD reservation per listing
create unique index ux_reservation_held_per_listing
   on reservation (listing_id) where status = 'HELD';

comment on table reservation is
'Exclusive hold bought by a buyer token. HELD blocks new inquiries; expiry auto-releases.';

-- ---------- waitlist (captures buyers during HELD window) ----------
create table reservation_waitlist (
                                     id              uuid primary key default gen_random_uuid(),
                                     listing_id      uuid        not null references listing(id),
                                     buyer_user_id   uuid        not null references app_user(id),
                                     position        int         not null,
                                     status          varchar(20) not null default 'WAITING'
                                        constraint chk_waitlist_status check (status in
                      ('WAITING','OFFERED','CONVERTED','EXPIRED','CANCELLED')),
                                     created_at      timestamptz not null default now(),
                                     updated_at      timestamptz not null default now(),
                                     unique (listing_id, buyer_user_id)
);
create index ix_waitlist_listing_pos on reservation_waitlist (listing_id, position)
   where status = 'WAITING';

-- ---------- token ledger (manual-record in v1; real payment gateway v1.1) ----------
create table token_ledger (
                             id              uuid primary key default gen_random_uuid(),
                             reservation_id  uuid        not null references reservation(id) on delete cascade,
                             entry_type      varchar(20) not null
                                constraint chk_token_entry check (entry_type in
                      ('RECEIVED','REFUNDED','FORFEITED','CONVERTED')),
                             beneficiary     varchar(20) not null
                                constraint chk_token_beneficiary check (beneficiary in
                      ('PLATFORM','BUYER','SELLER')),
                             amount          numeric(14,2) not null,
                             recorded_by     uuid        not null references app_user(id),    -- admin in v1
                             note            varchar(200),
                             created_at      timestamptz not null default now(),
                             constraint chk_token_amount_positive check (amount > 0)
);
create index ix_token_ledger_reservation on token_ledger (reservation_id, created_at desc);

-- ---------- viewing appointments (orthogonal to listing status) ----------
create table viewing_appointment (
                                    id                  uuid primary key default gen_random_uuid(),
                                    listing_id          uuid        not null references listing(id),
                                    visitor_user_id     uuid        not null references app_user(id),
                                    slot_start          timestamptz not null,
                                    slot_end            timestamptz not null,
                                    status              varchar(20) not null default 'REQUESTED'
                                       constraint chk_viewing_status check (status in
                          ('REQUESTED','CONFIRMED','COMPLETED','NO_SHOW','CANCELLED')),
                                    parent_request_id   uuid        references viewing_appointment(id),   -- 2-slot flexibility, unused in v1
                                    slot_rank           int         not null default 1,
                                    acknowledged_at     timestamptz,          -- when listing party acknowledged (SLA start)
                                    sla_met             boolean,
                                    created_at          timestamptz not null default now(),
                                    updated_at          timestamptz not null default now(),
                                    version             int         not null default 0,

                                    constraint chk_viewing_slot_order check (slot_end > slot_start)
);
create index ix_viewing_listing  on viewing_appointment (listing_id);
create index ix_viewing_visitor  on viewing_appointment (visitor_user_id);
create index ix_viewing_upcoming on viewing_appointment (slot_start)
   where status in ('REQUESTED','CONFIRMED');
create index ix_viewing_parent   on viewing_appointment (parent_request_id)
   where parent_request_id is not null;