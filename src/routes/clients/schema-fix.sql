-- Fix for client_id foreign key error
-- This script checks existing tables and fixes structure issues

-- Step 1: Check what tables exist and their structure
SELECT 
    t.table_name,
    array_agg(c.column_name::text ORDER BY c.ordinal_position) as columns
FROM information_schema.tables t
JOIN information_schema.columns c ON t.table_name = c.table_name
WHERE t.table_schema = 'public' 
    AND t.table_name IN ('clients', 'client_pricing', 'client_staff', 'invoices', 'invoice_items', 'client_rentals')
GROUP BY t.table_name;

-- Step 2: Check if clients table exists and what columns it has
SELECT 
    column_name, 
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'clients' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- Step 3: If you need to drop all tables and start fresh (CAREFUL - this will delete all data!)
-- Uncomment the following lines if you want to completely reset:
/*
DROP TABLE IF EXISTS client_rentals CASCADE;
DROP TABLE IF EXISTS invoice_items CASCADE;
DROP TABLE IF EXISTS invoices CASCADE;
DROP TABLE IF EXISTS client_staff CASCADE;
DROP TABLE IF EXISTS client_pricing CASCADE;
DROP TABLE IF EXISTS clients CASCADE;
*/

-- Step 4: Alternative - Rename existing clients table if it has wrong structure
-- Uncomment if needed:
/*
ALTER TABLE IF EXISTS clients RENAME TO clients_backup;
*/

-- Step 5: Create clients table with correct structure
-- This will only create if it doesn't exist
CREATE TABLE IF NOT EXISTS clients (
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

-- Step 6: If the clients table exists but with 'id' instead of 'client_id', fix it
-- Check if this is the case first with the query in Step 2
-- Then uncomment and run if needed:
/*
ALTER TABLE clients RENAME COLUMN id TO client_id;
*/

-- Step 7: Create other tables one by one
-- Run each CREATE TABLE separately to identify which one fails

-- 7a. Client pricing
CREATE TABLE IF NOT EXISTS client_pricing (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL,
  name VARCHAR(255) NOT NULL,
  pricing_model VARCHAR(20) NOT NULL CHECK (pricing_model IN ('per_kg', 'per_piece', 'flat_rate')),
  price DECIMAL(10, 2) NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_client_pricing_client FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE
);

-- 7b. Client staff (without users FK for now)
CREATE TABLE IF NOT EXISTS client_staff (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL,
  user_id UUID NOT NULL,
  role VARCHAR(50) CHECK (role IN ('contact', 'billing', 'operations')),
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(client_id, user_id),
  CONSTRAINT fk_client_staff_client FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE
);

-- 7c. Invoices
CREATE TABLE IF NOT EXISTS invoices (
  invoice_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_number VARCHAR(50) UNIQUE NOT NULL,
  client_id UUID NOT NULL,
  invoice_date DATE NOT NULL,
  due_date DATE NOT NULL,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  total_items INTEGER DEFAULT 0,
  total_weight DECIMAL(10, 2) DEFAULT 0,
  subtotal DECIMAL(10, 2) NOT NULL,
  tax_amount DECIMAL(10, 2) DEFAULT 0,
  total_amount DECIMAL(10, 2) NOT NULL,
  status VARCHAR(20) CHECK (status IN ('draft', 'sent', 'paid', 'overdue', 'cancelled')),
  paid_at TIMESTAMP,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_invoices_client FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE
);

-- 7d. Client rentals
CREATE TABLE IF NOT EXISTS client_rentals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL,
  item_type VARCHAR(50) NOT NULL CHECK (item_type IN ('towel', 'bedding', 'bathrobe', 'other')),
  item_name VARCHAR(255) NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 0,
  unit_price DECIMAL(10, 2) DEFAULT 0,
  rental_start_date DATE NOT NULL DEFAULT CURRENT_DATE,
  rental_end_date DATE,
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'returned', 'damaged', 'lost')),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_client_rentals_client FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE
);

-- 7e. Invoice items
CREATE TABLE IF NOT EXISTS invoice_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id UUID NOT NULL,
  description VARCHAR(255),
  quantity INTEGER DEFAULT 1,
  unit_price DECIMAL(10, 2),
  amount DECIMAL(10, 2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_invoice_items_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON DELETE CASCADE
);

-- Step 8: Add users foreign key if users table exists
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users' AND table_schema = 'public') THEN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.table_constraints 
      WHERE constraint_name = 'fk_client_staff_user' 
      AND table_name = 'client_staff'
    ) THEN
      ALTER TABLE client_staff ADD CONSTRAINT fk_client_staff_user 
      FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;
    END IF;
  END IF;
END $$;

-- Step 9: Verify all tables were created successfully
SELECT 
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public' 
    AND table_name IN ('clients', 'client_pricing', 'client_staff', 'invoices', 'invoice_items', 'client_rentals')
ORDER BY table_name; 