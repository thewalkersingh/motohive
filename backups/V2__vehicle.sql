-- ============================================================
-- V2: vehicle + subtypes + segment policy + commission config
-- ============================================================

-- ---------- segment policy (vehicle eligibility; tunable, not hardcoded) ----------
CREATE TABLE segment_policy
(
   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
   segment       varchar(20) NOT NULL CONSTRAINT chk_segment_policy_segment CHECK (segment IN
                      ('COMMUTER','PREMIUM','SUPERBIKE','VINTAGE','EV')),
   min_engine_cc int         NOT NULL DEFAULT 0,
   max_engine_cc int,
   active        boolean     NOT NULL DEFAULT TRUE,
   effective_from timestamptz NOT NULL DEFAULT now(),
   created_at timestamptz NOT NULL DEFAULT now(),
   updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX ux_segment_policy_active ON segment_policy (segment) WHERE ACTIVE;

-- ---------- commission config (rates, versioned by effective date) ----------
CREATE TABLE commission_config
(
   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
   role     varchar(20)   NOT NULL CONSTRAINT chk_commission_role CHECK (ROLE IN
                      ('PLATFORM_GENERIC','PLATFORM_DEALER','INSPECTOR_SUCCESS')),
   rate_pct numeric(5, 2) NOT NULL,
   effective_from timestamptz NOT NULL DEFAULT now(),
   created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ix_commission_config_role_effective
   ON commission_config (role, effective_from DESC);

-- ---------- vehicle (base) ----------
CREATE TABLE vehicle
(
   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
   vehicle_type     varchar(20) NOT NULL CONSTRAINT chk_vehicle_type CHECK (vehicle_type IN ('TWO_WHEELER','CAR')),
   subtype          varchar(20) NOT NULL CONSTRAINT chk_vehicle_subtype CHECK (subtype IN
                        ('MOTORCYCLE','SCOOTER','MOPED','E_BIKE','E_SCOOTER','CAR')),
   segment          varchar(20) NOT NULL CONSTRAINT chk_vehicle_segment CHECK (segment IN
                        ('COMMUTER','PREMIUM','SUPERBIKE','VINTAGE','EV')),
   make             varchar(80) NOT NULL,
   model            varchar(80) NOT NULL,
   year             smallint    NOT NULL,
   engine_cc        int,
   reg_no           varchar(20),
   odometer_km      int,
   location_pincode varchar(10),
   lat              numeric(9, 6),
   lng              numeric(9, 6),
   owner_user_id UUID NOT NULL REFERENCES app_user(id),
   status           varchar(30) NOT NULL DEFAULT 'DRAFT' CONSTRAINT chk_vehicle_status CHECK (STATUS IN
                        ('DRAFT','REQUESTED','ASSIGNED','INSPECTED','CERTIFIED',
                         'REJECTED','EXPIRED','LISTED','RESERVED','SOLD')),
   created_at timestamptz NOT NULL DEFAULT now(),
   updated_at timestamptz NOT NULL DEFAULT now(),
   version          int         NOT NULL DEFAULT 0
);
CREATE INDEX ix_vehicle_owner ON vehicle (owner_user_id);
CREATE INDEX ix_vehicle_status ON vehicle (status);
CREATE INDEX ix_vehicle_pincode ON vehicle (location_pincode) WHERE STATUS IN ('LISTED','RESERVED');
CREATE UNIQUE INDEX ux_vehicle_reg_no ON vehicle (reg_no) WHERE reg_no IS NOT NULL;

COMMENT ON TABLE vehicle IS
'Common fields for all vehicles. Type-specific data lives in subtype tables (joined inheritance).';

-- ---------- two-wheeler details (subtype table) ----------
CREATE TABLE two_wheeler_details
(
   vehicle_id UUID PRIMARY KEY REFERENCES vehicle(id) ON DELETE CASCADE,
   fuel         varchar(20) NOT NULL CONSTRAINT chk_fuel CHECK (fuel IN ('PETROL','ELECTRIC','HYBRID')),
   transmission varchar(20) NOT NULL DEFAULT 'MANUAL' CONSTRAINT chk_transmission CHECK (transmission IN
                       ('MANUAL','AUTOMATIC','CVT','DCT')),
   battery_kwh  numeric(6, 2),
   created_at timestamptz NOT NULL DEFAULT now(),
   updated_at timestamptz NOT NULL DEFAULT now(),
   version      int         NOT NULL DEFAULT 0
);

-- Note: car_details stub intentionally omitted until Phase 2; schema is ready
-- for it (vehicle_type='CAR') without change.

-- ---------- seed segment policy ----------
INSERT INTO segment_policy (segment, min_engine_cc, max_engine_cc)
VALUES ('COMMUTER',  0,   199 ),
       ('PREMIUM',   200, 749 ),
       ('SUPERBIKE', 750, NULL),
       ('VINTAGE',   0,   NULL),
       ('EV',        0,   NULL);

-- ---------- seed commission config (placeholder rates; tune in DB, not code) ----------
INSERT INTO commission_config (role, rate_pct)
VALUES ('PLATFORM_GENERIC',  5.00),
       ('PLATFORM_DEALER',   2.00),
       ('INSPECTOR_SUCCESS', 1.00);