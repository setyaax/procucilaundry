<script lang="ts">
  import { supabase } from '$lib/supabase';
  
  const updateRolesSQL = `
-- First, add hotel_name column if it doesn't exist
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS hotel_name VARCHAR(255);

-- Update the role constraint to include all new roles
ALTER TABLE users 
DROP CONSTRAINT IF EXISTS users_role_check;

ALTER TABLE users 
ADD CONSTRAINT users_role_check 
CHECK (role IN (
  'main_admin',
  'laundry_manager',
  'laundry_picker',
  'laundry_washer', 
  'laundry_cashier',
  'hotel_owner',
  'hotel_logistic',
  'hotel_accountant',
  'hotel_staff',
  'laundry_staff' -- Keep for backward compatibility
));

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_hotel_name ON users(hotel_name);
  `;
  
  async function checkDatabase() {
    if (!supabase) {
      alert('Supabase not connected');
      return;
    }
    
    try {
      const { data, error } = await supabase
        .from('users')
        .select('role')
        .limit(10);
      
      if (error) {
        alert('Error checking database: ' + error.message);
      } else {
        alert('Database connection successful! Found ' + (data?.length || 0) + ' users');
      }
    } catch (err) {
      alert('Error: ' + err);
    }
  }
</script>

<div class="p-8 max-w-4xl mx-auto">
  <h1 class="text-2xl font-bold mb-6">Database Setup - Update Roles</h1>
  
  <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-6">
    <p class="text-yellow-800">
      <strong>Important:</strong> Run this SQL in your Supabase SQL editor to update the database schema for the new role system.
    </p>
  </div>
  
  <div class="bg-white rounded-lg shadow p-6 mb-6">
    <h2 class="text-lg font-semibold mb-4">SQL to Update Database Schema</h2>
    <pre class="bg-gray-100 p-4 rounded overflow-x-auto text-sm">{updateRolesSQL}</pre>
    
    <div class="mt-4">
      <p class="text-sm text-gray-600 mb-2">Steps to apply:</p>
      <ol class="list-decimal list-inside text-sm text-gray-600 space-y-1">
        <li>Go to your Supabase dashboard</li>
        <li>Navigate to SQL Editor</li>
        <li>Copy and paste the SQL above</li>
        <li>Click "Run" to execute</li>
      </ol>
    </div>
  </div>
  
  <div class="bg-white rounded-lg shadow p-6 mb-6">
    <h2 class="text-lg font-semibold mb-4">New Role Structure</h2>
    
    <div class="space-y-4">
      <div>
        <h3 class="font-medium text-gray-900 mb-2">Administrator</h3>
        <ul class="list-disc list-inside text-sm text-gray-600">
          <li><code class="bg-gray-100 px-1">main_admin</code> - Full system access</li>
        </ul>
      </div>
      
      <div>
        <h3 class="font-medium text-gray-900 mb-2">Laundry Staff</h3>
        <ul class="list-disc list-inside text-sm text-gray-600">
          <li><code class="bg-gray-100 px-1">laundry_manager</code> - Manages laundry operations</li>
          <li><code class="bg-gray-100 px-1">laundry_picker</code> - Picking & Delivery Team</li>
          <li><code class="bg-gray-100 px-1">laundry_washer</code> - Washing Team</li>
          <li><code class="bg-gray-100 px-1">laundry_cashier</code> - Cashier</li>
        </ul>
      </div>
      
      <div>
        <h3 class="font-medium text-gray-900 mb-2">Hotel Staff</h3>
        <ul class="list-disc list-inside text-sm text-gray-600">
          <li><code class="bg-gray-100 px-1">hotel_owner</code> - Hotel Owner (views reports)</li>
          <li><code class="bg-gray-100 px-1">hotel_logistic</code> - Logistic Staff</li>
          <li><code class="bg-gray-100 px-1">hotel_accountant</code> - Accountant</li>
          <li><code class="bg-gray-100 px-1">hotel_staff</code> - General Staff (creates orders)</li>
        </ul>
      </div>
    </div>
  </div>
  
  <div class="bg-white rounded-lg shadow p-6">
    <h2 class="text-lg font-semibold mb-4">Test Database Connection</h2>
    <button
      on:click={checkDatabase}
      class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
    >
      Check Database Connection
    </button>
  </div>
  
  <div class="mt-6 space-y-2">
    <a href="/users" class="text-blue-600 hover:underline block">→ Go to User Management</a>
    <a href="/dashboard" class="text-blue-600 hover:underline block">← Back to Dashboard</a>
  </div>
</div> 