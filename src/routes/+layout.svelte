<script lang="ts">
  import '../app.css';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  let sidebarOpen = true;
  
  // Make user reactive by using $: to watch for changes
  $: user = $page.data.user;

  function toggleSidebar() {
    sidebarOpen = !sidebarOpen;
  }

  async function logout() {
    // Call the logout endpoint
    const response = await fetch('/logout', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    if (response.ok) {
      // Invalidate all data and navigate to login
      await goto('/', { invalidateAll: true });
    }
  }

  const navItems: Record<string, { label: string; path: string }[]> = {
    main_admin: [
      { label: 'Dashboard', path: '/dashboard' },
      { label: 'Orders', path: '/orders' },
      { label: 'Clients', path: '/clients' },
      { label: 'Users', path: '/users' },
      { label: 'Settings', path: '/settings' }
    ],
    laundry_staff: [
      { label: 'Dashboard', path: '/dashboard' },
      { label: 'Orders', path: '/orders' },
      { label: 'Clients', path: '/clients' },
      { label: 'Schedule', path: '/schedule' },
      { label: 'Settings', path: '/settings' }
    ],
    hotel_staff: [
      { label: 'Dashboard', path: '/dashboard' },
      { label: 'Orders', path: '/orders' },
      { label: 'Order Status', path: '/status' },
      { label: 'History', path: '/history' },
      { label: 'Settings', path: '/settings' }
    ]
  };
  
  // Add support for all new roles
  const roleNavMapping: Record<string, string> = {
    'laundry_manager': 'laundry_staff',
    'laundry_picker': 'laundry_staff',
    'laundry_washer': 'laundry_staff',
    'laundry_cashier': 'laundry_staff',
    'hotel_owner': 'hotel_staff',
    'hotel_logistic': 'hotel_staff',
    'hotel_accountant': 'hotel_staff'
  };
  
  $: userRole = user?.role ? (roleNavMapping[user.role] || user.role) : null;
  $: userNavItems = userRole ? (navItems[userRole] || navItems.hotel_staff) : [];
</script>

{#if user}
  <div class="flex h-screen bg-gradient-to-br from-indigo-50 to-purple-50">
    <!-- Sidebar Overlay (Mobile) -->
    {#if sidebarOpen}
      <div class="fixed inset-0 z-40 lg:hidden bg-black bg-opacity-50" on:click={toggleSidebar}></div>
    {/if}

    <!-- Sidebar -->
    <aside class="{sidebarOpen ? 'translate-x-0' : '-translate-x-full'} fixed inset-y-0 left-0 z-50 w-64 bg-white shadow-2xl transform transition-transform duration-300 ease-in-out lg:relative lg:translate-x-0 overflow-y-auto">
      <div class="p-6 border-b border-indigo-100 flex items-center justify-between">
        <div>
          <h2 class="text-xl font-bold text-indigo-800">PROCUCI Laundry</h2>
          <p class="text-sm text-indigo-600">{user.role.replace('_', ' ').toUpperCase()}</p>
        </div>
        <!-- Close button for mobile -->
        <button on:click={toggleSidebar} class="lg:hidden text-indigo-600 hover:text-indigo-800 focus:outline-none" aria-label="Close sidebar">
          <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>
      <nav class="p-4 space-y-2">
        {#each userNavItems as item}
          <a 
            href="{item.path}" 
            class="flex items-center px-4 py-3 rounded-lg text-indigo-700 hover:bg-indigo-100 hover:text-indigo-900 transition-colors duration-200 {$page.url.pathname === item.path ? 'bg-indigo-100 text-indigo-900 font-medium' : ''}"
            on:click={() => sidebarOpen = false}
          >
            <!-- Add icons for menu items -->
            {#if item.label === 'Dashboard'}
              <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2H5a2 2 0 00-2-2z"></path>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 5a2 2 0 012-2h4a2 2 0 012 2v1H8V5z"></path>
              </svg>
            {:else if item.label === 'Orders'}
              <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"></path>
              </svg>
            {:else if item.label === 'Clients'}
              <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path>
              </svg>
            {:else if item.label === 'Users'}
              <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m3 4.197a4 4 0 11-6.8-1.5L12 16l-1.4-1.293A4 4 0 0115 21z"></path>
              </svg>
            {:else if item.label === 'Settings'}
              <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
              </svg>
            {:else}
              <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
              </svg>
            {/if}
            {item.label}
          </a>
        {/each}
      </nav>
    </aside>

    <!-- Main content -->
    <div class="flex-1 flex flex-col overflow-hidden">
      <!-- Header -->
      <header class="flex items-center justify-between p-4 bg-white shadow-md">
        <div class="flex items-center">
          <button on:click={toggleSidebar} class="text-indigo-600 hover:text-indigo-800 focus:outline-none mr-4" aria-label="Toggle sidebar">
            <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>
          <h1 class="text-xl font-semibold text-indigo-800">PROCUCI Dashboard</h1>
        </div>
        <div class="flex items-center space-x-4">
          <span class="text-sm text-indigo-600">Welcome, {user.email}</span>
          <button on:click={logout} class="px-4 py-2 bg-indigo-600 text-white rounded-md shadow hover:bg-indigo-700 transition-colors duration-200">Logout</button>
        </div>
      </header>

      <main class="flex-1 overflow-y-auto p-6 bg-white/50">
        <slot />
      </main>
    </div>
  </div>
{:else}
  <slot />
{/if}
