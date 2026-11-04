-- ============================================================
-- V7: state machine definitions + audit log + notification templates + announcements
-- Final schema chunk. Seeds for VehicleListingMachine and ReservationMachine.
-- ============================================================

-- ---------- state machine definition (config-driven; reusable for Phase 3) ----------
create table state_machine_definition (
                                         id              uuid primary key default gen_random_uuid(),
                                         name            varchar(60) not null,
                                         entity_type     varchar(60) not null,
                                         version_no      int         not null default 1,
                                         active          boolean     not null default true,
                                         description     varchar(200),
                                         created_at      timestamptz not null default now()
);
create unique index ux_sm_def_active
   on state_machine_definition (name) where active;

-- ---------- individual transitions ----------
create table state_transition (
                                 id              uuid primary key default gen_random_uuid(),
                                 machine_id      uuid        not null references state_machine_definition(id) on delete cascade,
                                 event           varchar(40) not null,
                                 from_state      varchar(40) not null,
                                 to_state        varchar(40) not null,
                                 guard_key       varchar(80),            -- name of guard bean; null = always allowed
                                 effect_keys     jsonb       not null default '[]'::jsonb, -- list of side-effect bean names
                                 created_at      timestamptz not null default now(),

                                 unique (machine_id, event, from_state)
);
create index ix_transition_machine on state_transition (machine_id, from_state);

-- ---------- audit log (every state transition; jsonb before/after) ----------
create table audit_log (
                          id              uuid primary key default gen_random_uuid(),
                          entity_type     varchar(60) not null,
                          entity_id       uuid        not null,
                          event           varchar(40) not null,
                          actor_user_id   uuid        references app_user(id),
                          before_json     jsonb,
                          after_json      jsonb,
                          notes           varchar(400),
                          created_at      timestamptz not null default now()
);
create index ix_audit_entity on audit_log (entity_type, entity_id, created_at desc);
create index ix_audit_actor  on audit_log (actor_user_id) where actor_user_id is not null;

comment on table audit_log is
'Every state transition writes one row. before/after jsonb only on transitions; null for informational events.';

-- ---------- notification templates ----------
create table notification_template (
                                      id              uuid primary key default gen_random_uuid(),
                                      code            varchar(60) not null,
                                      channel         varchar(20) not null default 'EMAIL'
                                         constraint chk_notif_channel check (channel in ('EMAIL','SMS','IN_APP')),
                                      subject         varchar(200),
                                      body            text        not null,
                                      active          boolean     not null default true,
                                      created_at      timestamptz not null default now(),
                                      updated_at      timestamptz not null default now(),
                                      version         int         not null default 0
);
create unique index ux_notif_template_code_channel_active
   on notification_template (code, channel) where active;

-- ---------- site announcements (banners, posters — admin editable) ----------
create table announcement (
                             id              uuid primary key default gen_random_uuid(),
                             title           varchar(200) not null,
                             body            text,
                             image_url       varchar(500),
                             placement       varchar(30) not null default 'HOME_BANNER'
                                constraint chk_announcement_placement check (placement in
                      ('HOME_BANNER','VIEWING_INFO','LISTING_TOP','FOOTER')),
                             active          boolean     not null default true,
                             starts_at       timestamptz not null default now(),
                             ends_at         timestamptz,
                             created_by      uuid        not null references app_user(id),
                             created_at      timestamptz not null default now(),
                             updated_at      timestamptz not null default now(),
                             version         int         not null default 0,

                             constraint chk_announcement_window check (ends_at is null or ends_at > starts_at)
);
create index ix_announcement_active on announcement (placement, starts_at)
   where active;

-- ============================================================
-- SEED: VehicleListingMachine
-- ============================================================
with m as (
insert into state_machine_definition (name, entity_type, description)
   values ('VehicleListingMachine', 'Vehicle', 'Generic-seller vehicle lifecycle')
      returning id
)
insert into state_transition (machine_id, event, from_state, to_state, guard_key, effect_keys) values
                                                                                                  ((select id from m), 'ASSIGN_INSPECTOR',   'REQUESTED',           'ASSIGNED',           'requiresInspector',    '["audit","notifyInspectorAssigned"]'),
                                                                                                  ((select id from m), 'SUBMIT_REPORT_OK',   'ASSIGNED',            'INSPECTED',          'reportIsCertified',    '["audit","notifyInspectorReportOk"]'),
                                                                                                  ((select id from m), 'SUBMIT_REPORT_FAIL', 'ASSIGNED',            'INSPECTED',          'reportIsRejected',     '["audit","notifyInspectorReportFail"]'),
                                                                                                  ((select id from m), 'CERTIFY',            'INSPECTED',           'CERTIFIED',          'verdictCertified',     '["audit","issueCertificate","payBaseFee","notifyCertified"]'),
                                                                                                  ((select id from m), 'REJECT',             'INSPECTED',           'REJECTED',           'verdictRejected',      '["audit","notifyRejected"]'),
                                                                                                  ((select id from m), 'OFFER_DEALERS',      'CERTIFIED',           'OFFERED_TO_DEALERS',  'hasFloorPrice',        '["audit","openBuyoutOffers"]'),
                                                                                                  ((select id from m), 'PUBLISH',            'CERTIFIED',           'LISTED',              'certificateActive',    '["audit","publishListing"]'),
                                                                                                  ((select id from m), 'PUBLISH',            'OFFERED_TO_DEALERS',  'LISTED',              'certificateActive',    '["audit","publishListing"]'),
                                                                                                  ((select id from m), 'DEALER_BUYOUT',      'OFFERED_TO_DEALERS',  'SOLD',                'buyoutAccepted',       '["audit","payInspectorBonus","paySellerFloor","openDealerListing"]'),
                                                                                                  ((select id from m), 'RESERVE',            'LISTED',              'RESERVED',            'tokenHeld',            '["audit","notifyBuyerReserved"]'),
                                                                                                  ((select id from m), 'RELEASE',            'RESERVED',            'LISTED',              'tokenReleased',        '["audit","notifyWaitlist"]'),
                                                                                                  ((select id from m), 'SELL',               'RESERVED',            'SOLD',                'docsTransferred',      '["audit","confirmTransaction"]'),
                                                                                                  ((select id from m), 'EXPIRE_CERT',        'CERTIFIED',           'EXPIRED',             'certificateExpired',   '["audit","notifyExpired"]'),
                                                                                                  ((select id from m), 'REINSTATE',          'EXPIRED',             'REQUESTED',           'cooldownElapsed',      '["audit"]'),
                                                                                                  ((select id from m), 'REINSTATE',          'REJECTED',            'REQUESTED',           'cooldownElapsed',      '["audit"]');

-- ============================================================
-- SEED: ReservationMachine
-- ============================================================
with m as (
insert into state_machine_definition (name, entity_type, description)
   values ('ReservationMachine', 'Reservation', 'Token escrow reservation lifecycle')
      returning id
)
insert into state_transition (machine_id, event, from_state, to_state, guard_key, effect_keys) values
                                                                                                  ((select id from m), 'REFUND',    'HELD', 'REFUNDED',  'windowExpiredOrCancelled', '["audit","refundToken","notifyBuyerRefunded"]'),
                                                                                                  ((select id from m), 'FORFEIT',   'HELD', 'FORFEITED', 'buyerWithdrew',            '["audit","forfeitToken"]'),
                                                                                                  ((select id from m), 'CONVERT',   'HELD', 'CONVERTED', 'docsTransferred',          '["audit","convertToken","linkTransaction"]'),
                                                                                                  ((select id from m), 'CANCEL',    'HELD', 'CANCELLED', 'adminCancelled',           '["audit","refundToken"]');

-- ============================================================
-- SEED: notification templates (v1)
-- ============================================================
insert into notification_template (code, channel, subject, body) values
                                                                    ('VIEWING_REQUESTED',       'EMAIL', 'New viewing request on Motohive',       'Dear {{owner}}, you have a viewing request for listing {{listingTitle}} on {{slot}}. Please acknowledge.'),
                                                                    ('VIEWING_CONFIRMED_BUYER', 'EMAIL', 'Your Motohive viewing is confirmed',    'Hi {{buyer}}, your viewing for {{listingTitle}} is confirmed on {{slot}}. See you there.'),
                                                                    ('VIEWING_REMINDER',        'EMAIL', 'Reminder: your viewing is tomorrow',    'Hi {{recipient}}, this is a reminder for your {{listingTitle}} viewing on {{slot}}.'),
                                                                    ('INSPECTION_ASSIGNED',     'EMAIL', 'New config assigned',              'Hi {{inspector}}, config {{inspectionId}} for {{vehicleTitle}} is assigned to you at {{slot}}.'),
                                                                    ('INSPECTION_CERTIFIED',    'EMAIL', 'Your vehicle is Motohive certified',   'Hi {{seller}}, {{vehicleTitle}} passed config and is now listed on Motohive.'),
                                                                    ('INSPECTION_REJECTED',     'EMAIL', 'Inspection report for your vehicle',   'Hi {{seller}}, {{vehicleTitle}} was not certified. Review the correction list: {{defectsUrl}}.'),
                                                                    ('LISTING_PUBLISHED',       'EMAIL', 'Your listing is live on Motohive',      'Hi {{seller}}, {{listingTitle}} is now live.'),
                                                                    ('RESERVATION_HELD',        'EMAIL', 'Your reservation is confirmed',        'Hi {{buyer}}, token received. {{listingTitle}} is reserved for you until {{expiresAt}}.'),
                                                                    ('RESERVATION_REFUNDED',    'EMAIL', 'Your reservation was released',        'Hi {{buyer}}, the hold on {{listingTitle}} has expired and your token has been refunded.'),
                                                                    ('VEHICLE_SOLD',            'EMAIL', 'Vehicle sold',                          '{{recipient}}, {{listingTitle}} has been sold on Motohive. Payout details to follow.');