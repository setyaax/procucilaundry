<script lang="ts">
  import '../../app.css';
  
  let email = '';
  let password = '';
  let role = 'hotel_staff';
  let message = '';
  let error = '';
  let loading = false;

  async function handleSignup() {
    loading = true;
    message = '';
    error = '';
    
    try {
      const response = await fetch('/signup', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password, role })
      });

      const result = await response.json();
      
      if (response.ok) {
        message = `Success! User ${result.user.email} created with role ${result.user.role}`;
        // Clear form
        email = '';
        password = '';
      } else {
        error = result.error || 'Failed to create user';
      }
    } catch (err) {
      error = 'Network error: ' + (err instanceof Error ? err.message : 'Unknown error');
    }
    
    loading = false;
  }
</script>

<div class="min-h-screen bg-gray-50 p-8">
  <div class="max-w-md mx-auto">
    <h1 class="text-2xl font-bold mb-6">Create New User</h1>
    
    <form on:submit|preventDefault={handleSignup} class="space-y-4 bg-white p-6 rounded-lg shadow">
      <div>
        <label for="email" class="block text-sm font-medium text-gray-700">Email</label>
        <input
          bind:value={email}
          type="email"
          id="email"
          required
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm p-2 border"
          placeholder="user@example.com"
        />
      </div>

      <div>
        <label for="password" class="block text-sm font-medium text-gray-700">Password</label>
        <input
          bind:value={password}
          type="password"
          id="password"
          required
          minlength="6"
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm p-2 border"
          placeholder="At least 6 characters"
        />
      </div>

      <div>
        <label for="role" class="block text-sm font-medium text-gray-700">Role</label>
        <select
          bind:value={role}
          id="role"
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm p-2 border"
        >
          <option value="main_admin">Main Admin</option>
          <option value="laundry_staff">Laundry Staff</option>
          <option value="hotel_staff">Hotel Staff</option>
        </select>
      </div>

      <button
        type="submit"
        disabled={loading}
        class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50"
      >
        {loading ? 'Creating...' : 'Create User'}
      </button>
    </form>

    {#if message}
      <div class="mt-4 p-4 bg-green-100 border border-green-400 text-green-700 rounded">
        {message}
      </div>
    {/if}

    {#if error}
      <div class="mt-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded">
        {error}
      </div>
    {/if}

    <div class="mt-6 text-center">
      <a href="/" class="text-indigo-600 hover:text-indigo-500">Back to Login</a>
    </div>
  </div>
</div> 