<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabase';
  import { page } from '$app/stores';
  
  const currentUser = $page.data.user;
  
  // Expanded role definitions
  const roleCategories = {
    admin: {
      label: 'Administrator',
      roles: [
        { value: 'main_admin', label: 'Main Admin', description: 'Full system access' }
      ]
    },
    laundry: {
      label: 'Laundry Staff',
      roles: [
        { value: 'laundry_manager', label: 'Manager', description: 'Manages laundry operations' },
        { value: 'laundry_picker', label: 'Picking & Delivery Team', description: 'Picks up and delivers laundry' },
        { value: 'laundry_washer', label: 'Washing Team', description: 'Handles washing and processing' },
        { value: 'laundry_cashier', label: 'Cashier', description: 'Handles payments and billing' }
      ]
    },
    hotel: {
      label: 'Hotel Staff',
      roles: [
        { value: 'hotel_owner', label: 'Hotel Owner', description: 'Views reports and analytics' },
        { value: 'hotel_logistic', label: 'Logistic Staff', description: 'Manages hotel logistics' },
        { value: 'hotel_accountant', label: 'Accountant', description: 'Handles hotel accounting' },
        { value: 'hotel_staff', label: 'General Staff', description: 'Creates laundry orders' }
      ]
    }
  };
  
  let users: any[] = [];
  let loading = true;
  let showAddUser = false;
  let editingUser: any = null;
  let searchTerm = '';
  let filterRole = '';
  
  // New user form
  let newUser = {
    email: '',
    password: '',
    role: 'hotel_staff',
    hotel_name: ''
  };
  
  // Pagination
  let currentPage = 1;
  let itemsPerPage = 10;
  let totalUsers = 0;
  
  async function loadUsers() {
    if (!supabase) return;
    
    loading = true;
    try {
      // Get total count
      const { count } = await supabase
        .from('users')
        .select('*', { count: 'exact', head: true });
      
      totalUsers = count || 0;
      
      // Get paginated users
      let query = supabase
        .from('users')
        .select('*')
        .order('created_at', { ascending: false })
        .range((currentPage - 1) * itemsPerPage, currentPage * itemsPerPage - 1);
      
      if (searchTerm) {
        query = query.ilike('email', `%${searchTerm}%`);
      }
      
      if (filterRole) {
        query = query.eq('role', filterRole);
      }
      
      const { data, error } = await query;
      
      if (error) {
        console.error('Error loading users:', error);
      } else {
        users = data || [];
      }
    } catch (error) {
      console.error('Error:', error);
    } finally {
      loading = false;
    }
  }
  
  async function createUser() {
    if (!supabase || !newUser.email || !newUser.password || !newUser.role) return;
    
    try {
      // Hash password via API
      const hashResponse = await fetch('/api/hash-password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ password: newUser.password })
      });
      
      const { hashedPassword } = await hashResponse.json();
      
      // Create user
      const { data, error } = await supabase
        .from('users')
        .insert({
          email: newUser.email,
          password: hashedPassword,
          role: newUser.role,
          hotel_name: newUser.hotel_name || null
        })
        .select()
        .single();
      
      if (error) {
        alert('Error creating user: ' + error.message);
      } else {
        alert('User created successfully!');
        showAddUser = false;
        newUser = { email: '', password: '', role: 'hotel_staff', hotel_name: '' };
        await loadUsers();
      }
    } catch (error) {
      alert('Error: ' + error);
    }
  }
  
  async function updateUserRole(userId: string, newRole: string) {
    if (!supabase) return;
    
    const { error } = await supabase
      .from('users')
      .update({ role: newRole })
      .eq('user_id', userId);
    
    if (error) {
      alert('Error updating role: ' + error.message);
    } else {
      await loadUsers();
    }
  }
  
  async function deleteUser(userId: string) {
    if (!supabase) return;
    
    if (!confirm('Are you sure you want to delete this user?')) return;
    
    const { error } = await supabase
      .from('users')
      .delete()
      .eq('user_id', userId);
    
    if (error) {
      alert('Error deleting user: ' + error.message);
    } else {
      await loadUsers();
    }
  }
  
  function getRoleInfo(role: string) {
    for (const category of Object.values(roleCategories)) {
      const roleInfo = category.roles.find(r => r.value === role);
      if (roleInfo) return roleInfo;
    }
    return { value: role, label: role, description: '' };
  }
  
  function getRoleBadgeColor(role: string) {
    if (role.includes('admin')) return 'bg-red-100 text-red-800';
    if (role.includes('manager') || role.includes('owner')) return 'bg-purple-100 text-purple-800';
    if (role.includes('laundry')) return 'bg-blue-100 text-blue-800';
    if (role.includes('hotel')) return 'bg-green-100 text-green-800';
    return 'bg-gray-100 text-gray-800';
  }
  
  onMount(() => {
    loadUsers();
  });
  
  $: totalPages = Math.ceil(totalUsers / itemsPerPage);
</script>

<div class="p-6 max-w-7xl mx-auto">
  <div class="mb-8">
    <h1 class="text-3xl font-bold text-gray-800">User Management</h1>
    <p class="text-gray-600 mt-2">Manage all system users and their roles</p>
  </div>
  
  <!-- Actions Bar -->
  <div class="bg-white rounded-lg shadow p-4 mb-6">
    <div class="flex flex-col md:flex-row justify-between items-center gap-4">
      <div class="flex flex-col md:flex-row gap-4 w-full md:w-auto">
        <input
          type="text"
          placeholder="Search by email..."
          bind:value={searchTerm}
          on:input={() => loadUsers()}
          class="px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
        />
        
        <select
          bind:value={filterRole}
          on:change={() => loadUsers()}
          class="px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
        >
          <option value="">All Roles</option>
          {#each Object.entries(roleCategories) as [key, category]}
            <optgroup label={category.label}>
              {#each category.roles as role}
                <option value={role.value}>{role.label}</option>
              {/each}
            </optgroup>
          {/each}
        </select>
      </div>
      
      {#if currentUser.role === 'main_admin'}
        <button
          on:click={() => showAddUser = true}
          class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 transition-colors"
        >
          + Add New User
        </button>
      {/if}
    </div>
  </div>
  
  <!-- User Statistics -->
  <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
    <div class="bg-white rounded-lg shadow p-4">
      <p class="text-sm text-gray-600">Total Users</p>
      <p class="text-2xl font-bold text-gray-900">{totalUsers}</p>
    </div>
    <div class="bg-white rounded-lg shadow p-4">
      <p class="text-sm text-gray-600">Laundry Staff</p>
      <p class="text-2xl font-bold text-blue-600">
        {users.filter(u => u.role.includes('laundry')).length}
      </p>
    </div>
    <div class="bg-white rounded-lg shadow p-4">
      <p class="text-sm text-gray-600">Hotel Staff</p>
      <p class="text-2xl font-bold text-green-600">
        {users.filter(u => u.role.includes('hotel')).length}
      </p>
    </div>
    <div class="bg-white rounded-lg shadow p-4">
      <p class="text-sm text-gray-600">Administrators</p>
      <p class="text-2xl font-bold text-red-600">
        {users.filter(u => u.role.includes('admin')).length}
      </p>
    </div>
  </div>
  
  <!-- Users Table -->
  {#if loading}
    <div class="bg-white rounded-lg shadow p-8">
      <div class="text-center text-gray-500">Loading users...</div>
    </div>
  {:else}
    <div class="bg-white rounded-lg shadow overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">User</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Category</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Hotel</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Created</th>
              {#if currentUser.role === 'main_admin'}
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              {/if}
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            {#each users as user}
              {@const roleInfo = getRoleInfo(user.role)}
              <tr>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div>
                    <div class="text-sm font-medium text-gray-900">{user.email}</div>
                    <div class="text-sm text-gray-500">ID: {user.user_id.substring(0, 8)}...</div>
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full {getRoleBadgeColor(user.role)}">
                    {roleInfo.label}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {#if user.role.includes('laundry')}
                    Laundry
                  {:else if user.role.includes('hotel')}
                    Hotel
                  {:else if user.role.includes('admin')}
                    Admin
                  {:else}
                    Other
                  {/if}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {user.hotel_name || '-'}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {new Date(user.created_at).toLocaleDateString()}
                </td>
                {#if currentUser.role === 'main_admin'}
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <button
                      on:click={() => editingUser = user}
                      class="text-indigo-600 hover:text-indigo-900 mr-3"
                    >
                      Edit
                    </button>
                    {#if user.user_id !== currentUser.userId}
                      <button
                        on:click={() => deleteUser(user.user_id)}
                        class="text-red-600 hover:text-red-900"
                      >
                        Delete
                      </button>
                    {/if}
                  </td>
                {/if}
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
      
      <!-- Pagination -->
      <div class="bg-gray-50 px-4 py-3 flex items-center justify-between border-t border-gray-200">
        <div class="flex-1 flex justify-between sm:hidden">
          <button
            on:click={() => { currentPage = Math.max(1, currentPage - 1); loadUsers(); }}
            disabled={currentPage === 1}
            class="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50"
          >
            Previous
          </button>
          <button
            on:click={() => { currentPage = Math.min(totalPages, currentPage + 1); loadUsers(); }}
            disabled={currentPage === totalPages}
            class="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50"
          >
            Next
          </button>
        </div>
        <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
          <div>
            <p class="text-sm text-gray-700">
              Showing page <span class="font-medium">{currentPage}</span> of <span class="font-medium">{totalPages}</span>
            </p>
          </div>
          <div>
            <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px">
              <button
                on:click={() => { currentPage = Math.max(1, currentPage - 1); loadUsers(); }}
                disabled={currentPage === 1}
                class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50"
              >
                Previous
              </button>
              <button
                on:click={() => { currentPage = Math.min(totalPages, currentPage + 1); loadUsers(); }}
                disabled={currentPage === totalPages}
                class="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50"
              >
                Next
              </button>
            </nav>
          </div>
        </div>
      </div>
    </div>
  {/if}
  
  <!-- Add User Modal -->
  {#if showAddUser}
    <div class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h2 class="text-xl font-bold mb-4">Add New User</h2>
        
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
            <input
              type="email"
              bind:value={newUser.email}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              placeholder="user@example.com"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Password</label>
            <input
              type="password"
              bind:value={newUser.password}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              placeholder="Minimum 6 characters"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Role</label>
            <select
              bind:value={newUser.role}
              class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              {#each Object.entries(roleCategories) as [key, category]}
                <optgroup label={category.label}>
                  {#each category.roles as role}
                    <option value={role.value}>{role.label} - {role.description}</option>
                  {/each}
                </optgroup>
              {/each}
            </select>
          </div>
          
          {#if newUser.role.includes('hotel')}
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Hotel Name (Optional)</label>
              <input
                type="text"
                bind:value={newUser.hotel_name}
                class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
                placeholder="Grand Hotel"
              />
            </div>
          {/if}
        </div>
        
        <div class="mt-6 flex justify-end gap-3">
          <button
            on:click={() => showAddUser = false}
            class="px-4 py-2 border border-gray-300 rounded-md hover:bg-gray-50"
          >
            Cancel
          </button>
          <button
            on:click={createUser}
            class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
          >
            Create User
          </button>
        </div>
      </div>
    </div>
  {/if}
  
  <!-- Edit User Modal -->
  {#if editingUser}
    <div class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h2 class="text-xl font-bold mb-4">Edit User Role</h2>
        
        <div class="mb-4">
          <p class="text-sm text-gray-600">Email: {editingUser.email}</p>
          <p class="text-sm text-gray-600">Current Role: {getRoleInfo(editingUser.role).label}</p>
        </div>
        
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">New Role</label>
          <select
            value={editingUser.role}
            on:change={(e) => editingUser.role = e.currentTarget.value}
            class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
          >
            {#each Object.entries(roleCategories) as [key, category]}
              <optgroup label={category.label}>
                {#each category.roles as role}
                  <option value={role.value}>{role.label} - {role.description}</option>
                {/each}
              </optgroup>
            {/each}
          </select>
        </div>
        
        <div class="mt-6 flex justify-end gap-3">
          <button
            on:click={() => editingUser = null}
            class="px-4 py-2 border border-gray-300 rounded-md hover:bg-gray-50"
          >
            Cancel
          </button>
          <button
            on:click={() => {
              updateUserRole(editingUser.user_id, editingUser.role);
              editingUser = null;
            }}
            class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
          >
            Update Role
          </button>
        </div>
      </div>
    </div>
  {/if}
</div> 