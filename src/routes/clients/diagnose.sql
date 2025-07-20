-- Diagnostic script to identify the client_id foreign key issue
-- Run this step by step in your database

-- Step 1: Check what tables currently exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_name IN ('clients', 'client_pricing', 'client_staff', 'invoices', 'invoice_items', 'client_rentals', 'users')
ORDER BY table_name;

-- Step 2: Check the structure of the clients table (if it exists)
SELECT 
    column_name, 
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'clients' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- Step 3: Check if there are any foreign key constraints already
SELECT 
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu 
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_name IN ('client_pricing', 'client_staff', 'invoices', 'invoice_items', 'client_rentals');

-- Step 4: If the issue is that clients table has 'id' instead of 'client_id'
-- Check this first before running any fixes
SELECT 
    column_name
FROM information_schema.columns 
WHERE table_name = 'clients' 
    AND table_schema = 'public'
    AND column_name IN ('id', 'client_id');

-- SOLUTION OPTIONS:
-- Based on the results above, choose one of these solutions:

-- OPTION A: If clients table doesn't exist, create it first
/*
CREATE TABLE clients (
  client_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  type VARCHAR(50) NOT NULL CHECK (type IN ('hotel', 'restaurant', 'spa', 'hospital', 'other')),
  address TEXT,
  phone VARCHAR(50),
  email VARCHAR(255),
  contact_person VARCHAR(255),
  pricing_type VARCHAR(20) NOT NULL CHECK (pricing_type IN ('per_kg', 'per_piece', 'flat_rate')),
  price_per_kg DECIMAL(10, 2) DEFAULT 0,
  price_per_piece DECIMAL(10, 2) DEFAULT 0,
  flat_rate DECIMAL(10, 2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
*/

-- OPTION B: If clients table exists but has 'id' instead of 'client_id'
/*
ALTER TABLE clients RENAME COLUMN id TO client_id;
*/

-- OPTION C: If you want to start completely fresh (WARNING: deletes all data)
/*
DROP TABLE IF EXISTS client_rentals CASCADE;
DROP TABLE IF EXISTS invoice_items CASCADE;
DROP TABLE IF EXISTS invoices CASCADE;
DROP TABLE IF EXISTS client_staff CASCADE;
DROP TABLE IF EXISTS client_pricing CASCADE;
DROP TABLE IF EXISTS clients CASCADE;
*/

-- After choosing and running one of the options above, run the main schema.sql again 