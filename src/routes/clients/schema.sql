-- Prerequisites: The 'users' table must exist before running this script
-- as the client_staff table references users(user_id)

-- Drop existing tables if needed (uncomment if you want to recreate)
-- DROP TABLE IF EXISTS client_rentals CASCADE;
-- DROP TABLE IF EXISTS invoice_items CASCADE;
-- DROP TABLE IF EXISTS invoices CASCADE;
-- DROP TABLE IF EXISTS client_staff CASCADE;
-- DROP TABLE IF EXISTS client_pricing CASCADE;
-- DROP TABLE IF EXISTS clients CASCADE;

-- Step 1: Create the main clients table first (no dependencies)
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

-- Step 2: Create tables that depend on clients
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
  FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE
);

-- Note: This table requires 'users' table to exist
CREATE TABLE IF NOT EXISTS client_staff (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL,
  user_id UUID NOT NULL,
  role VARCHAR(50) CHECK (role IN ('contact', 'billing', 'operations')),
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(client_id, user_id),
  FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE
  -- Note: Foreign key to users table is added separately if users table exists
);

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
  FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE
);

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
  FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE
);

-- Step 3: Create tables that depend on other tables
CREATE TABLE IF NOT EXISTS invoice_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id UUID NOT NULL,
  description VARCHAR(255),
  quantity INTEGER DEFAULT 1,
  unit_price DECIMAL(10, 2),
  amount DECIMAL(10, 2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON DELETE CASCADE
);

-- Step 4: Add foreign key to users table if it exists
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users') THEN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.table_constraints 
      WHERE constraint_name = 'client_staff_user_id_fkey' 
      AND table_name = 'client_staff'
    ) THEN
      ALTER TABLE client_staff ADD CONSTRAINT client_staff_user_id_fkey 
      FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;
    END IF;
  END IF;
END $$;

-- Step 5: Create indexes
CREATE INDEX IF NOT EXISTS idx_clients_type ON clients(type);
CREATE INDEX IF NOT EXISTS idx_clients_pricing_type ON clients(pricing_type);
CREATE INDEX IF NOT EXISTS idx_client_pricing_client ON client_pricing(client_id);
CREATE INDEX IF NOT EXISTS idx_client_pricing_active ON client_pricing(is_active);
CREATE INDEX IF NOT EXISTS idx_client_staff_client ON client_staff(client_id);
CREATE INDEX IF NOT EXISTS idx_client_staff_user ON client_staff(user_id);
CREATE INDEX IF NOT EXISTS idx_invoices_client ON invoices(client_id);
CREATE INDEX IF NOT EXISTS idx_invoices_status ON invoices(status);
CREATE INDEX IF NOT EXISTS idx_invoices_date ON invoices(invoice_date);
CREATE INDEX IF NOT EXISTS idx_invoice_items_invoice ON invoice_items(invoice_id);
CREATE INDEX IF NOT EXISTS idx_client_rentals_client ON client_rentals(client_id);
CREATE INDEX IF NOT EXISTS idx_client_rentals_status ON client_rentals(status);

-- Step 6: Insert sample data (only if not exists)
INSERT INTO clients (name, type, address, phone, email, contact_person, pricing_type, price_per_kg) 
SELECT 'Grand Hotel Jakarta', 'hotel', 'Jl. Sudirman No. 1, Jakarta', '+62 21 1234567', 'laundry@grandhotel.com', 'John Doe', 'per_kg', 15000
WHERE NOT EXISTS (SELECT 1 FROM clients WHERE name = 'Grand Hotel Jakarta');

INSERT INTO clients (name, type, address, phone, email, contact_person, pricing_type, price_per_kg) 
SELECT 'Beach Resort Bali', 'hotel', 'Jl. Pantai Kuta, Bali', '+62 361 7654321', 'housekeeping@beachresort.com', 'Jane Smith', 'flat_rate', 0
WHERE NOT EXISTS (SELECT 1 FROM clients WHERE name = 'Beach Resort Bali');

INSERT INTO clients (name, type, address, phone, email, contact_person, pricing_type, price_per_kg) 
SELECT 'City Inn Surabaya', 'hotel', 'Jl. Tunjungan No. 45, Surabaya', '+62 31 9876543', 'operations@cityinn.com', 'Bob Johnson', 'per_piece', 0
WHERE NOT EXISTS (SELECT 1 FROM clients WHERE name = 'City Inn Surabaya');

UPDATE clients SET flat_rate = 5000000 WHERE name = 'Beach Resort Bali' AND flat_rate = 0;
UPDATE clients SET price_per_piece = 5000 WHERE name = 'City Inn Surabaya' AND price_per_piece = 0; 