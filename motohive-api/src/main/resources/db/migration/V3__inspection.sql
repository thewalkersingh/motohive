-- ============================================================
-- V3: inspection request, report, checklist template, certificate
-- Generic-seller vehicles only. Dealer listings bypass this entirely.
-- ============================================================

-- ---------- checklist template (versioned; evolves without breaking old reports) ----------
create table checklist_template (
                                   id              uuid primary key default gen_random_uuid(),
                                   name            varchar(80) not null,
                                   segment         varchar(20) not null
                                      constraint chk_checklist_segment check (segment in
                      ('COMMUTER','PREMIUM','SUPERBIKE','VINTAGE','EV')),
                                   subtype         varchar(20) not null
                                      constraint chk_checklist_subtype check (subtype in
                      ('MOTORCYCLE','SCOOTER','MOPED','E_BIKE','E_SCOOTER')),
                                   active          boolean     not null default true,
                                   created_at      timestamptz not null default now()
);
create unique index ux_checklist_template_active
   on checklist_template (segment, subtype) where active;

create table checklist_template_version (
                                           id              uuid primary key default gen_random_uuid(),
                                           template_id     uuid        not null references checklist_template(id) on delete cascade,
                                           version_no      int         not null,
                                           schema_json     jsonb       not null,   -- ordered list of checklist items + validation rules
                                           created_at      timestamptz not null default now(),
                                           unique (template_id, version_no)
);
create index ix_checklist_version_template on checklist_template_version (template_id, version_no desc);

comment on table checklist_template_version is
'Immutable once created. Reports pin a version_no, so edits never rewrite history.';

-- ---------- inspection request ----------
create table inspection_request (
                                   id                uuid primary key default gen_random_uuid(),
                                   vehicle_id        uuid        not null references vehicle(id),
                                   seller_user_id    uuid        not null references app_user(id),
                                   inspector_id      uuid        references provider_profile(id),   -- null until assigned
                                   status            varchar(20) not null default 'REQUESTED'
                                      constraint chk_inspection_request_status check (status in
                        ('REQUESTED','ASSIGNED','INSPECTED','CERTIFIED','REJECTED',
                         'EXPIRED','CANCELLED')),
                                   pincode           varchar(10),
                                   lat               numeric(9,6),
                                   lng               numeric(9,6),
                                   requested_at      timestamptz not null default now(),
                                   assigned_at       timestamptz,
                                   scheduled_at      timestamptz,
                                   completed_at      timestamptz,
                                   created_at        timestamptz not null default now(),
                                   updated_at        timestamptz not null default now(),
                                   version           int         not null default 0
);
create index ix_inspection_request_status  on inspection_request (status);
create index ix_inspection_request_vehicle on inspection_request (vehicle_id);
create index ix_inspection_request_inspector on inspection_request (inspector_id)
   where status in ('ASSIGNED','INSPECTED');

-- At most one live request per vehicle at a time
create unique index ux_inspection_live_per_vehicle
   on inspection_request (vehicle_id)
   where status in ('REQUESTED','ASSIGNED');

-- ---------- inspection report ----------
create table inspection_report (
                                  id                       uuid primary key default gen_random_uuid(),
                                  inspection_request_id    uuid        not null references inspection_request(id) on delete cascade,
                                  inspector_id             uuid        not null references provider_profile(id),
                                  checklist_version_id     uuid        not null references checklist_template_version(id),
                                  checklist_data           jsonb       not null,
                                  photos                   jsonb       not null default '[]'::jsonb,
                                  verdict                  varchar(20) not null
                                     constraint chk_inspection_verdict check (verdict in
                               ('CERTIFIED','REJECTED')),
                                  defect_list              jsonb       not null default '[]'::jsonb,  -- structured list for seller
                                  provenance               jsonb       not null default '{}'::jsonb,  -- owners, accidents, service history
                                  notes                    text,
                                  created_at               timestamptz not null default now()
);
create unique index ux_inspection_report_request on inspection_report (inspection_request_id);

comment on column inspection_report.provenance is
'Free-form structured provenance captured during inspection. v1 keeps it as jsonb; promoted to typed fields in v1.1 if needed.';

-- ---------- certificate ----------
create table certificate (
                            id                      uuid primary key default gen_random_uuid(),
                            vehicle_id              uuid        not null references vehicle(id),
                            inspection_report_id    uuid        not null references inspection_report(id),
                            issued_at               timestamptz not null default now(),
                            expires_at              timestamptz not null,
                            status                  varchar(20) not null default 'ACTIVE'
                               constraint chk_certificate_status check (status in
                              ('ACTIVE','EXPIRED','REVOKED')),
                            created_at              timestamptz not null default now(),
                            updated_at              timestamptz not null default now(),
                            version                 int         not null default 0
);
-- At most one ACTIVE certificate per vehicle
create unique index ux_certificate_active_per_vehicle
   on certificate (vehicle_id) where status = 'ACTIVE';
create index ix_certificate_expiry on certificate (expires_at) where status = 'ACTIVE';

comment on table certificate is
'Only issued for generic-seller vehicles. Dealer listings bypass inspection by design.';