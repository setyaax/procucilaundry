<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabase';
  import { page } from '$app/stores';
  
  const currentUser = $page.data.user;
  
  // Tab management
  let activeTab = 'clients';
  
  // Data
  let clients: any[] = [];
  let selectedClient: any = null;
  let clientStaff: any[] = [];
  let clientPrices: any[] = [];
  let invoices: any[] = [];
  let users: any[] = [];
  let loading = true;
  
  // Rental data
  let clientRentals: any[] = [];
  let showAddRental = false;
  let editingRental: any = null;
  let newRental = {
    item_type: 'towel',
    item_name: '',
    quantity: 0,
    unit_price: 0,
    notes: ''
  };
  
  // Forms
  let showAddClient = false;
  let showAddStaff = false;
  let editingClient: any = null;
  let showEditClient = false;
  
  // Loading states
  let loadingClients = false;
  let loadingCreateClient = false;
  let loadingUpdateClient = false;
  let loadingDeleteClient = false;
  let loadingRentals = false;
  let loadingCreateRental = false;
  let newClient = {
    name: '',
    type: 'hotel', // hotel, restaurant, spa, etc.
    address: '',
    phone: '',
    email: '',
    contact_person: '',
    pricing_type: 'per_kg', // per_kg, per_piece, flat_rate
    price_per_kg: 0,
    price_per_piece: 0,
    flat_rate: 0
  };
  
  let newStaff = {
    client_id: '',
    user_id: '',
    role: 'contact' // contact, billing, operations
  };
  
  // Pricing forms
  let showAddPrice = false;
  let editingPrice: any = null;
  let newPrice = {
    name: '',
    pricing_model: 'per_kg', // per_kg, per_piece, flat_rate
    price: 0,
    description: ''
  };
  
  // Date filters for invoicing
  let invoiceFilter = {
    period: 'daily', // daily, monthly
    dateFrom: new Date().toISOString().split('T')[0],
    dateTo: new Date().toISOString().split('T')[0],
    month: new Date().toISOString().slice(0, 7),
    clientId: 'all' // 'all' or specific client ID
  };
  
  // Mock data for now (will be replaced with real data)
  const mockClients = [
    {
      id: '1',
      name: 'Grand Hotel Jakarta',
      type: 'hotel',
      address: 'Jl. Sudirman No. 1, Jakarta',
      phone: '+62 21 1234567',
      email: 'laundry@grandhotel.com',
      contact_person: 'John Doe',
      pricing_type: 'per_kg',
      price_per_kg: 15000,
      created_at: new Date(),
      total_orders: 156,
      pending_amount: 4500000
    },
    {
      id: '2',
      name: 'Beach Resort Bali',
      type: 'hotel',
      address: 'Jl. Pantai Kuta, Bali',
      phone: '+62 361 7654321',
      email: 'housekeeping@beachresort.com',
      contact_person: 'Jane Smith',
      pricing_type: 'flat_rate',
      flat_rate: 5000000,
      created_at: new Date(),
      total_orders: 89,
      pending_amount: 2800000
    },
    {
      id: '3',
      name: 'City Inn Surabaya',
      type: 'hotel',
      address: 'Jl. Tunjungan No. 45, Surabaya',
      phone: '+62 31 9876543',
      email: 'operations@cityinn.com',
      contact_person: 'Bob Johnson',
      pricing_type: 'per_piece',
      price_per_piece: 5000,
      created_at: new Date(),
      total_orders: 234,
      pending_amount: 1200000
    }
  ];
  
  const mockInvoices = [
    {
      id: 'INV001',
      client_id: '1',
      client_name: 'Grand Hotel Jakarta',
      date: new Date(),
      items_count: 245,
      weight_kg: 120,
      amount: 1800000,
      status: 'pending'
    },
    {
      id: 'INV002',
      client_id: '2',
      client_name: 'Beach Resort Bali',
      date: new Date(),
      items_count: 180,
      weight_kg: 95,
      amount: 5000000,
      status: 'paid'
    },
    {
      id: 'INV003',
      client_id: '1',
      client_name: 'Grand Hotel Jakarta',
      date: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000), // Yesterday
      items_count: 312,
      weight_kg: 150,
      amount: 2250000,
      status: 'paid'
    },
    {
      id: 'INV004',
      client_id: '3',
      client_name: 'City Inn Surabaya',
      date: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // 2 days ago
      items_count: 125,
      weight_kg: 65,
      amount: 625000,
      status: 'paid'
    },
    {
      id: 'INV005',
      client_id: '2',
      client_name: 'Beach Resort Bali',
      date: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // 1 week ago
      items_count: 200,
      weight_kg: 105,
      amount: 5000000,
      status: 'pending'
    },
    {
      id: 'INV006',
      client_id: '1',
      client_name: 'Grand Hotel Jakarta',
      date: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), // 1 month ago
      items_count: 280,
      weight_kg: 140,
      amount: 2100000,
      status: 'paid'
    }
  ];
  
  async function loadClients() {
    loadingClients = true;
    if (!supabase) {
      console.error('Supabase not initialized');
      clients = [];
      loadingClients = false;
      return;
    }
    
    try {
      const { data, error } = await supabase
        .from('clients')
        .select('*')
        .order('created_at', { ascending: false });
      
      if (error) {
        console.error('Error loading clients:', error);
        clients = [];
      } else {
        clients = data || [];
      }
    } catch (error) {
      console.error('Error loading clients:', error);
      clients = [];
    }
    loadingClients = false;
  }
  
  async function loadClientStaff(clientId: string) {
    if (!supabase) return;
    
    try {
      // Load staff assigned to this client from client_staff table
      const { data: staff, error } = await supabase
        .from('client_staff')
        .select(`
          *,
          users!inner(user_id, email, role)
        `)
        .eq('client_id', clientId);
      
      if (error) {
        console.error('Error loading client staff:', error);
        clientStaff = [];
      } else {
        clientStaff = staff || [];
      }
    } catch (error) {
      console.error('Error loading client staff:', error);
      clientStaff = [];
    }
  }
  
  async function loadClientPrices(clientId: string) {
    if (!supabase) {
      console.error('Supabase not initialized');
      clientPrices = [];
      return;
    }
    
    try {
      const { data, error } = await supabase
        .from('client_pricing')
        .select('*')
        .eq('client_id', clientId)
        .eq('is_active', true)
        .order('created_at', { ascending: false });
      
      if (error) {
        console.error('Error loading client prices:', error);
        clientPrices = [];
      } else {
        clientPrices = data || [];
      }
    } catch (error) {
      console.error('Error loading client prices:', error);
      clientPrices = [];
    }
  }
  
  async function loadInvoices() {
    if (!supabase) {
      console.error('Supabase not initialized');
      invoices = [];
      return;
    }
    
    try {
      let query = supabase
        .from('invoices')
        .select(`
          *,
          clients!inner(name)
        `)
        .order('invoice_date', { ascending: false });
      
      // Filter by client
      if (invoiceFilter.clientId !== 'all') {
        query = query.eq('client_id', invoiceFilter.clientId);
      }
      
      // Filter by date range
      if (invoiceFilter.dateFrom) {
        query = query.gte('invoice_date', invoiceFilter.dateFrom);
      }
      if (invoiceFilter.dateTo) {
        query = query.lte('invoice_date', invoiceFilter.dateTo);
      }
      
      const { data, error } = await query;
      
      if (error) {
        console.error('Error loading invoices:', error);
        invoices = [];
      } else {
        invoices = data || [];
      }
    } catch (error) {
      console.error('Error loading invoices:', error);
      invoices = [];
    }
  }
  
  async function createClient() {
    if (!newClient.name || !newClient.type || !newClient.pricing_type) {
      alert('Please fill in all required fields');
      return;
    }
    
    if (!supabase) {
      alert('Error: Unable to save client');
      return;
    }
    
    loadingCreateClient = true;
    try {
      const { data, error } = await supabase
        .from('clients')
        .insert([{
          name: newClient.name,
          type: newClient.type,
          address: newClient.address,
          phone: newClient.phone,
          email: newClient.email,
          contact_person: newClient.contact_person,
          pricing_type: newClient.pricing_type,
          price_per_kg: newClient.price_per_kg,
          price_per_piece: newClient.price_per_piece,
          flat_rate: newClient.flat_rate
        }])
        .select();
      
      if (error) {
        console.error('Error creating client:', error);
        alert('Error creating client');
      } else {
        await loadClients();
        showAddClient = false;
        newClient = {
          name: '',
          type: 'hotel',
          address: '',
          phone: '',
          email: '',
          contact_person: '',
          pricing_type: 'per_kg',
          price_per_kg: 0,
          price_per_piece: 0,
          flat_rate: 0
        };
        alert('Client created successfully');
      }
    } catch (error) {
      console.error('Error creating client:', error);
      alert('Error creating client');
    }
    loadingCreateClient = false;
  }
  
  function editClient(client: any) {
    editingClient = { ...client };
    showEditClient = true;
  }
  
  async function updateClient() {
    if (!editingClient.name || !editingClient.type || !editingClient.pricing_type) {
      alert('Please fill in all required fields');
      return;
    }
    
    if (!supabase) {
      alert('Error: Unable to update client');
      return;
    }
    
    loadingUpdateClient = true;
    try {
      const { data, error } = await supabase
        .from('clients')
        .update({
          name: editingClient.name,
          type: editingClient.type,
          address: editingClient.address,
          phone: editingClient.phone,
          email: editingClient.email,
          contact_person: editingClient.contact_person,
          pricing_type: editingClient.pricing_type,
          price_per_kg: editingClient.price_per_kg,
          price_per_piece: editingClient.price_per_piece,
          flat_rate: editingClient.flat_rate
        })
        .eq('client_id', editingClient.client_id)
        .select();
      
      if (error) {
        console.error('Error updating client:', error);
        alert('Error updating client');
      } else {
        await loadClients();
        showEditClient = false;
        editingClient = null;
        alert('Client updated successfully');
      }
    } catch (error) {
      console.error('Error updating client:', error);
      alert('Error updating client');
    }
    loadingUpdateClient = false;
  }
  
  async function deleteClient(client: any) {
    if (!confirm(`Are you sure you want to delete "${client.name}"? This action cannot be undone.`)) {
      return;
    }
    
    if (!supabase) {
      alert('Error: Unable to delete client');
      return;
    }
    
    loadingDeleteClient = true;
    try {
      const { error } = await supabase
        .from('clients')
        .delete()
        .eq('client_id', client.client_id);
      
      if (error) {
        console.error('Error deleting client:', error);
        alert('Error deleting client');
      } else {
        await loadClients();
        if (selectedClient?.client_id === client.client_id) {
          selectedClient = null;
        }
        alert('Client deleted successfully');
      }
    } catch (error) {
      console.error('Error deleting client:', error);
      alert('Error deleting client');
    }
    loadingDeleteClient = false;
  }
  
  async function assignStaff() {
    if (!newStaff.user_id || !newStaff.role) {
      alert('Please fill in all required fields');
      return;
    }
    
    if (!supabase || !selectedClient) {
      alert('Error: Unable to assign staff');
      return;
    }
    
    try {
      const { data, error } = await supabase
        .from('client_staff')
        .insert([{
          client_id: selectedClient.client_id,
          user_id: newStaff.user_id,
          role: newStaff.role
        }])
        .select();
      
      if (error) {
        console.error('Error assigning staff:', error);
        alert('Error assigning staff');
      } else {
        await loadClientStaff(selectedClient.client_id);
        showAddStaff = false;
        newStaff = { client_id: '', user_id: '', role: 'contact' };
        alert('Staff assigned successfully');
      }
    } catch (error) {
      console.error('Error assigning staff:', error);
      alert('Error assigning staff');
    }
  }
  
  async function createPrice() {
    if (!newPrice.name || !newPrice.price) {
      alert('Please fill in all required fields');
      return;
    }
    
    if (!supabase || !selectedClient) {
      alert('Error: Unable to save price');
      return;
    }
    
    try {
      const { data, error } = await supabase
        .from('client_pricing')
        .insert([{
          client_id: selectedClient.client_id,
          name: newPrice.name,
          pricing_model: newPrice.pricing_model,
          price: newPrice.price,
          description: newPrice.description,
          is_active: true
        }])
        .select();
      
      if (error) {
        console.error('Error creating price:', error);
        alert('Error creating price');
      } else {
        await loadClientPrices(selectedClient.client_id);
        showAddPrice = false;
        newPrice = { name: '', pricing_model: 'per_kg', price: 0, description: '' };
        alert('Price added successfully');
      }
    } catch (error) {
      console.error('Error creating price:', error);
      alert('Error creating price');
    }
  }
  
  async function updatePrice() {
    if (!editingPrice) return;
    
    if (!supabase || !selectedClient) {
      alert('Error: Unable to update price');
      return;
    }
    
    try {
      const { data, error } = await supabase
        .from('client_pricing')
        .update({
          name: editingPrice.name,
          pricing_model: editingPrice.pricing_model,
          price: editingPrice.price,
          description: editingPrice.description
        })
        .eq('id', editingPrice.id)
        .select();
      
      if (error) {
        console.error('Error updating price:', error);
        alert('Error updating price');
      } else {
        await loadClientPrices(selectedClient.client_id);
        editingPrice = null;
        alert('Price updated successfully');
      }
    } catch (error) {
      console.error('Error updating price:', error);
      alert('Error updating price');
    }
  }
  
  async function deletePrice(priceId: string) {
    if (!confirm('Are you sure you want to delete this price?')) return;
    
    // TODO: Delete from database
    clientPrices = clientPrices.filter(p => p.id !== priceId);
    alert('Price deleted successfully');
  }
  
  function generateInvoice(client: any) {
    // TODO: Implement invoice generation
    alert(`Generating invoice for ${client.name}`);
  }
  
  function selectClient(client: any) {
    selectedClient = client;
    loadClientStaff(client.client_id);
    loadClientPrices(client.client_id);
    loadClientRentals(client.client_id);
    loadInvoices();
  }
  
  function formatCurrency(amount: number) {
    return new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR'
    }).format(amount);
  }
  
  // Rental functions
  async function loadClientRentals(clientId: string) {
    loadingRentals = true;
    if (!supabase) {
      console.error('Supabase not initialized');
      clientRentals = [];
      loadingRentals = false;
      return;
    }
    
    try {
      const { data, error } = await supabase
        .from('client_rentals')
        .select('*')
        .eq('client_id', clientId)
        .order('created_at', { ascending: false });
      
      if (error) {
        console.error('Error loading client rentals:', error);
        clientRentals = [];
      } else {
        clientRentals = data || [];
      }
    } catch (error) {
      console.error('Error loading client rentals:', error);
      clientRentals = [];
    }
    loadingRentals = false;
  }
  
  async function createRental() {
    if (!newRental.item_name || !newRental.quantity || !newRental.unit_price) {
      alert('Please fill in all required fields');
      return;
    }
    
    if (!supabase || !selectedClient) {
      alert('Error: Unable to save rental');
      return;
    }
    
    loadingCreateRental = true;
    try {
      const { data, error } = await supabase
        .from('client_rentals')
        .insert([{
          client_id: selectedClient.client_id,
          item_type: newRental.item_type,
          item_name: newRental.item_name,
          quantity: newRental.quantity,
          unit_price: newRental.unit_price,
          notes: newRental.notes,
          status: 'active'
        }])
        .select();
      
      if (error) {
        console.error('Error creating rental:', error);
        alert('Error creating rental');
      } else {
        await loadClientRentals(selectedClient.client_id);
        showAddRental = false;
        newRental = { item_type: 'towel', item_name: '', quantity: 0, unit_price: 0, notes: '' };
        alert('Rental item added successfully');
      }
    } catch (error) {
      console.error('Error creating rental:', error);
      alert('Error creating rental');
    }
    loadingCreateRental = false;
  }
  
  async function updateRental() {
    if (!editingRental) return;
    
    // TODO: Update in database
    clientRentals = clientRentals.map(r => 
      r.id === editingRental.id ? editingRental : r
    );
    
    editingRental = null;
    alert('Rental updated successfully');
  }
  
  async function deleteRental(rentalId: string) {
    if (!confirm('Are you sure you want to delete this rental item?')) return;
    
    // TODO: Delete from database
    clientRentals = clientRentals.filter(r => r.id !== rentalId);
    alert('Rental item deleted successfully');
  }
  
  async function returnRental(rentalId: string) {
    if (!confirm('Mark this item as returned?')) return;
    
    // TODO: Update status in database
    clientRentals = clientRentals.map(r => 
      r.id === rentalId ? { ...r, status: 'returned', rental_end_date: new Date() } : r
    );
    alert('Item marked as returned');
  }
  
  async function loadUsers() {
    if (!supabase) return;
    
    try {
      const { data, error } = await supabase
        .from('users')
        .select('user_id, email, role')
        .order('email');
      
      if (error) {
        console.error('Error loading users:', error);
        users = [];
      } else {
        users = data || [];
      }
    } catch (error) {
      console.error('Error loading users:', error);
      users = [];
    }
  }

  onMount(() => {
    loadClients();
    loadInvoices();
    loadUsers();
  });
</script>

<div class="p-6 max-w-7xl mx-auto">
  <div class="mb-8">
    <h1 class="text-3xl font-bold text-gray-800">Client Management</h1>
    <p class="text-gray-600 mt-2">Manage your laundry service clients and invoicing</p>
  </div>
  
  <!-- Tab Navigation -->
  <div class="border-b border-gray-200 mb-6">
    <nav class="-mb-px flex space-x-8">
      <button
        on:click={() => activeTab = 'clients'}
        class="py-2 px-1 border-b-2 font-medium text-sm {activeTab === 'clients' ? 'border-indigo-500 text-indigo-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'}"
      >
        Clients
      </button>
      <button
        on:click={() => activeTab = 'invoicing'}
        class="py-2 px-1 border-b-2 font-medium text-sm {activeTab === 'invoicing' ? 'border-indigo-500 text-indigo-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'}"
      >
        Invoicing
      </button>
    </nav>
  </div>
  
  <!-- Clients Tab -->
  {#if activeTab === 'clients'}
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Client List -->
      <div class="lg:col-span-1">
        <div class="bg-white rounded-lg shadow">
          <div class="p-4 border-b border-gray-200 flex justify-between items-center">
            <h2 class="text-lg font-semibold">Client List</h2>
            {#if currentUser.role === 'main_admin' || currentUser.role === 'laundry_manager'}
              <button
                on:click={() => showAddClient = true}
                class="px-3 py-1 bg-indigo-600 text-white text-sm rounded-md hover:bg-indigo-700"
              >
                + Add
              </button>
            {/if}
          </div>
          
          <div class="divide-y divide-gray-200 max-h-96 overflow-y-auto">
            {#if loadingClients}
              <div class="flex justify-center items-center p-8">
                <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
                <span class="ml-2 text-gray-600">Loading clients...</span>
              </div>
            {:else if clients.length === 0}
              <div class="text-center p-8 text-gray-500">
                <p>No clients found</p>
                <button
                  on:click={() => showAddClient = true}
                  class="mt-2 text-indigo-600 hover:text-indigo-500"
                >
                  Add your first client
                </button>
              </div>
            {:else}
              {#each clients as client}
                <div class="p-4 hover:bg-gray-50 transition-colors {selectedClient?.client_id === client.client_id ? 'bg-indigo-50' : ''}">
                  <div class="flex justify-between items-start">
                    <button
                      on:click={() => selectClient(client)}
                      class="flex-1 text-left"
                    >
                      <div>
                        <h3 class="font-medium text-gray-900">{client.name}</h3>
                        <p class="text-sm text-gray-500">{client.type} • {client.contact_person}</p>
                        <p class="text-sm text-gray-600 mt-1">{client.phone}</p>
                      </div>
                    </button>
                    
                    <!-- CRUD Actions -->
                    <div class="flex items-center space-x-2 ml-4">
                      <button
                        on:click={() => editClient(client)}
                        class="p-1 text-gray-400 hover:text-indigo-600 transition-colors"
                        title="Edit client"
                      >
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                        </svg>
                      </button>
                      
                      <button
                        on:click={() => deleteClient(client)}
                        class="p-1 text-gray-400 hover:text-red-600 transition-colors"
                        title="Delete client"
                        disabled={loadingDeleteClient}
                      >
                        {#if loadingDeleteClient}
                          <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-red-600"></div>
                        {:else}
                          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                          </svg>
                        {/if}
                      </button>
                    </div>
                  </div>
                </div>
              {/each}
            {/if}
          </div>
        </div>
      </div>
      
      <!-- Client Details -->
      <div class="lg:col-span-2">
        {#if selectedClient}
          <div class="space-y-6">
            <!-- Client Info -->
            <div class="bg-white rounded-lg shadow p-6">
              <h3 class="text-lg font-semibold mb-4">Client Information</h3>
              
              <div class="grid grid-cols-2 gap-4">
                <div>
                  <p class="text-sm text-gray-600">Name</p>
                  <p class="font-medium">{selectedClient.name}</p>
                </div>
                <div>
                  <p class="text-sm text-gray-600">Type</p>
                  <p class="font-medium capitalize">{selectedClient.type}</p>
                </div>
                <div>
                  <p class="text-sm text-gray-600">Contact Person</p>
                  <p class="font-medium">{selectedClient.contact_person}</p>
                </div>
                <div>
                  <p class="text-sm text-gray-600">Phone</p>
                  <p class="font-medium">{selectedClient.phone}</p>
                </div>
                <div>
                  <p class="text-sm text-gray-600">Email</p>
                  <p class="font-medium">{selectedClient.email}</p>
                </div>
                <div>
                  <p class="text-sm text-gray-600">Address</p>
                  <p class="font-medium">{selectedClient.address}</p>
                </div>
              </div>
              
              <div class="mt-6 pt-6 border-t border-gray-200">
                <div class="flex justify-between items-center mb-4">
                  <h4 class="font-medium">Pricing List</h4>
                  {#if currentUser.role === 'main_admin' || currentUser.role === 'laundry_manager'}
                    <button
                      on:click={() => showAddPrice = true}
                      class="px-3 py-1 bg-indigo-600 text-white text-sm rounded-md hover:bg-indigo-700"
                    >
                      + Add Price
                    </button>
                  {/if}
                </div>
                
                {#if clientPrices.length > 0}
                  <div class="space-y-2">
                    {#each clientPrices as price}
                      <div class="bg-gray-50 p-3 rounded-lg">
                        <div class="flex justify-between items-start">
                          <div class="flex-1">
                            <h5 class="font-medium text-gray-900">{price.name}</h5>
                            <p class="text-sm text-gray-600">{price.description}</p>
                            <div class="mt-1 flex items-center gap-4">
                              <span class="text-sm px-2 py-1 bg-indigo-100 text-indigo-700 rounded">
                                {price.pricing_model.replace('_', ' ').toUpperCase()}
                              </span>
                              <span class="font-semibold text-indigo-600">
                                {formatCurrency(price.price)}
                              </span>
                            </div>
                          </div>
                          {#if currentUser.role === 'main_admin' || currentUser.role === 'laundry_manager'}
                            <div class="flex gap-2 ml-4">
                              <button
                                on:click={() => editingPrice = {...price}}
                                class="text-sm text-indigo-600 hover:text-indigo-800"
                              >
                                Edit
                              </button>
                              <button
                                on:click={() => deletePrice(price.id)}
                                class="text-sm text-red-600 hover:text-red-800"
                              >
                                Delete
                              </button>
                            </div>
                          {/if}
                        </div>
                      </div>
                    {/each}
                  </div>
                {:else}
                  <p class="text-gray-500 text-center py-4">No pricing configured</p>
                {/if}
              </div>
            </div>
            
            <!-- Rental Items -->
            <div class="bg-white rounded-lg shadow p-6">
              <div class="flex justify-between items-center mb-4">
                <h3 class="text-lg font-semibold">Rental Items</h3>
                {#if currentUser.role === 'main_admin' || currentUser.role === 'laundry_manager'}
                  <button
                    on:click={() => showAddRental = true}
                    class="px-3 py-1 bg-indigo-600 text-white text-sm rounded-md hover:bg-indigo-700"
                  >
                    + Add Rental
                  </button>
                {/if}
              </div>
              
              {#if loadingRentals}
                <div class="flex justify-center items-center p-8">
                  <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-indigo-600"></div>
                  <span class="ml-2 text-gray-600">Loading rentals...</span>
                </div>
              {:else if clientRentals.length > 0}
                <div class="space-y-2">
                  {#each clientRentals as rental}
                    <div class="bg-gray-50 p-3 rounded-lg">
                      <div class="flex justify-between items-start">
                        <div class="flex-1">
                          <div class="flex items-center gap-2">
                            <h5 class="font-medium text-gray-900">{rental.item_name}</h5>
                            <span class="text-xs px-2 py-1 bg-indigo-100 text-indigo-700 rounded">
                              {rental.item_type.toUpperCase()}
                            </span>
                            <span class="text-xs px-2 py-1 {rental.status === 'active' ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-700'} rounded">
                              {rental.status.toUpperCase()}
                            </span>
                          </div>
                          <div class="mt-1 grid grid-cols-3 gap-4 text-sm">
                            <div>
                              <span class="text-gray-600">Quantity:</span>
                              <span class="font-semibold ml-1">{rental.quantity}</span>
                            </div>
                            <div>
                              <span class="text-gray-600">Unit Price:</span>
                              <span class="font-semibold ml-1">{formatCurrency(rental.unit_price)}</span>
                            </div>
                            <div>
                              <span class="text-gray-600">Total Value:</span>
                              <span class="font-semibold ml-1 text-indigo-600">{formatCurrency(rental.quantity * rental.unit_price)}</span>
                            </div>
                          </div>
                          {#if rental.notes}
                            <p class="text-sm text-gray-600 mt-1">{rental.notes}</p>
                          {/if}
                          <p class="text-xs text-gray-500 mt-1">
                            Started: {new Date(rental.rental_start_date).toLocaleDateString()}
                            {#if rental.rental_end_date}
                              | Ended: {new Date(rental.rental_end_date).toLocaleDateString()}
                            {/if}
                          </p>
                        </div>
                        {#if currentUser.role === 'main_admin' || currentUser.role === 'laundry_manager'}
                          <div class="flex gap-2 ml-4">
                            {#if rental.status === 'active'}
                              <button
                                on:click={() => returnRental(rental.id)}
                                class="text-sm text-green-600 hover:text-green-800"
                              >
                                Return
                              </button>
                              <button
                                on:click={() => editingRental = {...rental}}
                                class="text-sm text-indigo-600 hover:text-indigo-800"
                              >
                                Edit
                              </button>
                            {/if}
                            <button
                              on:click={() => deleteRental(rental.id)}
                              class="text-sm text-red-600 hover:text-red-800"
                            >
                              Delete
                            </button>
                          </div>
                        {/if}
                      </div>
                    </div>
                  {/each}
                </div>
                
                <!-- Summary -->
                <div class="mt-4 p-3 bg-indigo-50 rounded">
                  <div class="flex justify-between items-center">
                    <span class="text-sm font-medium text-indigo-900">Total Active Rentals:</span>
                    <span class="text-lg font-bold text-indigo-700">
                      {formatCurrency(
                        clientRentals
                          .filter(r => r.status === 'active')
                          .reduce((sum, r) => sum + (r.quantity * r.unit_price), 0)
                      )}
                    </span>
                  </div>
                </div>
              {:else}
                <p class="text-gray-500 text-center py-4">No rental items</p>
              {/if}
            </div>
            
            <!-- Client Staff -->
            <div class="bg-white rounded-lg shadow p-6">
              <div class="flex justify-between items-center mb-4">
                <h3 class="text-lg font-semibold">Assigned Staff</h3>
                {#if currentUser.role === 'main_admin' || currentUser.role === 'laundry_manager'}
                  <button
                    on:click={() => showAddStaff = true}
                    class="px-3 py-1 bg-indigo-600 text-white text-sm rounded-md hover:bg-indigo-700"
                  >
                    + Assign Staff
                  </button>
                {/if}
              </div>
              
              {#if clientStaff.length > 0}
                <div class="space-y-2">
                  {#each clientStaff as staff}
                    <div class="flex justify-between items-center p-3 bg-gray-50 rounded">
                      <div>
                        <p class="font-medium">{staff.users?.email || 'Unknown Email'}</p>
                        <p class="text-sm text-gray-600">
                          Role: {staff.role} | User Role: {staff.users?.role || 'Unknown'}
                        </p>
                      </div>
                      <button class="text-red-600 hover:text-red-700 text-sm">
                        Remove
                      </button>
                    </div>
                  {/each}
                </div>
              {:else}
                <p class="text-gray-500 text-center py-4">No staff assigned to this client</p>
              {/if}
            </div>
          </div>
        {:else}
          <div class="bg-white rounded-lg shadow p-8 text-center">
            <p class="text-gray-500">Select a client to view details</p>
          </div>
        {/if}
      </div>
    </div>
  {/if}
  
  <!-- Invoicing Tab -->
  {#if activeTab === 'invoicing'}
    <div class="space-y-6">
      <!-- Filters -->
      <div class="bg-white rounded-lg shadow p-4">
        <div class="flex flex-col md:flex-row gap-4 items-end">
          <div class="flex-1">
            <label for="invoice-client" class="block text-sm font-medium text-gray-700 mb-1">Client</label>
            <select
              id="invoice-client"
              bind:value={invoiceFilter.clientId}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="all">All Clients</option>
              {#each clients as client}
                <option value={client.id}>{client.name}</option>
              {/each}
            </select>
          </div>
          
          <div>
            <label for="invoice-period" class="block text-sm font-medium text-gray-700 mb-1">Period</label>
            <select
              id="invoice-period"
              bind:value={invoiceFilter.period}
              class="px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="daily">Daily</option>
              <option value="monthly">Monthly</option>
            </select>
          </div>
          
          {#if invoiceFilter.period === 'daily'}
            <div>
              <label for="invoice-date-from" class="block text-sm font-medium text-gray-700 mb-1">Date From</label>
              <input
                id="invoice-date-from"
                type="date"
                bind:value={invoiceFilter.dateFrom}
                class="px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>
            <div>
              <label for="invoice-date-to" class="block text-sm font-medium text-gray-700 mb-1">Date To</label>
              <input
                id="invoice-date-to"
                type="date"
                bind:value={invoiceFilter.dateTo}
                class="px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>
          {:else}
            <div>
              <label for="invoice-month" class="block text-sm font-medium text-gray-700 mb-1">Month</label>
              <input
                id="invoice-month"
                type="month"
                bind:value={invoiceFilter.month}
                class="px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>
          {/if}
          
          <div>
            <button
              on:click={loadInvoices}
              class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
            >
              Filter
            </button>
          </div>
        </div>
      </div>
      
      <!-- Invoice Summary -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div class="bg-white rounded-lg shadow p-4">
          <p class="text-sm text-gray-600">Total Invoices</p>
          <p class="text-2xl font-bold text-gray-900">{invoices.length}</p>
        </div>
        <div class="bg-white rounded-lg shadow p-4">
          <p class="text-sm text-gray-600">Total Amount</p>
          <p class="text-2xl font-bold text-green-600">
            {formatCurrency(invoices.reduce((sum, inv) => sum + inv.amount, 0))}
          </p>
        </div>
        <div class="bg-white rounded-lg shadow p-4">
          <p class="text-sm text-gray-600">Paid</p>
          <p class="text-2xl font-bold text-blue-600">
            {formatCurrency(invoices.filter(i => i.status === 'paid').reduce((sum, inv) => sum + inv.amount, 0))}
          </p>
        </div>
        <div class="bg-white rounded-lg shadow p-4">
          <p class="text-sm text-gray-600">Pending</p>
          <p class="text-2xl font-bold text-orange-600">
            {formatCurrency(invoices.filter(i => i.status === 'pending').reduce((sum, inv) => sum + inv.amount, 0))}
          </p>
        </div>
      </div>
      
      <!-- Invoice List -->
      <div class="bg-white rounded-lg shadow overflow-hidden">
        <table class="w-full">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Invoice ID</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Client</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Items</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Amount</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            {#each invoices as invoice}
              <tr>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                  {invoice.id}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {invoice.client_name}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {new Date(invoice.date).toLocaleDateString()}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {invoice.items_count} items ({invoice.weight_kg} kg)
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                  {formatCurrency(invoice.amount)}
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full {invoice.status === 'paid' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'}">
                    {invoice.status}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <button class="text-indigo-600 hover:text-indigo-900 mr-3">View</button>
                  <button class="text-indigo-600 hover:text-indigo-900">Download</button>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    </div>
  {/if}
  
  <!-- Add Client Modal -->
  {#if showAddClient}
    <div class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-2xl max-h-screen overflow-y-auto">
        <h2 class="text-xl font-bold mb-4">Add New Client</h2>
        
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Client Name</label>
            <input
              type="text"
              bind:value={newClient.name}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              placeholder="Grand Hotel"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Type</label>
            <select
              bind:value={newClient.type}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="hotel">Hotel</option>
              <option value="restaurant">Restaurant</option>
              <option value="spa">Spa</option>
              <option value="hospital">Hospital</option>
              <option value="other">Other</option>
            </select>
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Contact Person</label>
            <input
              type="text"
              bind:value={newClient.contact_person}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Phone</label>
            <input
              type="tel"
              bind:value={newClient.phone}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
            <input
              type="email"
              bind:value={newClient.email}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Pricing Type</label>
            <select
              bind:value={newClient.pricing_type}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="per_kg">Per KG</option>
              <option value="per_piece">Per Piece</option>
              <option value="flat_rate">Monthly Flat Rate</option>
            </select>
          </div>
          
          <div class="col-span-2">
            <label class="block text-sm font-medium text-gray-700 mb-1">Address</label>
            <textarea
              bind:value={newClient.address}
              rows="2"
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          
          {#if newClient.pricing_type === 'per_kg'}
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Price per KG (IDR)</label>
              <input
                type="number"
                bind:value={newClient.price_per_kg}
                class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>
          {:else if newClient.pricing_type === 'per_piece'}
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Price per Piece (IDR)</label>
              <input
                type="number"
                bind:value={newClient.price_per_piece}
                class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>
          {:else if newClient.pricing_type === 'flat_rate'}
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Monthly Flat Rate (IDR)</label>
              <input
                type="number"
                bind:value={newClient.flat_rate}
                class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>
          {/if}
        </div>
        
        <div class="mt-6 flex justify-end gap-3">
          <button
            on:click={() => showAddClient = false}
            class="px-4 py-2 border border-gray-300 rounded-md hover:bg-gray-50"
          >
            Cancel
          </button>
          <button
            on:click={createClient}
            disabled={loadingCreateClient}
            class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center"
          >
            {#if loadingCreateClient}
              <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
              Creating...
            {:else}
              Create Client
            {/if}
          </button>
        </div>
      </div>
    </div>
  {/if}
  
  <!-- Edit Client Modal -->
  {#if showEditClient && editingClient}
    <div class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-2xl max-h-screen overflow-y-auto">
        <h2 class="text-xl font-bold mb-4">Edit Client</h2>
        
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Client Name</label>
            <input
              type="text"
              bind:value={editingClient.name}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              placeholder="Grand Hotel"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Type</label>
            <select
              bind:value={editingClient.type}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="hotel">Hotel</option>
              <option value="restaurant">Restaurant</option>
              <option value="spa">Spa</option>
              <option value="hospital">Hospital</option>
              <option value="other">Other</option>
            </select>
          </div>
          
          <div class="col-span-2">
            <label class="block text-sm font-medium text-gray-700 mb-1">Address</label>
            <input
              type="text"
              bind:value={editingClient.address}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              placeholder="Jl. Sudirman No. 1, Jakarta"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Phone</label>
            <input
              type="text"
              bind:value={editingClient.phone}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              placeholder="+62 21 1234567"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
            <input
              type="email"
              bind:value={editingClient.email}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              placeholder="contact@hotel.com"
            />
          </div>
          
          <div class="col-span-2">
            <label class="block text-sm font-medium text-gray-700 mb-1">Contact Person</label>
            <input
              type="text"
              bind:value={editingClient.contact_person}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              placeholder="John Doe"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Pricing Type</label>
            <select
              bind:value={editingClient.pricing_type}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="per_kg">Per Kg</option>
              <option value="per_piece">Per Piece</option>
              <option value="flat_rate">Flat Rate</option>
            </select>
          </div>
          
          {#if editingClient.pricing_type === 'per_kg'}
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Price per Kg</label>
              <input
                type="number"
                bind:value={editingClient.price_per_kg}
                class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
                placeholder="15000"
              />
            </div>
          {:else if editingClient.pricing_type === 'per_piece'}
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Price per Piece</label>
              <input
                type="number"
                bind:value={editingClient.price_per_piece}
                class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
                placeholder="5000"
              />
            </div>
          {:else if editingClient.pricing_type === 'flat_rate'}
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Flat Rate</label>
              <input
                type="number"
                bind:value={editingClient.flat_rate}
                class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
                placeholder="5000000"
              />
            </div>
          {/if}
        </div>
        
        <div class="flex justify-end space-x-3 mt-6">
          <button
            on:click={() => {showEditClient = false; editingClient = null;}}
            class="px-4 py-2 border border-gray-300 rounded-md hover:bg-gray-50"
          >
            Cancel
          </button>
          <button
            on:click={updateClient}
            disabled={loadingUpdateClient}
            class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center"
          >
            {#if loadingUpdateClient}
              <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
              Updating...
            {:else}
              Update Client
            {/if}
          </button>
        </div>
      </div>
    </div>
  {/if}
  
  <!-- Add Staff Modal -->
  {#if showAddStaff}
    <div class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h2 class="text-xl font-bold mb-4">Assign Staff to Client</h2>
        
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Select User</label>
            <select
              bind:value={newStaff.user_id}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="">Choose a user...</option>
              {#each users as user}
                <option value={user.user_id}>{user.email} ({user.role})</option>
              {/each}
            </select>
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Role for this Client</label>
            <select
              bind:value={newStaff.role}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="contact">Contact Person</option>
              <option value="billing">Billing Contact</option>
              <option value="operations">Operations Contact</option>
            </select>
          </div>
        </div>
        
        <div class="flex justify-end space-x-3 mt-6">
          <button
            on:click={() => showAddStaff = false}
            class="px-4 py-2 border border-gray-300 rounded-md hover:bg-gray-50"
          >
            Cancel
          </button>
          <button
            on:click={assignStaff}
            class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
          >
            Assign Staff
          </button>
        </div>
      </div>
    </div>
  {/if}
  
  <!-- Add Price Modal -->
  {#if showAddPrice}
    <div class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h2 class="text-xl font-bold mb-4">Add New Price</h2>
        
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Service Name</label>
            <input
              type="text"
              bind:value={newPrice.name}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              placeholder="e.g., Regular Laundry"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Pricing Model</label>
            <select
              bind:value={newPrice.pricing_model}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="per_kg">Per KG</option>
              <option value="per_piece">Per Piece</option>
              <option value="flat_rate">Flat Rate</option>
            </select>
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">
              Price (IDR) 
              {#if newPrice.pricing_model === 'per_kg'}
                per KG
              {:else if newPrice.pricing_model === 'per_piece'}
                per Piece
              {:else}
                per Month
              {/if}
            </label>
            <input
              type="number"
              bind:value={newPrice.price}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              placeholder="0"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Description (Optional)</label>
            <textarea
              bind:value={newPrice.description}
              rows="2"
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              placeholder="Service details..."
            ></textarea>
          </div>
        </div>
        
        <div class="mt-6 flex justify-end gap-3">
          <button
            on:click={() => showAddPrice = false}
            class="px-4 py-2 border border-gray-300 rounded-md hover:bg-gray-50"
          >
            Cancel
          </button>
          <button
            on:click={createPrice}
            class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
          >
            Add Price
          </button>
        </div>
      </div>
    </div>
  {/if}
  
  <!-- Edit Price Modal -->
  {#if editingPrice}
    <div class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h2 class="text-xl font-bold mb-4">Edit Price</h2>
        
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Service Name</label>
            <input
              type="text"
              bind:value={editingPrice.name}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Pricing Model</label>
            <select
              bind:value={editingPrice.pricing_model}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="per_kg">Per KG</option>
              <option value="per_piece">Per Piece</option>
              <option value="flat_rate">Flat Rate</option>
            </select>
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">
              Price (IDR)
              {#if editingPrice.pricing_model === 'per_kg'}
                per KG
              {:else if editingPrice.pricing_model === 'per_piece'}
                per Piece
              {:else}
                per Month
              {/if}
            </label>
            <input
              type="number"
              bind:value={editingPrice.price}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
            <textarea
              bind:value={editingPrice.description}
              rows="2"
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            ></textarea>
          </div>
        </div>
        
        <div class="mt-6 flex justify-end gap-3">
          <button
            on:click={() => editingPrice = null}
            class="px-4 py-2 border border-gray-300 rounded-md hover:bg-gray-50"
          >
            Cancel
          </button>
          <button
            on:click={updatePrice}
            class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
          >
            Update Price
          </button>
        </div>
      </div>
    </div>
  {/if}
  
  <!-- Add Rental Modal -->
  {#if showAddRental}
    <div class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h2 class="text-xl font-bold mb-4">Add Rental Item</h2>
        
        <div class="space-y-4">
          <div>
            <label for="rental-type" class="block text-sm font-medium text-gray-700 mb-1">Item Type</label>
            <select
              id="rental-type"
              bind:value={newRental.item_type}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="towel">Towel</option>
              <option value="bedding">Bedding</option>
              <option value="bathrobe">Bathrobe</option>
              <option value="other">Other</option>
            </select>
          </div>
          
          <div>
            <label for="rental-name" class="block text-sm font-medium text-gray-700 mb-1">Item Name</label>
            <input
              id="rental-name"
              type="text"
              bind:value={newRental.item_name}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              placeholder="e.g., Bath Towel, Queen Size Bedsheet"
            />
          </div>
          
          <div>
            <label for="rental-quantity" class="block text-sm font-medium text-gray-700 mb-1">Quantity</label>
            <input
              id="rental-quantity"
              type="number"
              bind:value={newRental.quantity}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              placeholder="0"
              min="0"
            />
          </div>
          
          <div>
            <label for="rental-price" class="block text-sm font-medium text-gray-700 mb-1">Unit Price (IDR)</label>
            <input
              id="rental-price"
              type="number"
              bind:value={newRental.unit_price}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              placeholder="0"
              min="0"
            />
          </div>
          
          <div>
            <label for="rental-notes" class="block text-sm font-medium text-gray-700 mb-1">Notes (Optional)</label>
            <textarea
              id="rental-notes"
              bind:value={newRental.notes}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              rows="3"
              placeholder="Additional notes..."
            ></textarea>
          </div>
        </div>
        
        <div class="mt-6 flex justify-end space-x-3">
          <button
            on:click={() => showAddRental = false}
            class="px-4 py-2 border border-gray-300 rounded-md hover:bg-gray-50"
          >
            Cancel
          </button>
          <button
            on:click={createRental}
            disabled={loadingCreateRental}
            class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center"
          >
            {#if loadingCreateRental}
              <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
              Adding...
            {:else}
              Add Rental
            {/if}
          </button>
        </div>
      </div>
    </div>
  {/if}
  
  <!-- Edit Rental Modal -->
  {#if editingRental}
    <div class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h2 class="text-xl font-bold mb-4">Edit Rental Item</h2>
        
        <div class="space-y-4">
          <div>
            <label for="edit-rental-type" class="block text-sm font-medium text-gray-700 mb-1">Item Type</label>
            <select
              id="edit-rental-type"
              bind:value={editingRental.item_type}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="towel">Towel</option>
              <option value="bedding">Bedding</option>
              <option value="bathrobe">Bathrobe</option>
              <option value="other">Other</option>
            </select>
          </div>
          
          <div>
            <label for="edit-rental-name" class="block text-sm font-medium text-gray-700 mb-1">Item Name</label>
            <input
              id="edit-rental-name"
              type="text"
              bind:value={editingRental.item_name}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              placeholder="e.g., Bath Towel, Queen Size Bedsheet"
            />
          </div>
          
          <div>
            <label for="edit-rental-quantity" class="block text-sm font-medium text-gray-700 mb-1">Quantity</label>
            <input
              id="edit-rental-quantity"
              type="number"
              bind:value={editingRental.quantity}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              placeholder="0"
              min="0"
            />
          </div>
          
          <div>
            <label for="edit-rental-price" class="block text-sm font-medium text-gray-700 mb-1">Unit Price (IDR)</label>
            <input
              id="edit-rental-price"
              type="number"
              bind:value={editingRental.unit_price}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              placeholder="0"
              min="0"
            />
          </div>
          
          <div>
            <label for="edit-rental-status" class="block text-sm font-medium text-gray-700 mb-1">Status</label>
            <select
              id="edit-rental-status"
              bind:value={editingRental.status}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="active">Active</option>
              <option value="returned">Returned</option>
              <option value="damaged">Damaged</option>
              <option value="lost">Lost</option>
            </select>
          </div>
          
          <div>
            <label for="edit-rental-notes" class="block text-sm font-medium text-gray-700 mb-1">Notes (Optional)</label>
            <textarea
              id="edit-rental-notes"
              bind:value={editingRental.notes}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              rows="3"
              placeholder="Additional notes..."
            ></textarea>
          </div>
        </div>
        
        <div class="mt-6 flex justify-end space-x-3">
          <button
            on:click={() => editingRental = null}
            class="px-4 py-2 border border-gray-300 rounded-md hover:bg-gray-50"
          >
            Cancel
          </button>
          <button
            on:click={updateRental}
            class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
          >
            Update Rental
          </button>
        </div>
      </div>
    </div>
  {/if}
</div> 