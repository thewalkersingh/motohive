-- ============================================================
-- V4: listing + price history + buyout offers
-- ============================================================

-- ---------- listing ----------
create table listing (
                        id                  uuid primary key default gen_random_uuid(),
                        vehicle_id          uuid        not null references vehicle(id),
                        owner_type          varchar(20) not null
                           constraint chk_listing_owner_type check (owner_type in ('PLATFORM','DEALER')),
                        owner_user_id       uuid        not null references app_user(id),
                        dealer_provider_id  uuid        references provider_profile(id),
                        asking_price        numeric(14,2) not null,
                        floor_price         numeric(14,2),           -- internal only; never returned by public API
                        status              varchar(20) not null default 'DRAFT'
                           constraint chk_listing_status check (status in
                          ('DRAFT','LISTED','RESERVED','SOLD','SOLD_VIA_BUYOUT',
                           'WITHDRAWN','EXPIRED')),
                        featured            boolean     not null default false,
                        featured_by_admin_id uuid       references app_user(id),
                        featured_at         timestamptz,
                        published_at        timestamptz,
                        sold_at             timestamptz,
                        expires_at          timestamptz,
                        created_at          timestamptz not null default now(),
                        updated_at          timestamptz not null default now(),
                        version             int         not null default 0,

                        constraint chk_listing_dealer_consistency check (
                           (owner_type = 'DEALER'   and dealer_provider_id is not null) or
                           (owner_type = 'PLATFORM' and dealer_provider_id is null)
                           ),
                        constraint chk_listing_price_positive check (asking_price > 0),
                        constraint chk_listing_floor_le_asking check (floor_price is null or floor_price <= asking_price),
                        constraint chk_listing_featured_audit check (
                           (featured = false and featured_by_admin_id is null and featured_at is null) or
                           (featured = true  and featured_by_admin_id is not null and featured_at is not null)
                           )
);
create index ix_listing_vehicle     on listing (vehicle_id);
create index ix_listing_status      on listing (status);
create index ix_listing_dealer      on listing (dealer_provider_id) where dealer_provider_id is not null;
create index ix_listing_featured    on listing (featured, published_at desc) where featured and status = 'LISTED';

-- At most one live listing per vehicle at a time
create unique index ux_listing_live_per_vehicle
   on listing (vehicle_id)
   where status in ('DRAFT','LISTED','RESERVED');

comment on column listing.floor_price is
'Internal negotiation floor. Never exposed to buyers; only used for buyout offers to dealers.';

-- ---------- price history ----------
create table listing_price_history (
                                      id            uuid primary key default gen_random_uuid(),
                                      listing_id    uuid        not null references listing(id) on delete cascade,
                                      asking_price  numeric(14,2) not null,
                                      floor_price   numeric(14,2),
                                      changed_by    uuid        not null references app_user(id),
                                      reason        varchar(200),
                                      created_at    timestamptz not null default now()
);
create index ix_price_history_listing on listing_price_history (listing_id, created_at desc);

-- ---------- buyout offer ----------
create table buyout_offer (
                             id              uuid primary key default gen_random_uuid(),
                             listing_id      uuid        not null references listing(id) on delete cascade,
                             dealer_id       uuid        not null references provider_profile(id),
                             floor_price     numeric(14,2) not null,     -- snapshot of listing floor at offer time
                             status          varchar(20) not null default 'OFFERED'
                                constraint chk_buyout_offer_status check (status in
                      ('OFFERED','ACCEPTED','DECLINED','EXPIRED','CANCELLED')),
                             offered_at      timestamptz not null default now(),
                             expires_at      timestamptz not null,
                             responded_at    timestamptz,
                             created_at      timestamptz not null default now(),
                             updated_at      timestamptz not null default now(),
                             version         int         not null default 0
);
create index ix_buyout_offer_listing on buyout_offer (listing_id);
create index ix_buyout_offer_dealer  on buyout_offer (dealer_id) where status = 'OFFERED';
create index ix_buyout_offer_expiry  on buyout_offer (expires_at) where status = 'OFFERED';

-- At most one ACCEPTED buyout per listing
create unique index ux_buyout_accepted_per_listing
   on buyout_offer (listing_id) where status = 'ACCEPTED';