<script lang="ts">
  import { page } from '$app/stores';
  import { supabase } from '$lib/supabase';
  
  const user = $page.data.user;
  
  // Tab management
  let activeTab = 'profile';
  
  // Profile form
  let profileForm = {
    email: '',
    currentEmail: ''
  };
  
  // Password form
  let passwordForm = {
    currentPassword: '',
    newPassword: '',
    confirmPassword: ''
  };
  
  // Loading states
  let loadingProfile = false;
  let loadingPassword = false;
  
  // Messages
  let profileMessage = { type: '', text: '' };
  let passwordMessage = { type: '', text: '' };
  
  // Load current user data
  async function loadUserData() {
    if (!supabase) return;
    
    try {
      const { data, error } = await supabase
        .from('users')
        .select('email')
        .eq('user_id', user.userId)
        .single();
      
      if (data) {
        profileForm.email = data.email;
        profileForm.currentEmail = data.email;
      }
    } catch (error) {
      console.error('Error loading user data:', error);
    }
  }
  
  // Update email
  async function updateEmail() {
    if (!supabase) {
      profileMessage = { type: 'error', text: 'Database not connected' };
      return;
    }
    
    if (!profileForm.email) {
      profileMessage = { type: 'error', text: 'Email is required' };
      return;
    }
    
    if (profileForm.email === profileForm.currentEmail) {
      profileMessage = { type: 'info', text: 'Email is the same as current' };
      return;
    }
    
    loadingProfile = true;
    profileMessage = { type: '', text: '' };
    
    try {
      // Check if new email already exists
      const { data: existingUser } = await supabase
        .from('users')
        .select('email')
        .eq('email', profileForm.email)
        .single();
      
      if (existingUser) {
        profileMessage = { type: 'error', text: 'Email already exists' };
        loadingProfile = false;
        return;
      }
      
      // Update email
      const { error } = await supabase
        .from('users')
        .update({ email: profileForm.email })
        .eq('user_id', user.userId);
      
      if (error) {
        profileMessage = { type: 'error', text: 'Failed to update email: ' + error.message };
      } else {
        profileMessage = { type: 'success', text: 'Email updated successfully! Please login again with your new email.' };
        profileForm.currentEmail = profileForm.email;
        
        // Log out after 3 seconds
        setTimeout(() => {
          document.cookie = 'session=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
          window.location.href = '/';
        }, 3000);
      }
    } catch (error) {
      profileMessage = { type: 'error', text: 'Error updating email' };
    } finally {
      loadingProfile = false;
    }
  }
  
  // Update password
  async function updatePassword() {
    if (!supabase) {
      passwordMessage = { type: 'error', text: 'Database not connected' };
      return;
    }
    
    // Validate form
    if (!passwordForm.currentPassword || !passwordForm.newPassword || !passwordForm.confirmPassword) {
      passwordMessage = { type: 'error', text: 'All fields are required' };
      return;
    }
    
    if (passwordForm.newPassword.length < 6) {
      passwordMessage = { type: 'error', text: 'New password must be at least 6 characters' };
      return;
    }
    
    if (passwordForm.newPassword !== passwordForm.confirmPassword) {
      passwordMessage = { type: 'error', text: 'New passwords do not match' };
      return;
    }
    
    loadingPassword = true;
    passwordMessage = { type: '', text: '' };
    
    try {
      // First verify current password
      const { data: userData } = await supabase
        .from('users')
        .select('password')
        .eq('user_id', user.userId)
        .single();
      
      if (!userData) {
        passwordMessage = { type: 'error', text: 'User not found' };
        loadingPassword = false;
        return;
      }
      
      // Verify current password
      const verifyResponse = await fetch('/api/verify-password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          password: passwordForm.currentPassword,
          hash: userData.password
        })
      });
      
      const { valid } = await verifyResponse.json();
      
      if (!valid) {
        passwordMessage = { type: 'error', text: 'Current password is incorrect' };
        loadingPassword = false;
        return;
      }
      
      // Hash new password
      const hashResponse = await fetch('/api/hash-password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ password: passwordForm.newPassword })
      });
      
      const { hashedPassword } = await hashResponse.json();
      
      // Update password in database
      const { error } = await supabase
        .from('users')
        .update({ password: hashedPassword })
        .eq('user_id', user.userId);
      
      if (error) {
        passwordMessage = { type: 'error', text: 'Failed to update password: ' + error.message };
      } else {
        passwordMessage = { type: 'success', text: 'Password updated successfully!' };
        // Clear form
        passwordForm = {
          currentPassword: '',
          newPassword: '',
          confirmPassword: ''
        };
      }
    } catch (error) {
      passwordMessage = { type: 'error', text: 'Error updating password' };
    } finally {
      loadingPassword = false;
    }
  }
  
  // Load user data on mount
  import { onMount } from 'svelte';
  onMount(() => {
    loadUserData();
  });
</script>

<div class="p-6 max-w-4xl mx-auto">
  <div class="mb-8">
    <h1 class="text-3xl font-bold text-gray-800">Settings</h1>
    <p class="text-gray-600 mt-2">Manage your account settings and preferences</p>
  </div>
  
  <!-- Tab Navigation -->
  <div class="border-b border-gray-200 mb-6">
    <nav class="-mb-px flex space-x-8">
      <button
        on:click={() => activeTab = 'profile'}
        class="py-2 px-1 border-b-2 font-medium text-sm {activeTab === 'profile' ? 'border-indigo-500 text-indigo-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'}"
      >
        Profile
      </button>
      <button
        on:click={() => activeTab = 'security'}
        class="py-2 px-1 border-b-2 font-medium text-sm {activeTab === 'security' ? 'border-indigo-500 text-indigo-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'}"
      >
        Security
      </button>
    </nav>
  </div>
  
  <!-- Profile Tab -->
  {#if activeTab === 'profile'}
    <div class="bg-white rounded-lg shadow p-6">
      <h2 class="text-xl font-semibold mb-6">Profile Information</h2>
      
      <form on:submit|preventDefault={updateEmail} class="space-y-6">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Current Role</label>
          <p class="text-sm text-gray-900 bg-gray-50 px-3 py-2 rounded">
            {user.role.replace(/_/g, ' ').toUpperCase()}
          </p>
        </div>
        
        <div>
          <label for="email" class="block text-sm font-medium text-gray-700 mb-1">Email Address</label>
          <input
            id="email"
            type="email"
            bind:value={profileForm.email}
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            required
          />
          <p class="mt-1 text-sm text-gray-500">
            Changing your email will require you to login again
          </p>
        </div>
        
        {#if profileMessage.text}
          <div class="rounded-md p-4 {profileMessage.type === 'error' ? 'bg-red-50 text-red-800' : profileMessage.type === 'success' ? 'bg-green-50 text-green-800' : 'bg-blue-50 text-blue-800'}">
            {profileMessage.text}
          </div>
        {/if}
        
        <div>
          <button
            type="submit"
            disabled={loadingProfile}
            class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 disabled:opacity-50"
          >
            {loadingProfile ? 'Updating...' : 'Update Email'}
          </button>
        </div>
      </form>
    </div>
  {/if}
  
  <!-- Security Tab -->
  {#if activeTab === 'security'}
    <div class="bg-white rounded-lg shadow p-6">
      <h2 class="text-xl font-semibold mb-6">Change Password</h2>
      
      <form on:submit|preventDefault={updatePassword} class="space-y-6 max-w-md">
        <div>
          <label for="currentPassword" class="block text-sm font-medium text-gray-700 mb-1">Current Password</label>
          <input
            id="currentPassword"
            type="password"
            bind:value={passwordForm.currentPassword}
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            required
          />
        </div>
        
        <div>
          <label for="newPassword" class="block text-sm font-medium text-gray-700 mb-1">New Password</label>
          <input
            id="newPassword"
            type="password"
            bind:value={passwordForm.newPassword}
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            required
            minlength="6"
          />
          <p class="mt-1 text-sm text-gray-500">Minimum 6 characters</p>
        </div>
        
        <div>
          <label for="confirmPassword" class="block text-sm font-medium text-gray-700 mb-1">Confirm New Password</label>
          <input
            id="confirmPassword"
            type="password"
            bind:value={passwordForm.confirmPassword}
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            required
            minlength="6"
          />
        </div>
        
        {#if passwordMessage.text}
          <div class="rounded-md p-4 {passwordMessage.type === 'error' ? 'bg-red-50 text-red-800' : passwordMessage.type === 'success' ? 'bg-green-50 text-green-800' : 'bg-blue-50 text-blue-800'}">
            {passwordMessage.text}
          </div>
        {/if}
        
        <div>
          <button
            type="submit"
            disabled={loadingPassword}
            class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 disabled:opacity-50"
          >
            {loadingPassword ? 'Updating...' : 'Update Password'}
          </button>
        </div>
      </form>
      
      <div class="mt-8 pt-8 border-t border-gray-200">
        <h3 class="text-lg font-medium text-gray-900 mb-4">Password Requirements</h3>
        <ul class="list-disc list-inside text-sm text-gray-600 space-y-1">
          <li>Minimum 6 characters</li>
          <li>Use a mix of letters, numbers, and symbols for better security</li>
          <li>Avoid using common words or personal information</li>
          <li>Don't reuse passwords from other accounts</li>
        </ul>
      </div>
    </div>
  {/if}
  
  <!-- Additional Settings Info -->
  <div class="mt-8 bg-blue-50 border border-blue-200 rounded-lg p-4">
    <h3 class="text-sm font-medium text-blue-900">Need help?</h3>
    <p class="mt-1 text-sm text-blue-700">
      Contact your system administrator if you need assistance with your account settings.
    </p>
  </div>
</div> 