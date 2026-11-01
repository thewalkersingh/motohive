-- ============================================================
-- V6: transaction (sale) + payout ledger + provider rating events
-- ============================================================

-- ---------- transaction (sale of a listing; expands to services/parts in Phase 2) ----------
create table txn (
                    id                    uuid primary key default gen_random_uuid(),
                    listing_id            uuid        not null references listing(id),
                    buyer_user_id         uuid        references app_user(id),           -- null for buyout
                    txn_type              varchar(30) not null default 'VEHICLE_SALE'
                       constraint chk_txn_type check (txn_type in
                            ('VEHICLE_SALE','SERVICE_BOOKING','PART_PURCHASE')),
                    sale_price            numeric(14,2) not null,
                    inspector_cut         numeric(14,2) not null default 0,
                    platform_cut          numeric(14,2) not null default 0,
                    seller_payout         numeric(14,2) not null default 0,
                    dealer_commission     numeric(14,2) not null default 0,
                    buyout_flag           boolean     not null default false,
                    buyout_dealer_id      uuid        references provider_profile(id),   -- set when buyout
                    sold_at               timestamptz not null default now(),
                    confirmed_by_admin_id uuid        not null references app_user(id),
                    created_at            timestamptz not null default now(),
                    updated_at            timestamptz not null default now(),
                    version               int         not null default 0,

                    constraint chk_txn_sale_price_positive check (sale_price > 0),
                    constraint chk_txn_cuts_nonnegative check (
                       inspector_cut >= 0 and platform_cut >= 0 and
                       seller_payout >= 0 and dealer_commission >= 0
                       ),
                    constraint chk_txn_buyout_consistency check (
                       (buyout_flag = false and buyout_dealer_id is null) or
                       (buyout_flag = true  and buyout_dealer_id is not null and buyer_user_id is null)
                       )
);
create index ix_txn_listing  on txn (listing_id);
create index ix_txn_buyer    on txn (buyer_user_id) where buyer_user_id is not null;
create index ix_txn_sold_at  on txn (sold_at desc);

-- At most one VEHICLE_SALE transaction per listing
create unique index ux_txn_sale_per_listing
   on txn (listing_id) where txn_type = 'VEHICLE_SALE';

comment on table txn is
'Rename-safe: txn is generic. Phase 2 adds SERVICE_BOOKING and PART_PURCHASE rows without schema change.';

-- ---------- payout ledger (all money owed to users, append-only) ----------
create table payout_ledger (
                              id              uuid primary key default gen_random_uuid(),
                              user_id         uuid        not null references app_user(id),
                              provider_id     uuid        references provider_profile(id),
                              entry_type      varchar(30) not null
                                 constraint chk_payout_type check (entry_type in
                      ('BASE_FEE','SUCCESS_BONUS','SELLER_PAYOUT',
                       'DEALER_COMMISSION','CLAWBACK')),
                              amount          numeric(14,2) not null,
                              status          varchar(20) not null default 'PENDING'
                                 constraint chk_payout_status check (status in
                      ('PENDING','PAID','CLAWED_BACK')),
                              txn_id          uuid        references txn(id),
                              inspection_id   uuid        references inspection_request(id),
                              note            varchar(200),
                              created_at      timestamptz not null default now(),
                              paid_at         timestamptz,
                              created_by      uuid        references app_user(id),    -- null means SYSTEM

                              constraint chk_payout_amount_not_zero check (amount <> 0)
);
create index ix_payout_user       on payout_ledger (user_id, created_at desc);
create index ix_payout_status     on payout_ledger (status);
create index ix_payout_txn        on payout_ledger (txn_id) where txn_id is not null;
create index ix_payout_inspection on payout_ledger (inspection_id) where inspection_id is not null;

comment on table payout_ledger is
'Append-only. A clawback is a new negative-amount row, never a mutation of a PAID row.';

-- ---------- provider rating events (internal trust score) ----------
create table provider_rating_event (
                                      id              uuid primary key default gen_random_uuid(),
                                      provider_id     uuid        not null references provider_profile(id),
                                      dimension       varchar(30) not null
                                         constraint chk_rating_dimension check (dimension in
                      ('INSPECTION_QUALITY','LISTING_ACCURACY','SERVICE_QUALITY')),
                                      event_type      varchar(40) not null,
                                      weight          numeric(6,2) not null,
                                      source_ref      uuid,       -- FK-less pointer to whatever caused it
                                      source_type     varchar(30),
                                      note            varchar(200),
                                      created_at      timestamptz not null default now()
);
create index ix_rating_provider on provider_rating_event (provider_id, created_at desc);

-- ---------- close the reservation → sale loop ----------
alter table reservation
   add constraint fk_reservation_sale
      foreign key (converted_sale_id) references txn(id);