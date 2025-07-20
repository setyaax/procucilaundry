<script lang="ts">
  import { enhance } from '$app/forms';
  import { goto } from '$app/navigation';
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  
  let email = '';
  let password = '';
  let role = 'main_admin';
  let error = '';
  let loading = false;
  
  // Redirect if already logged in
  onMount(() => {
    if ($page.data.user) {
      goto('/dashboard');
    }
  });
</script>

<div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-indigo-50 to-purple-50">
  <div class="max-w-md w-full space-y-8">
    <div>
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
        Laundry Management for Hotels
      </h2>
      <p class="mt-2 text-center text-sm text-gray-600">
        Professional laundry services tailored for hotels. Manage orders, track status, and generate reports efficiently.
      </p>
    </div>
    <form 
      class="mt-8 space-y-6" 
      method="POST"
      use:enhance={() => {
        loading = true;
        error = '';
        return async ({ result }) => {
          loading = false;
          if (result.type === 'redirect') {
            // Invalidate all data to ensure layout refreshes with new user state
            await goto(result.location, { invalidateAll: true });
          } else if (result.type === 'failure') {
            error = (result.data as any)?.error || 'Login failed';
          } else if (result.type === 'error') {
            error = 'An error occurred during login';
          }
        };
      }}
    >
      <div class="rounded-md shadow-sm -space-y-px">
        <div>
          <label for="email" class="sr-only">Email address</label>
          <input bind:value={email} id="email" name="email" type="email" autocomplete="email" required class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm" placeholder="Email address" />
        </div>
        <div>
          <label for="password" class="sr-only">Password</label>
          <input bind:value={password} id="password" name="password" type="password" autocomplete="current-password" required class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm" placeholder="Password" />
        </div>
        <div>
          <label for="role" class="sr-only">Role</label>
          <select bind:value={role} id="role" name="role" class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-b-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm">
            <option value="main_admin">Main Admin</option>
            <option value="laundry_staff">Laundry Staff</option>
            <option value="hotel_staff">Hotel Staff</option>
          </select>
        </div>
      </div>
      
      {#if error}
        <div class="rounded-md bg-red-50 p-4">
          <div class="flex items-start">
            <svg class="w-5 h-5 text-red-400 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.732-.833-2.464 0L3.34 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
            </svg>
            <div class="ml-3">
              <p class="text-sm text-red-800">{error}</p>
              {#if error.includes('Database connection failed')}
                <p class="text-xs text-red-600 mt-2">
                  💡 <strong>Quick solution:</strong> Try the demo account for immediate access
                </p>
              {/if}
            </div>
          </div>
        </div>
      {/if}
      
      <div>
        <button 
          type="submit" 
          disabled={loading}
          class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50"
        >
          {loading ? 'Logging in...' : 'Login'}
        </button>
      </div>
      
      <div class="text-center text-sm">
        <p class="text-gray-600">
          Demo: <code class="bg-gray-100 px-1">demo@example.com</code> / <code class="bg-gray-100 px-1">demo123</code>
        </p>
        <p class="mt-2">
          <a href="/signup" class="text-indigo-600 hover:text-indigo-500">Create new account</a>
        </p>
      </div>
    </form>
  </div>
</div>
