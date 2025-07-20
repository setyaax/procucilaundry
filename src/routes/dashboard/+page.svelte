<script lang="ts">
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import { supabase } from '$lib/supabase';
	
	const user = $page.data.user;
	
	// Statistics
	let stats = {
		totalClients: 0,
		activeRentals: 0,
		completedToday: 0,
		totalUsers: 0,
		totalRevenue: 0
	};
	
	let loading = true;
	
	onMount(async () => {
		if (supabase) {
			// Fetch statistics
			try {
				// Get total users
				const { count: userCount } = await supabase
					.from('users')
					.select('*', { count: 'exact', head: true });
				stats.totalUsers = userCount || 0;
				
				// For now, we'll use mock data since the tables don't exist yet
				stats.totalClients = 15;
				stats.activeRentals = 450;
				stats.completedToday = 8;
				stats.totalRevenue = 4580.50;
			} catch (error) {
				console.error('Error fetching stats:', error);
			}
		}
		loading = false;
	});
	
	const quickActions = [
		{ title: 'Manage Users', icon: '👥', href: '/users', color: 'bg-purple-500' },
		{ title: 'Manage Clients', icon: '🏢', href: '/clients', color: 'bg-blue-500' }
	];
</script>

<div class="p-6 max-w-7xl mx-auto">
	<div class="mb-8">
		<h1 class="text-3xl font-bold text-gray-800">Welcome back, {user.role.replace('_', ' ').toUpperCase()}</h1>
		<p class="text-gray-600 mt-2">Here's what's happening with your laundry service today.</p>
	</div>
	
	{#if loading}
		<div class="flex justify-center items-center h-64">
			<div class="text-gray-500">Loading dashboard...</div>
		</div>
	{:else}
		<!-- Statistics Cards -->
		<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
			<div class="bg-white rounded-lg shadow p-6">
				<div class="flex items-center justify-between">
					<div>
						<p class="text-sm font-medium text-gray-600">Total Clients</p>
						<p class="text-2xl font-bold text-gray-900">{stats.totalClients}</p>
					</div>
					<div class="p-3 bg-blue-100 rounded-full">
						<svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
						</svg>
					</div>
				</div>
				<p class="text-sm text-gray-600 mt-2">+3 new this month</p>
			</div>
			
			<div class="bg-white rounded-lg shadow p-6">
				<div class="flex items-center justify-between">
					<div>
						<p class="text-sm font-medium text-gray-600">Active Rentals</p>
						<p class="text-2xl font-bold text-orange-600">{stats.activeRentals}</p>
					</div>
					<div class="p-3 bg-orange-100 rounded-full">
						<svg class="w-6 h-6 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
						</svg>
					</div>
				</div>
				<p class="text-sm text-gray-600 mt-2">Items currently rented</p>
			</div>
			
			<div class="bg-white rounded-lg shadow p-6">
				<div class="flex items-center justify-between">
					<div>
						<p class="text-sm font-medium text-gray-600">Completed Today</p>
						<p class="text-2xl font-bold text-green-600">{stats.completedToday}</p>
					</div>
					<div class="p-3 bg-green-100 rounded-full">
						<svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
						</svg>
					</div>
				</div>
				<p class="text-sm text-gray-600 mt-2">Great progress!</p>
			</div>
			
			<div class="bg-white rounded-lg shadow p-6">
				<div class="flex items-center justify-between">
					<div>
						<p class="text-sm font-medium text-gray-600">Total Revenue</p>
						<p class="text-2xl font-bold text-gray-900">${stats.totalRevenue.toFixed(2)}</p>
					</div>
					<div class="p-3 bg-purple-100 rounded-full">
						<svg class="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
						</svg>
					</div>
				</div>
				<p class="text-sm text-gray-600 mt-2">This month</p>
			</div>
		</div>
		
		<!-- Quick Actions -->
		<div class="mb-8">
			<h2 class="text-xl font-semibold text-gray-800 mb-4">Quick Actions</h2>
			<div class="grid grid-cols-2 md:grid-cols-4 gap-4">
				{#each quickActions as action}
					<a href={action.href} class="flex flex-col items-center p-6 bg-white rounded-lg shadow hover:shadow-lg transition-shadow">
						<div class="{action.color} text-white text-3xl w-16 h-16 rounded-full flex items-center justify-center mb-3">
							{action.icon}
						</div>
						<span class="text-sm font-medium text-gray-700">{action.title}</span>
					</a>
				{/each}
			</div>
		</div>
		
		<!-- Recent Activity -->
		<div class="bg-white rounded-lg shadow">
			<div class="px-6 py-4 border-b border-gray-200">
				<h2 class="text-xl font-semibold text-gray-800">Recent Activity</h2>
			</div>
			<div class="p-6">
				<div class="space-y-4">
					<div class="flex items-center space-x-3">
						<div class="flex-shrink-0">
							<div class="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
								<span class="text-blue-600">🏢</span>
							</div>
						</div>
						<div class="flex-1">
							<p class="text-sm font-medium text-gray-900">New client added</p>
							<p class="text-sm text-gray-500">Grand Hotel Jakarta joined</p>
						</div>
						<div class="text-sm text-gray-400">2 hours ago</div>
					</div>
					
					<div class="flex items-center space-x-3">
						<div class="flex-shrink-0">
							<div class="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center">
								<span class="text-green-600">✅</span>
							</div>
						</div>
						<div class="flex-1">
							<p class="text-sm font-medium text-gray-900">Rental returned</p>
							<p class="text-sm text-gray-500">100 towels returned by Beach Resort Bali</p>
						</div>
						<div class="text-sm text-gray-400">5 hours ago</div>
					</div>
					
					<div class="flex items-center space-x-3">
						<div class="flex-shrink-0">
							<div class="w-10 h-10 bg-purple-100 rounded-full flex items-center justify-center">
								<span class="text-purple-600">👤</span>
							</div>
						</div>
						<div class="flex-1">
							<p class="text-sm font-medium text-gray-900">New staff member</p>
							<p class="text-sm text-gray-500">John Doe added as Laundry Manager</p>
						</div>
						<div class="text-sm text-gray-400">1 day ago</div>
					</div>
				</div>
			</div>
			<div class="px-6 py-4 border-t border-gray-200">
				<a href="/clients" class="text-sm text-indigo-600 hover:text-indigo-900">View all clients →</a>
			</div>
		</div>
		
		{#if user.role === 'main_admin'}
			<!-- Admin-specific features -->
			<div class="mt-8 grid grid-cols-1 md:grid-cols-2 gap-6">
				<div class="bg-white rounded-lg shadow p-6">
					<h3 class="text-lg font-semibold text-gray-800 mb-4">System Health</h3>
					<div class="space-y-3">
						<div class="flex justify-between items-center">
							<span class="text-sm text-gray-600">Database Connection</span>
							<span class="text-sm font-medium text-green-600">✓ Connected</span>
						</div>
						<div class="flex justify-between items-center">
							<span class="text-sm text-gray-600">Active Users</span>
							<span class="text-sm font-medium text-gray-900">{stats.totalUsers} users</span>
						</div>
						<div class="flex justify-between items-center">
							<span class="text-sm text-gray-600">System Status</span>
							<span class="text-sm font-medium text-green-600">All systems operational</span>
						</div>
					</div>
				</div>
				
				<div class="bg-white rounded-lg shadow p-6">
					<h3 class="text-lg font-semibold text-gray-800 mb-4">Quick Stats</h3>
					<div class="space-y-3">
						<div class="flex justify-between items-center">
							<span class="text-sm text-gray-600">Average Order Value</span>
							<span class="text-sm font-medium text-gray-900">$29.35</span>
						</div>
						<div class="flex justify-between items-center">
							<span class="text-sm text-gray-600">Processing Time</span>
							<span class="text-sm font-medium text-gray-900">2.5 hours avg</span>
						</div>
						<div class="flex justify-between items-center">
							<span class="text-sm text-gray-600">Customer Satisfaction</span>
							<span class="text-sm font-medium text-green-600">98%</span>
						</div>
					</div>
				</div>
			</div>
		{/if}
	{/if}
</div>
