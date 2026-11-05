-- V3__fix_enum_types_to_varchar.sql
-- Convert PostgreSQL ENUM types to VARCHAR with CHECK constraints
-- This is more compatible with Hibernate's @Enumerated(EnumType.STRING)

-- 1. Drop existing tables that use ENUM types
DROP TABLE IF EXISTS listing_media;
DROP TABLE IF EXISTS vehicle_listings;
DROP TABLE IF EXISTS users;

-- 2. Drop the ENUM types
DROP TYPE IF EXISTS user_role;
DROP TYPE IF EXISTS vehicle_condition;
DROP TYPE IF EXISTS listing_status;
DROP TYPE IF EXISTS inspection_status;
DROP TYPE IF EXISTS media_type;

-- 3. Recreate tables using VARCHAR with CHECK constraints

-- Users Table
CREATE TABLE users (
                      id UUID PRIMARY KEY,
                      full_name VARCHAR(255) NOT NULL,
                      email VARCHAR(255) NOT NULL UNIQUE,
                      role VARCHAR(50) NOT NULL DEFAULT 'BUYER' CHECK (role IN ('BUYER', 'SELLER', 'DEALER', 'ADMIN')),
                      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                      updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Vehicle Listings Table
CREATE TABLE vehicle_listings (
                                 id UUID PRIMARY KEY,
                                 seller_id UUID NOT NULL REFERENCES users(id),
                                 title VARCHAR(255) NOT NULL,
                                 description TEXT,
                                 price NUMERIC(12, 2) NOT NULL,
                                 make VARCHAR(100) NOT NULL,
                                 model VARCHAR(100) NOT NULL,
                                 year_of_manufacture INTEGER NOT NULL,
                                 mileage_km INTEGER NOT NULL,
                                 engine_cc INTEGER NOT NULL,
                                 condition VARCHAR(50) NOT NULL CHECK (condition IN ('NEW', 'LIKE_NEW', 'GOOD', 'FAIR')),
    listing_status VARCHAR(50) NOT NULL DEFAULT 'DRAFT' CHECK (listing_status IN ('DRAFT', 'ACTIVE', 'RESERVED', 'SOLD')),
    inspection_status VARCHAR(50) NOT NULL DEFAULT 'PENDING' CHECK (inspection_status IN ('PENDING', 'CERTIFIED', 'REJECTED')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Listing Media Table
CREATE TABLE listing_media (
                              id UUID PRIMARY KEY,
                              listing_id UUID NOT NULL REFERENCES vehicle_listings(id) ON DELETE CASCADE,
                              url VARCHAR(1024) NOT NULL,
                              media_type VARCHAR(50) NOT NULL DEFAULT 'IMAGE' CHECK (media_type IN ('IMAGE', 'VIDEO', 'DOCUMENT')),
                              is_primary BOOLEAN NOT NULL DEFAULT FALSE,
                              display_order INTEGER NOT NULL DEFAULT 0,
                              created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                              updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_listings_seller ON vehicle_listings(seller_id);
CREATE INDEX idx_listings_status ON vehicle_listings(listing_status);
CREATE INDEX idx_media_listing ON listing_media(listing_id);