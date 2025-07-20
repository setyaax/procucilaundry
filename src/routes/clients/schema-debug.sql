-- Debug version: Run each section separately to identify where the error occurs

-- Section 1: Check if clients table exists and has client_id column
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'clients';

-- Section 2: Create clients table only
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

-- Section 3: Verify clients table was created
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'clients';

-- Section 4: Create client_pricing table
CREATE TABLE IF NOT EXISTS client_pricing (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  pricing_model VARCHAR(20) NOT NULL CHECK (pricing_model IN ('per_kg', 'per_piece', 'flat_rate')),
  price DECIMAL(10, 2) NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Section 5: Create client_staff table (without user_id foreign key for now)
CREATE TABLE IF NOT EXISTS client_staff (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
  user_id UUID NOT NULL,
  role VARCHAR(50) CHECK (role IN ('contact', 'billing', 'operations')),
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(client_id, user_id)
);

-- Section 6: Create invoices table
CREATE TABLE IF NOT EXISTS invoices (
  invoice_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_number VARCHAR(50) UNIQUE NOT NULL,
  client_id UUID NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
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
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Section 7: Create client_rentals table
CREATE TABLE IF NOT EXISTS client_rentals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
  item_type VARCHAR(50) NOT NULL CHECK (item_type IN ('towel', 'bedding', 'bathrobe', 'other')),
  item_name VARCHAR(255) NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 0,
  unit_price DECIMAL(10, 2) DEFAULT 0,
  rental_start_date DATE NOT NULL DEFAULT CURRENT_DATE,
  rental_end_date DATE,
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'returned', 'damaged', 'lost')),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Section 8: Create invoice_items table
CREATE TABLE IF NOT EXISTS invoice_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id UUID NOT NULL REFERENCES invoices(invoice_id) ON DELETE CASCADE,
  description VARCHAR(255),
  quantity INTEGER DEFAULT 1,
  unit_price DECIMAL(10, 2),
  amount DECIMAL(10, 2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Section 9: Check all tables
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('clients', 'client_pricing', 'client_staff', 'invoices', 'invoice_items', 'client_rentals'); 