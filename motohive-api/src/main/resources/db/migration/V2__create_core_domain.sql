-- V2__create_core_domain.sql

-- 1. Create ENUM types
CREATE
   TYPE user_role AS ENUM ('BUYER', 'SELLER', 'DEALER', 'ADMIN');
CREATE
   TYPE vehicle_condition AS ENUM ('NEW', 'LIKE_NEW', 'GOOD', 'FAIR');
CREATE
   TYPE listing_status AS ENUM ('DRAFT', 'ACTIVE', 'RESERVED', 'SOLD');
CREATE
   TYPE inspection_status AS ENUM ('PENDING', 'CERTIFIED', 'REJECTED');
CREATE
   TYPE media_type AS ENUM ('IMAGE', 'VIDEO', 'DOCUMENT');

-- 2. Users Table
CREATE TABLE users
(
   id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
   full_name  VARCHAR(255) NOT NULL,
   email      VARCHAR(255) NOT NULL UNIQUE,
   role       user_role    NOT NULL    DEFAULT 'BUYER',
   created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
   updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Vehicle Listings Table
CREATE TABLE vehicle_listings
(
   id                  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
   seller_id           BIGINT            NOT NULL REFERENCES users (id),
   title               VARCHAR(255)      NOT NULL,
   description         TEXT,
   price               NUMERIC(12, 2)    NOT NULL,
   make                VARCHAR(100)      NOT NULL,
   model               VARCHAR(100)      NOT NULL,
   year_of_manufacture INTEGER           NOT NULL,
   mileage_km          INTEGER           NOT NULL,
   engine_cc           INTEGER           NOT NULL,
   condition           vehicle_condition NOT NULL,
   listing_status      listing_status    NOT NULL DEFAULT 'DRAFT',
   inspection_status   inspection_status NOT NULL DEFAULT 'PENDING',
   created_at          TIMESTAMP WITH TIME ZONE   DEFAULT CURRENT_TIMESTAMP,
   updated_at          TIMESTAMP WITH TIME ZONE   DEFAULT CURRENT_TIMESTAMP
);

-- 4. Listing Media Table (Relational approach for Images, Videos, PDFs)
CREATE TABLE listing_media
(
   id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
   listing_id    BIGINT        NOT NULL REFERENCES vehicle_listings (id) ON DELETE CASCADE,
   url           VARCHAR(1024) NOT NULL,
   media_type    media_type    NOT NULL   DEFAULT 'IMAGE',
   is_primary    BOOLEAN       NOT NULL   DEFAULT FALSE,
   display_order INTEGER       NOT NULL   DEFAULT 0,
   created_at    TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
   updated_at    TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_listings_seller ON vehicle_listings (seller_id);
CREATE INDEX idx_listings_status ON vehicle_listings (listing_status);
CREATE INDEX idx_media_listing ON listing_media (listing_id);