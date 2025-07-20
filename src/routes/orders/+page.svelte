<script lang="ts">
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';

	// Type definitions
	interface User {
		email: string;
		role: string;
	}

	interface RegularItem {
		id: number;
		itemId: number | string;
		itemName: string;
		category: string;
		quantity: number;
		unitPrice: number;
		total: number;
	}

	interface SpecialItem {
		id: number;
		description: string;
		category: string;
		categoryName?: string;
		trackingCode?: string;
		timestamp?: string;
		photos?: any[];
	}

	interface Photo {
		id: number;
		url: string;
		timestamp: string;
	}

	interface PickedDataEntry {
		id: number;
		pickingId: string;
		pickerName: string;
		hotel: string;
		hotelId: string;
		date: string;
		time: string;
		staffName: string;
		staffRole: string;
		signature: string;
		notes: string;
		deliveryStatus?: string;
		regularItems: RegularItem[];
		specialItems: SpecialItem[];
		photos: string[];
		specialItemPhotos: Record<number, any[]>;
		totalItems: number;
		totalValue?: number;
		submittedAt: string;
		status?: string;
	}

	let user: User | null = null;
	let activeTab = 'picking';
	let pickedDataList: {
		id: number;
		pickingId: string;
		pickerName: string;
		hotel: string;
		hotelId: string;
		date: string;
		time: string;
		staffName: string;
		staffRole: string;
		signature: string;
		notes: string;
		deliveryStatus: string;
		regularItems: {
			id: number;
			itemId: number;
			itemName: string;
			category: string;
			quantity: number;
			unitPrice: number;
			total: number;
		}[];
		specialItems: {
			id: number;
			description: string;
			category: string;
			photos: any[];
		}[];
		photos: string[];
		specialItemPhotos: Record<number, any[]>;
		totalItems: number;
		submittedAt: string;
	}[] = [
		// Sample delivery orders
		{
			id: 1,
			pickingId: 'PICK-20250119-143022-A1B',
			pickerName: 'setya.ax2@gmail.com',
			hotel: 'Grand Hotel Jakarta',
			hotelId: 'hotel1',
			date: '2025-01-19',
			time: '14:30',
			staffName: 'Maria Santos',
			staffRole: 'Housekeeping Manager',
			signature: 'Maria S.',
			notes: 'VIP guest checkout - handle with care',
			deliveryStatus: 'ready_workshop',
			regularItems: [
				{ id: 1, itemId: 1, itemName: 'Bed Sheets', category: 'Bedding', quantity: 8, unitPrice: 15000, total: 120000 },
				{ id: 2, itemId: 3, itemName: 'Towels', category: 'Bathroom', quantity: 12, unitPrice: 8000, total: 96000 },
				{ id: 3, itemId: 4, itemName: 'Bathrobes', category: 'Bathroom', quantity: 4, unitPrice: 25000, total: 100000 }
			],
			specialItems: [
				{ id: 1, description: 'Presidential Suite Curtains', category: 'delicate', photos: [] }
			],
			photos: ['photo1.jpg', 'photo2.jpg'],
			specialItemPhotos: { 1: ['special1.jpg'] },
			totalItems: 25,
			submittedAt: '2025-01-19 14:35:22'
		},
		{
			id: 2,
			pickingId: 'PICK-20250119-101545-B2C',
			pickerName: 'setya.ax2@gmail.com',
			hotel: 'Paradise Resort Bali',
			hotelId: 'hotel2',
			date: '2025-01-19',
			time: '10:15',
			staffName: 'Ahmad Wijaya',
			staffRole: 'Laundry Supervisor',
			signature: 'A. Wijaya',
			notes: 'Restaurant linens from breakfast service',
			deliveryStatus: 'in_process',
			regularItems: [
				{ id: 1, itemId: 5, itemName: 'Tablecloths', category: 'Restaurant', quantity: 15, unitPrice: 20000, total: 300000 },
				{ id: 2, itemId: 6, itemName: 'Napkins', category: 'Restaurant', quantity: 80, unitPrice: 2000, total: 160000 }
			],
			specialItems: [],
			photos: ['photo3.jpg'],
			specialItemPhotos: {},
			totalItems: 95,
			submittedAt: '2025-01-19 10:20:15'
		},
		{
			id: 3,
			pickingId: 'PICK-20250118-165030-C3D',
			pickerName: 'setya.ax2@gmail.com',
			hotel: 'Luxury Beach Resort',
			hotelId: 'hotel3',
			date: '2025-01-18',
			time: '16:50',
			staffName: 'Sarah Johnson',
			staffRole: 'Front Office Manager',
			signature: 'S. Johnson',
			notes: 'End of day collection from spa and wellness center',
			deliveryStatus: 'on_logistic_car',
			regularItems: [
				{ id: 1, itemId: 3, itemName: 'Towels', category: 'Bathroom', quantity: 25, unitPrice: 8000, total: 200000 },
				{ id: 2, itemId: 2, itemName: 'Pillowcases', category: 'Bedding', quantity: 16, unitPrice: 5000, total: 80000 }
			],
			specialItems: [
				{ id: 1, description: 'Silk spa robes', category: 'delicate', photos: [] },
				{ id: 2, description: 'Meditation cushion covers', category: 'custom', photos: [] }
			],
			photos: ['photo4.jpg', 'photo5.jpg'],
			specialItemPhotos: { 1: ['spa1.jpg'], 2: ['meditation1.jpg'] },
			totalItems: 43,
			submittedAt: '2025-01-18 16:55:30'
		},
		{
			id: 4,
			pickingId: 'PICK-20250118-090012-D4E',
			pickerName: 'setya.ax2@gmail.com',
			hotel: 'City Business Hotel',
			hotelId: 'hotel4',
			date: '2025-01-18',
			time: '09:00',
			staffName: 'Robert Chen',
			staffRole: 'Operations Manager',
			signature: 'R. Chen',
			notes: 'Conference room setup materials',
			deliveryStatus: 'sent',
			regularItems: [
				{ id: 1, itemId: 5, itemName: 'Tablecloths', category: 'Restaurant', quantity: 8, unitPrice: 20000, total: 160000 },
				{ id: 2, itemId: 1, itemName: 'Bed Sheets', category: 'Bedding', quantity: 12, unitPrice: 15000, total: 180000 }
			],
			specialItems: [
				{ id: 1, description: 'Executive meeting room drapes', category: 'priority', photos: [] }
			],
			photos: ['photo6.jpg'],
			specialItemPhotos: { 1: ['meeting1.jpg'] },
			totalItems: 21,
			submittedAt: '2025-01-18 09:05:12'
		},
		{
			id: 5,
			pickingId: 'PICK-20250117-195522-E5F',
			pickerName: 'setya.ax2@gmail.com',
			hotel: 'Mountain View Lodge',
			hotelId: 'hotel5',
			date: '2025-01-17',
			time: '19:55',
			staffName: 'Lisa Thompson',
			staffRole: 'Guest Services',
			signature: 'L. Thompson',
			notes: 'Late evening pickup - security escort required',
			deliveryStatus: 'in_process',
			regularItems: [
				{ id: 1, itemId: 7, itemName: 'Curtains', category: 'Room', quantity: 6, unitPrice: 30000, total: 180000 },
				{ id: 2, itemId: 8, itemName: 'Blankets', category: 'Bedding', quantity: 10, unitPrice: 18000, total: 180000 }
			],
			specialItems: [
				{ id: 1, description: 'Antique tapestry wall hangings', category: 'delicate', photos: [] }
			],
			photos: ['photo7.jpg', 'photo8.jpg'],
			specialItemPhotos: { 1: ['antique1.jpg', 'antique2.jpg'] },
			totalItems: 17,
			submittedAt: '2025-01-17 20:00:22'
		}
	];
	let selectedDateFilter = '';
	let selectedHotelFilter = ''; // 'picking' or 'delivery'
	
	// Enhanced filters for picked data
	let dateRangeStart = '';
	let dateRangeEnd = '';
	let timeRangeStart = '';
	let timeRangeEnd = '';
	let selectedStaffFilter = '';
	
	// Delivery filters
	let deliveryDateFilter = '';
	let deliveryTimeRangeStart = '';
	let deliveryTimeRangeEnd = '';
	let deliveryHotelFilter = '';
	let selectedDeliveryOrders: number[] = []; // Array of selected order IDs for delivery
	
	// Get unique staff members from picked data
	$: availableStaff = [...new Set(pickedDataList.map(entry => entry.staffName).filter(name => name && name.trim()))]
		.sort((a, b) => a.toLowerCase().localeCompare(b.toLowerCase()));

	// Filter picked data for delivery (orders ready to be delivered)
	$: deliveryAvailableOrders = pickedDataList.filter(entry => {
		// Date filter
		let dateMatch = true;
		if (deliveryDateFilter) {
			dateMatch = entry.date === deliveryDateFilter;
		}
		
		// Hotel filter
		const hotelMatch = !deliveryHotelFilter || entry.hotelId === deliveryHotelFilter;
		
		// Time range filter
		let timeMatch = true;
		if (deliveryTimeRangeStart && deliveryTimeRangeEnd) {
			const entryTime = entry.time;
			timeMatch = entryTime >= deliveryTimeRangeStart && entryTime <= deliveryTimeRangeEnd;
		}
		
		return dateMatch && hotelMatch && timeMatch;
	});

	// Group filtered orders by status
	$: groupedByStatus = deliveryAvailableOrders.reduce((groups: Record<string, typeof deliveryAvailableOrders>, order) => {
		const status = order.deliveryStatus || 'in_process';
		if (!groups[status]) {
			groups[status] = [];
		}
		groups[status].push(order);
		return groups;
	}, {} as Record<string, typeof deliveryAvailableOrders>);

	// Get unique dates from picked data for delivery filter
	$: availableDeliveryDates = [...new Set(pickedDataList.map(entry => entry.date))]
		.sort().reverse(); // Most recent first

	// Picking state
	let selectedItems: RegularItem[] = [];
	let pickingNotes = '';
	let hotelStaffSignature = '';
	let hotelStaffName = '';
	let hotelStaffRole = '';
	let pickupDate = '';
	let pickupTime = '';
	let selectedHotel = '';
	let staffConfirmation = '';
	let hotelConfirmed = false;
	let currentPickingId = '';
	// Picker name is now displayed directly from user.email
	let specialItems: SpecialItem[] = [];
	let specialItemDescription = '';
	let specialItemCategory = '';
	
	// Special item categories
	const specialCategories = [
		{ id: 'manager', name: 'Manager/Executive Items' },
		{ id: 'vip', name: 'VIP Guest Items' },
		{ id: 'priority', name: 'Priority/Urgent Items' },
		{ id: 'delicate', name: 'Delicate/Special Care' },
		{ id: 'custom', name: 'Custom Request' }
	];
	
	// Available hotels list
	const availableHotels = [
		{ id: 'hotel1', name: 'Grand Hotel Jakarta', address: 'Jl. MH Thamrin No.1, Jakarta' },
		{ id: 'hotel2', name: 'Paradise Resort Bali', address: 'Jl. Pantai Kuta, Bali' },
		{ id: 'hotel3', name: 'Luxury Beach Resort', address: 'Jl. Pantai Sanur, Bali' },
		{ id: 'hotel4', name: 'City Business Hotel', address: 'Jl. Sudirman No.15, Jakarta' },
		{ id: 'hotel5', name: 'Mountain View Lodge', address: 'Jl. Raya Puncak, Bogor' },
		{ id: 'royal-surabaya', name: 'Royal Hotel Surabaya', address: 'Jl. Pemuda No.45, Surabaya' },
		{ id: 'golden-bandung', name: 'Golden Palace Bandung', address: 'Jl. Asia Afrika No.20, Bandung' },
		{ id: 'ocean-lombok', name: 'Ocean View Lombok', address: 'Jl. Pantai Senggigi, Lombok' }
	];
	
	// Common hotel staff names (can be expanded based on actual hotel data)
	const commonStaffNames = [
		'Maria Garcia', 'John Smith', 'Sarah Johnson', 'David Wilson', 'Lisa Chen',
		'Ahmed Hassan', 'Priya Sharma', 'Carlos Rodriguez', 'Anna Kowalski', 'Yuki Tanaka',
		'Sophie Martin', 'Hassan Ali', 'Elena Popov', 'Roberto Silva', 'Mei Wong'
	];
	
	// Common hotel staff roles
	const hotelStaffRoles = [
		'Housekeeping Manager', 'Housekeeping Supervisor', 'Room Attendant',
		'Front Desk Manager', 'Guest Services Manager', 'Maintenance Supervisor',
		'Laundry Supervisor', 'Assistant Manager', 'Duty Manager', 'Concierge'
	];
	
	// Set current date and time on component mount
	function setCurrentDateTime() {
		const now = new Date();
		pickupDate = now.toISOString().split('T')[0]; // YYYY-MM-DD format
		pickupTime = now.toTimeString().split(' ')[0].substring(0, 5); // HH:MM format
		currentPickingId = generatePickingId(); // Generate new picking ID
	}
	
	// Validate hotel confirmation
	function validateHotelConfirmation() {
		if (!selectedHotel || !staffConfirmation) {
			hotelConfirmed = false;
			return;
		}
		
		const selectedHotelData = availableHotels.find(h => h.id === selectedHotel);
		if (!selectedHotelData) {
			hotelConfirmed = false;
			return;
		}
		
		// Check if staff confirmation matches hotel name (case insensitive)
		const hotelName = selectedHotelData.name.toLowerCase();
		const confirmation = staffConfirmation.toLowerCase().trim();
		
		// Allow partial matches or exact matches
		hotelConfirmed = hotelName.includes(confirmation) || confirmation.includes(hotelName.split(' ')[0]);
	}
	
	// Generate unique tracking code for special items
	function generateTrackingCode() {
		const prefix = selectedHotel ? availableHotels.find(h => h.id === selectedHotel)?.name.substring(0, 2).toUpperCase() : 'SP';
		const timestamp = Date.now().toString().slice(-6);
		const random = Math.random().toString(36).substring(2, 5).toUpperCase();
		return `${prefix}-${timestamp}-${random}`;
	}
	
	// Generate unique picking ID
	function generatePickingId() {
		const prefix = 'PICK';
		const date = new Date();
		const dateStr = date.toISOString().slice(0, 10).replace(/-/g, ''); // YYYYMMDD
		const timeStr = date.toTimeString().slice(0, 8).replace(/:/g, ''); // HHMMSS
		const random = Math.random().toString(36).substring(2, 5).toUpperCase();
		return `${prefix}-${dateStr}-${timeStr}-${random}`;
	}
	
	// Add special item
	function addSpecialItem() {
		if (!specialItemDescription.trim() || !specialItemCategory) {
			alert('Please fill in description and category for special item');
			return;
		}
		
		const itemId = Date.now();
		const newSpecialItem = {
			id: itemId,
			description: specialItemDescription.trim(),
			category: specialItemCategory,
			categoryName: specialCategories.find(c => c.id === specialItemCategory)?.name,
			trackingCode: generateTrackingCode(),
			timestamp: new Date().toLocaleString()
		};
		
		specialItems = [...specialItems, newSpecialItem];
		specialItemPhotos[itemId] = []; // Initialize empty photo array for this special item
		specialItemDescription = '';
		specialItemCategory = '';
	}
	
	// Remove special item
	function removeSpecialItem(itemId: number) {
		specialItems = specialItems.filter(item => item.id !== itemId);
		delete specialItemPhotos[itemId]; // Remove photos for this special item
	}
	let pickingPhotos: Photo[] = [];
	let specialItemPhotos: Record<number, Photo[]> = {}; // Object to store photos per special item ID

	// Camera state
	let videoElement: HTMLVideoElement | null = null;
	let canvasElement: HTMLCanvasElement | null = null;
	let cameraStream: MediaStream | null = null;
	let isCameraActive = false;
	let currentPhotoTarget: string | number | null = null; // 'regular' or special item ID

	// Available laundry items (this would normally come from database)
	let availableItems = [
		{ id: 1, name: 'Bed Sheets', category: 'Bedding', unitPrice: 15000 },
		{ id: 2, name: 'Pillowcases', category: 'Bedding', unitPrice: 5000 },
		{ id: 3, name: 'Towels', category: 'Bathroom', unitPrice: 8000 },
		{ id: 4, name: 'Bathrobes', category: 'Bathroom', unitPrice: 25000 },
		{ id: 5, name: 'Tablecloths', category: 'Restaurant', unitPrice: 20000 },
		{ id: 6, name: 'Napkins', category: 'Restaurant', unitPrice: 2000 },
		{ id: 7, name: 'Curtains', category: 'Room', unitPrice: 30000 },
		{ id: 8, name: 'Blankets', category: 'Bedding', unitPrice: 18000 }
	];

	// Delivery now uses dynamic picking orders from pickedDataList

	onMount(async () => {
		try {
			// Check if user is authenticated
			// User data comes from server-side authentication
			if (!$page?.data?.user) {
				console.log('No user found, redirecting to login');
				goto('/');
				return;
			}
			
			user = $page.data.user;
			console.log('User authenticated:', user.email);
			
			// Picker name will be displayed directly from user.email
			
			// Set current date and time automatically
			setCurrentDateTime();
		} catch (error) {
			console.error('Error in onMount:', error);
			goto('/');
		}
	});

	function addItem() {
		selectedItems = [...selectedItems, {
			id: Date.now(),
			itemId: '',
			itemName: '',
			category: '',
			quantity: 1,
			unitPrice: 0,
			total: 0
		}];
	}

	function removeItem(index: number) {
		selectedItems = selectedItems.filter((_, i) => i !== index);
	}

	function updateItem(index: number, field: keyof RegularItem, value: any) {
		selectedItems[index][field] = value;
		
		if (field === 'itemId') {
			const item = availableItems.find(i => i.id == value);
			if (item) {
				selectedItems[index].itemName = item.name;
				selectedItems[index].category = item.category;
				selectedItems[index].unitPrice = item.unitPrice;
				selectedItems[index].total = selectedItems[index].quantity * item.unitPrice;
			}
		}
		
		if (field === 'quantity' || field === 'unitPrice') {
			selectedItems[index].total = selectedItems[index].quantity * selectedItems[index].unitPrice;
		}
		
		selectedItems = [...selectedItems];
	}

	function calculateTotal() {
		return selectedItems.reduce((sum, item) => sum + item.total, 0);
	}

	function formatCurrency(amount) {
		return new Intl.NumberFormat('id-ID', {
			style: 'currency',
			currency: 'IDR'
		}).format(amount);
	}

	async function startCamera() {
		try {
			if (cameraStream) {
				stopCamera();
			}
			cameraStream = await navigator.mediaDevices.getUserMedia({ 
				video: { 
					width: { ideal: 1280 },
					height: { ideal: 720 }
				} 
			});
			if (videoElement) {
				videoElement.srcObject = cameraStream;
				videoElement.play();
				isCameraActive = true;
			}
		} catch (error) {
			console.error('Error accessing camera:', error);
			alert('Unable to access camera. Please check permissions.');
		}
	}

	function stopCamera() {
		if (cameraStream) {
			cameraStream.getTracks().forEach(track => track.stop());
			cameraStream = null;
			isCameraActive = false;
		}
		if (videoElement) {
			videoElement.srcObject = null;
		}
	}

	function takePhoto() {
		if (videoElement && canvasElement && cameraStream) {
			const context = canvasElement.getContext('2d');
			canvasElement.width = videoElement.videoWidth;
			canvasElement.height = videoElement.videoHeight;
			context.drawImage(videoElement, 0, 0);
			
			const imageData = canvasElement.toDataURL('image/jpeg', 0.8);
			const photo = {
				id: Date.now(),
				url: imageData,
				timestamp: new Date().toLocaleString()
			};
			
			if (currentPhotoTarget === 'regular') {
				pickingPhotos = [...pickingPhotos, photo];
			} else if (currentPhotoTarget && specialItemPhotos[currentPhotoTarget]) {
				specialItemPhotos[currentPhotoTarget] = [...specialItemPhotos[currentPhotoTarget], photo];
				specialItemPhotos = { ...specialItemPhotos }; // Trigger reactivity
			}
		}
	}

	function takePhotoForSpecialItem(itemId) {
		currentPhotoTarget = itemId;
		if (!isCameraActive) {
			startCamera().then(() => {
				// Camera will be ready, user can then click take photo
			});
		}
	}

	function takePhotoForRegularItems() {
		currentPhotoTarget = 'regular';
		if (!isCameraActive) {
			startCamera().then(() => {
				// Camera will be ready, user can then click take photo
			});
		}
	}

	function removePhoto(photoId) {
		pickingPhotos = pickingPhotos.filter(p => p.id !== photoId);
	}

	function removeSpecialItemPhoto(itemId, photoId) {
		if (specialItemPhotos[itemId]) {
			specialItemPhotos[itemId] = specialItemPhotos[itemId].filter(p => p.id !== photoId);
			specialItemPhotos = { ...specialItemPhotos }; // Trigger reactivity
		}
	}

	function submitPickingOrder() {
		if (selectedItems.length === 0) {
			alert('Please add at least one item');
			return;
		}
		
		if (!user?.email) {
			alert('User not logged in');
			return;
		}
		
		if (!hotelStaffName) {
			alert('Please select hotel staff name');
			return;
		}
		
		if (!hotelStaffRole) {
			alert('Please select hotel staff role');
			return;
		}

		// Create picked data entry
		const pickedEntry = {
			id: Date.now(),
			pickingId: currentPickingId,
			pickerName: user?.email || 'Unknown',
			hotel: availableHotels.find(h => h.id === selectedHotel)?.name || 'Unknown Hotel',
			hotelId: selectedHotel,
			date: pickupDate,
			time: pickupTime,
			staffName: hotelStaffName,
			staffRole: hotelStaffRole,
			signature: hotelStaffSignature,
			notes: pickingNotes,
			regularItems: [...selectedItems],
			specialItems: [...specialItems],
			photos: [...pickingPhotos], // Photos for regular items (all items in one box)
			specialItemPhotos: { ...specialItemPhotos }, // Individual photos per special item
			totalItems: selectedItems.reduce((sum, item) => sum + item.quantity, 0),
			totalValue: calculateTotal(),
			submittedAt: new Date().toLocaleString(),
			status: 'picked'
		};

		// Add to picked data list
		pickedDataList = [pickedEntry, ...pickedDataList];

		console.log('Submitting picking order:', pickedEntry);
		alert('Picking order submitted successfully!');
		
		// Reset form
		selectedItems = [];
		pickingNotes = '';
		hotelStaffSignature = '';
		hotelStaffName = '';
		hotelStaffRole = '';
		selectedHotel = '';
		staffConfirmation = '';
		hotelConfirmed = false;
		// Picker name is now always user's email (no need to reset)
		specialItems = [];
		specialItemDescription = '';
		specialItemCategory = '';
		// Reset date/time and set to current (this will also generate new picking ID)
		setCurrentDateTime();
		pickingPhotos = [];
		specialItemPhotos = {};
		currentPhotoTarget = null;
		stopCamera();
	}

	// Enhanced filter picked data
	$: filteredPickedData = pickedDataList.filter(entry => {
		// Date range filter
		let dateMatch = true;
		if (dateRangeStart && dateRangeEnd) {
			const entryDate = new Date(entry.date);
			const startDate = new Date(dateRangeStart);
			const endDate = new Date(dateRangeEnd);
			dateMatch = entryDate >= startDate && entryDate <= endDate;
		} else if (selectedDateFilter) {
			dateMatch = entry.date === selectedDateFilter;
		}
		
		// Hotel filter
		const hotelMatch = !selectedHotelFilter || entry.hotelId === selectedHotelFilter;
		
		// Time range filter
		let timeMatch = true;
		if (timeRangeStart && timeRangeEnd) {
			const entryTime = entry.time;
			timeMatch = entryTime >= timeRangeStart && entryTime <= timeRangeEnd;
		}
		
		// Staff filter
		const staffMatch = !selectedStaffFilter || entry.staffName === selectedStaffFilter;
		
		return dateMatch && hotelMatch && timeMatch && staffMatch;
	});

	// Group filtered data by hotel and date
	$: groupedPickedData = filteredPickedData.reduce((groups, entry) => {
		const key = `${entry.hotel}_${entry.date}`;
		if (!groups[key]) {
			groups[key] = {
				hotel: entry.hotel,
				date: entry.date,
				entries: []
			};
		}
		groups[key].entries.push(entry);
		return groups;
	}, {});

	// Delivery functions
	function toggleOrderSelection(orderId) {
		if (selectedDeliveryOrders.includes(orderId)) {
			selectedDeliveryOrders = selectedDeliveryOrders.filter(id => id !== orderId);
		} else {
			selectedDeliveryOrders = [...selectedDeliveryOrders, orderId];
		}
	}

	function selectAllFilteredOrders() {
		selectedDeliveryOrders = deliveryAvailableOrders.map(order => order.id);
	}

	function clearOrderSelection() {
		selectedDeliveryOrders = [];
	}

	function submitSelectedOrdersForDelivery() {
		if (selectedDeliveryOrders.length === 0) {
			alert('Please select at least one order for delivery');
			return;
		}

		// Here you would update delivery status in database
		console.log('Delivering orders:', selectedDeliveryOrders);
		alert(`${selectedDeliveryOrders.length} order(s) marked as delivered!`);
		
		// In a real app, you would update the database status
		// For now, we'll just clear the selection
		selectedDeliveryOrders = [];
	}

	function clearDeliveryFilters() {
		deliveryDateFilter = '';
		deliveryTimeRangeStart = '';
		deliveryTimeRangeEnd = '';
		deliveryHotelFilter = '';
		selectedDeliveryOrders = [];
	}

	// Clear all filters
	function clearAllFilters() {
		selectedDateFilter = '';
		selectedHotelFilter = '';
		dateRangeStart = '';
		dateRangeEnd = '';
		timeRangeStart = '';
		timeRangeEnd = '';
		selectedStaffFilter = '';
	}

	// Delivery status options
	const deliveryStatuses = [
		{ value: 'in_process', label: 'In Process', color: 'yellow', icon: '⏳' },
		{ value: 'ready_to_send', label: 'Ready to Send', color: 'blue', icon: '📦' },
		{ value: 'send_in_car', label: 'Send in Car', color: 'purple', icon: '🚛' },
		{ value: 'received', label: 'Received', color: 'green', icon: '✅' }
	];
</script>

<svelte:head>
	<title>Orders - Picking & Delivery - PROCUCI</title>
</svelte:head>

<div class="min-h-screen bg-gray-50">
	{#if user}
		<div class="max-w-4xl mx-auto py-4 px-3 sm:py-8 sm:px-6 lg:px-8">
			<!-- Header -->
			<div class="mb-8">
				<h1 class="text-3xl font-bold text-gray-900">Orders Management</h1>
				<p class="mt-2 text-sm text-gray-600">
					Handle picking and delivery operations for hotel laundry services
				</p>
			</div>

			<!-- Tab Navigation -->
			<div class="border-b border-gray-200 mb-6">
				<nav class="-mb-px flex space-x-8 overflow-x-auto">
					<button
						class="py-2 px-1 border-b-2 font-medium text-sm whitespace-nowrap {activeTab === 'picking' ? 'border-blue-500 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'}"
						on:click={() => activeTab = 'picking'}
					>
						📋 Picking
					</button>
					<button
						class="py-2 px-1 border-b-2 font-medium text-sm whitespace-nowrap {activeTab === 'picked-data' ? 'border-green-500 text-green-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'}"
						on:click={() => activeTab = 'picked-data'}
					>
						📊 Picked Data
					</button>
					<button
						class="py-2 px-1 border-b-2 font-medium text-sm whitespace-nowrap {activeTab === 'delivery' ? 'border-purple-500 text-purple-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'}"
						on:click={() => activeTab = 'delivery'}
					>
						🚚 Delivery
					</button>
				</nav>
			</div>

			<!-- Picking Tab -->
			{#if activeTab === 'picking'}
				<div class="bg-white shadow-sm rounded-xl">
					<div class="p-4 sm:p-6">
						<div class="mb-6">
							<h2 class="text-xl sm:text-2xl font-bold text-gray-900 mb-3">Laundry Item Picking</h2>
							
							<!-- Picking ID and Picker Name Section -->
							<div class="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-xl p-4 border border-blue-200 mb-4">
								<div class="flex flex-col sm:flex-row sm:items-center gap-4">
									<!-- Picking ID Display -->
									{#if currentPickingId}
										<div class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-gradient-to-r from-blue-100 to-indigo-100 text-blue-800 border border-blue-300">
											<svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
												<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
											</svg>
											<strong>Picking ID:</strong> {currentPickingId}
										</div>
									{/if}
									
									<!-- Picker Name Display -->
									<div class="flex-1">
										<label class="block text-sm font-semibold text-blue-800 mb-2">
											Picker Name *
											<span class="text-xs text-green-600 font-normal">(From logged-in user)</span>
										</label>
										<div class="w-full px-3 py-2 border border-blue-300 rounded-lg shadow-sm text-sm bg-gray-50 text-gray-800 font-medium">
											{user?.email || 'Not logged in'}
										</div>
									</div>
								</div>
							</div>
						</div>
						
						<!-- Hotel Selection & Confirmation -->
						<div class="mb-6 bg-gradient-to-r from-orange-50 to-amber-50 rounded-xl p-4 border border-orange-200">
							<h3 class="text-lg font-semibold text-gray-900 mb-4 flex items-center">
								<svg class="w-5 h-5 mr-2 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path>
								</svg>
								Hotel Pickup Location
								{#if hotelConfirmed}
									<span class="ml-2 text-xs bg-green-100 text-green-600 px-2 py-1 rounded-full">✓ Confirmed</span>
								{:else if selectedHotel && staffConfirmation}
									<span class="ml-2 text-xs bg-red-100 text-red-600 px-2 py-1 rounded-full">⚠ Not Matched</span>
								{/if}
							</h3>
							
							<div class="space-y-4">
								<!-- Hotel Selection -->
								<div>
									<label for="hotel-select" class="block text-sm font-semibold text-gray-700 mb-2">Select Hotel for Pickup</label>
									<select 
										id="hotel-select"
										bind:value={selectedHotel}
										on:change={validateHotelConfirmation}
										class="w-full px-3 py-3 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-orange-500 focus:border-orange-500 text-base"
										required
									>
										<option value="">Choose a hotel...</option>
										{#each availableHotels as hotel}
											<option value={hotel.id}>{hotel.name} - {hotel.address}</option>
										{/each}
									</select>
								</div>
								
								<!-- Staff Confirmation -->
								{#if selectedHotel}
									<div class="bg-white rounded-lg p-4 border border-orange-300">
										<label for="staff-confirmation" class="block text-sm font-semibold text-gray-700 mb-2">
											Staff Confirmation Required
										</label>
										<p class="text-sm text-gray-600 mb-3">
											Please type the hotel name to confirm you are at the correct location:
											<span class="font-bold text-orange-600">
								 				{availableHotels.find(h => h.id === selectedHotel)?.name}
											</span>
										</p>
										<input 
											id="staff-confirmation"
											type="text" 
											bind:value={staffConfirmation}
											on:input={validateHotelConfirmation}
											placeholder="Type hotel name to confirm location..."
											class="w-full px-3 py-3 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-orange-500 focus:border-orange-500 text-base {hotelConfirmed ? 'border-green-500 bg-green-50' : staffConfirmation ? 'border-red-500 bg-red-50' : ''}"
											required
										>
										{#if hotelConfirmed}
											<p class="text-sm text-green-600 mt-2 flex items-center">
												<svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
													<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
												</svg>
												✓ Hotel location confirmed
											</p>
										{:else if staffConfirmation}
											<p class="text-sm text-red-600 mt-2 flex items-center">
												<svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
													<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.732-.833-2.464 0L3.34 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
												</svg>
												Hotel name doesn't match. Please verify you're at the correct location.
											</p>
										{/if}
									</div>
								{/if}
							</div>
						</div>
						
						<!-- Pickup Date & Time - Auto-filled from device -->
						<div class="mb-6 bg-gradient-to-r from-blue-50 to-indigo-50 rounded-xl p-4">
							<h3 class="text-lg font-semibold text-gray-900 mb-4 flex items-center">
								<svg class="w-5 h-5 mr-2 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
								</svg>
								Pickup Information
								<span class="ml-2 text-xs bg-blue-100 text-blue-600 px-2 py-1 rounded-full">Auto-filled</span>
							</h3>
							<div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
								<!-- Pickup Date -->
								<div>
									<label for="pickup-date" class="block text-sm font-medium text-gray-700 mb-2">Pickup Date</label>
									<input 
										id="pickup-date"
										type="date" 
										bind:value={pickupDate}
										class="w-full px-3 py-3 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-base bg-blue-50"
										readonly
									>
									<p class="text-xs text-gray-500 mt-1">Automatically set to today's date</p>
								</div>
								<!-- Pickup Time -->
								<div>
									<label for="pickup-time" class="block text-sm font-medium text-gray-700 mb-2">Pickup Time</label>
									<input 
										id="pickup-time"
										type="time" 
										bind:value={pickupTime}
										class="w-full px-3 py-3 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-base"
									>
									<p class="text-xs text-gray-500 mt-1">Automatically set to current time (editable)</p>
								</div>
							</div>
						</div>
						
						<!-- Item Selection -->
						<div class="mb-6">
							<div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-3 mb-4">
								<h3 class="text-lg font-semibold text-gray-900 flex items-center">
									<svg class="w-5 h-5 mr-2 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"></path>
									</svg>
									Select Items to Pick
								</h3>
								<button
									class="bg-gradient-to-r from-blue-600 to-blue-700 text-white px-6 py-3 rounded-xl text-sm font-medium hover:from-blue-700 hover:to-blue-800 shadow-lg transform hover:scale-105 transition-all duration-200"
									on:click={addItem}
								>
									<svg class="w-4 h-4 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
									</svg>
									Add Item
								</button>
							</div>

							{#if selectedItems.length === 0}
								<div class="text-center py-12 text-gray-500 bg-gray-50 rounded-xl border-2 border-dashed border-gray-300">
									<svg class="w-16 h-16 mx-auto text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"></path>
									</svg>
									<p class="text-lg font-medium mb-2">No items selected</p>
									<p class="text-sm">Click "Add Item" to start adding laundry items</p>
								</div>
							{:else}
								<div class="space-y-4">
									{#each selectedItems as item, index}
										<div class="bg-white border-2 border-gray-200 rounded-xl p-4 shadow-sm hover:shadow-md transition-shadow">
											<!-- Mobile-first design with stacked layout -->
											<div class="space-y-4">
												<!-- Item Type - Full width on mobile -->
												<div>
													<label for="item-type-{index}" class="block text-sm font-semibold text-gray-700 mb-2">Item Type</label>
													<select 
														id="item-type-{index}"
														value={item.itemId}
														on:change={(e) => updateItem(index, 'itemId', e.target.value)}
														class="w-full px-3 py-3 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-base"
													>
														<option value="">Select Item</option>
														{#each availableItems as availableItem}
															<option value={availableItem.id}>
																{availableItem.name} ({availableItem.category})
															</option>
														{/each}
													</select>
												</div>
												
												<!-- Quantity and Price in a row on mobile -->
												<div class="grid grid-cols-2 gap-3">
													<div>
														<label for="quantity-{index}" class="block text-sm font-semibold text-gray-700 mb-2">Quantity</label>
														<input 
															id="quantity-{index}"
															type="number" 
															value={item.quantity}
															on:input={(e) => updateItem(index, 'quantity', parseInt(e.target.value) || 0)}
															min="1" 
															class="w-full px-3 py-3 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-base"
														>
													</div>
													<div>
														<label for="unit-price-{index}" class="block text-sm font-semibold text-gray-700 mb-2">Unit Price (IDR)</label>
														<input 
															id="unit-price-{index}"
															type="number" 
															value={item.unitPrice}
															on:input={(e) => updateItem(index, 'unitPrice', parseInt(e.target.value) || 0)}
															step="1000" 
															class="w-full px-3 py-3 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-base"
														>
													</div>
												</div>
												
												<!-- Total and Remove button -->
												<div class="flex justify-between items-center pt-2 border-t border-gray-200">
													<div>
														<span class="text-sm text-gray-600">Total:</span>
														<span class="text-lg font-bold text-blue-600 ml-2">
															{formatCurrency(item.total)}
														</span>
													</div>
													<button 
														class="bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded-lg text-sm font-medium shadow-md transform hover:scale-105 transition-all duration-200"
														on:click={() => removeItem(index)}
													>
														<svg class="w-4 h-4 inline mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
															<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
														</svg>
														Remove
													</button>
												</div>
											</div>
										</div>
									{/each}
								</div>
														{/if}
						</div>
						
						<!-- Special Items Section -->
						<div class="mb-6">
							<div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-3 mb-4">
								<h3 class="text-lg font-semibold text-gray-900 flex items-center">
									<svg class="w-5 h-5 mr-2 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.196-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z"></path>
									</svg>
									Special Items (Manager/VIP)
									{#if specialItems.length > 0}
										<span class="ml-2 text-xs bg-purple-100 text-purple-600 px-2 py-1 rounded-full">{specialItems.length} item{specialItems.length !== 1 ? 's' : ''}</span>
									{/if}
								</h3>
							</div>
							
							<!-- Add Special Item Form -->
							<div class="bg-gradient-to-r from-purple-50 to-indigo-50 rounded-xl p-4 border border-purple-200 mb-4">
								<h4 class="text-md font-semibold text-gray-900 mb-3">Add Special Item</h4>
								<div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
									<div>
										<label for="special-category" class="block text-sm font-semibold text-gray-700 mb-2">Category</label>
										<select
											id="special-category"
											bind:value={specialItemCategory}
											class="w-full px-3 py-3 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-purple-500 focus:border-purple-500 text-base"
										>
											<option value="">Select category...</option>
											{#each specialCategories as category}
												<option value={category.id}>{category.name}</option>
											{/each}
										</select>
									</div>
									<div>
										<label for="special-description" class="block text-sm font-semibold text-gray-700 mb-2">Description</label>
										<input
											id="special-description"
											type="text"
											bind:value={specialItemDescription}
											placeholder="e.g., CEO's white shirts, VIP guest's silk dress..."
											class="w-full px-3 py-3 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-purple-500 focus:border-purple-500 text-base"
										>
									</div>
								</div>
								<button
									on:click={addSpecialItem}
									class="bg-gradient-to-r from-purple-600 to-purple-700 hover:from-purple-700 hover:to-purple-800 text-white px-6 py-3 rounded-lg text-sm font-medium shadow-md transform hover:scale-105 transition-all duration-200"
									disabled={!specialItemCategory || !specialItemDescription.trim()}
								>
									<svg class="w-4 h-4 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
									</svg>
									Add Special Item
								</button>
							</div>
							
							<!-- Special Items List -->
							{#if specialItems.length === 0}
								<div class="text-center py-8 text-gray-500 bg-gray-50 rounded-xl border-2 border-dashed border-gray-300">
									<svg class="w-12 h-12 mx-auto text-gray-400 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.196-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z"></path>
									</svg>
									<p class="text-lg font-medium mb-2">No special items added</p>
									<p class="text-sm">Add manager, VIP, or special care items that need unique tracking codes</p>
								</div>
							{:else}
								<div class="space-y-3">
									{#each specialItems as item}
										<div class="bg-white border-2 border-purple-200 rounded-xl p-4 shadow-sm">
											<div class="flex justify-between items-start">
												<div class="flex-1">
													<div class="flex items-center gap-2 mb-2">
														<span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
															{item.categoryName}
														</span>
														<span class="text-xs text-gray-500">{item.timestamp}</span>
													</div>
													<p class="text-gray-900 font-medium mb-2">{item.description}</p>
													<div class="bg-purple-50 border border-purple-200 rounded-lg p-3 mb-3">
														<div class="flex items-center justify-between">
															<div>
																<p class="text-sm font-semibold text-purple-800">Tracking Code for Box Stamp:</p>
																<p class="text-lg font-mono font-bold text-purple-900">{item.trackingCode}</p>
															</div>
															<div class="text-right">
																<svg class="w-8 h-8 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
																	<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 20l4-16m2 16l4-16M6 9h14M4 15h14"></path>
																</svg>
															</div>
														</div>
													</div>
													
													<!-- Individual Photo Section for Special Item -->
													<div class="bg-gradient-to-r from-purple-50 to-indigo-50 border border-purple-200 rounded-lg p-3">
														<div class="flex items-center justify-between mb-2">
															<h5 class="text-sm font-semibold text-purple-800 flex items-center">
																<svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
																	<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z"></path>
																	<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z"></path>
																</svg>
																Item Photo ({specialItemPhotos[item.id]?.length || 0})
															</h5>
															<button
																on:click={() => takePhotoForSpecialItem(item.id)}
																class="bg-purple-600 hover:bg-purple-700 text-white px-3 py-1 rounded-lg text-xs font-medium shadow-sm transition-colors duration-200"
															>
																📷 Take Photo
															</button>
														</div>
														
														{#if specialItemPhotos[item.id]?.length > 0}
															<div class="grid grid-cols-2 gap-2">
																{#each specialItemPhotos[item.id] as photo}
																	<div class="relative group">
																		<img src={photo.url} alt="Special item {item.description}" class="w-full h-20 object-cover rounded border-2 border-purple-200 shadow-sm">
																		<button 
																			class="absolute -top-1 -right-1 bg-red-500 hover:bg-red-600 text-white rounded-full w-6 h-6 text-xs font-bold shadow-lg transform hover:scale-110 transition-all duration-200"
																			on:click={() => removeSpecialItemPhoto(item.id, photo.id)}
																		>
																			×
																		</button>
																		<div class="absolute bottom-0 left-0 right-0 bg-black bg-opacity-50 text-white text-xs p-1 text-center opacity-0 group-hover:opacity-100 transition-opacity">
																			{photo.timestamp}
																		</div>
																	</div>
																{/each}
															</div>
														{:else}
															<div class="text-center py-3 text-purple-600 text-sm">
																<svg class="w-8 h-8 mx-auto text-purple-400 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
																	<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 002 2z"></path>
																</svg>
																<p>No photo yet</p>
																<p class="text-xs">Each special item needs individual photo</p>
															</div>
														{/if}
													</div>
												</div>
												<button
													on:click={() => removeSpecialItem(item.id)}
													class="ml-4 bg-red-500 hover:bg-red-600 text-white rounded-full w-8 h-8 flex items-center justify-center shadow-md transform hover:scale-110 transition-all duration-200"
													aria-label="Remove special item"
												>
													<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
														<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
													</svg>
												</button>
											</div>
										</div>
									{/each}
								</div>
							{/if}
						</div>
						
						<!-- Order Summary -->
						{#if selectedItems.length > 0}
							<div class="mb-6 bg-gradient-to-r from-green-50 to-emerald-50 rounded-xl p-5 border border-green-200">
								<h3 class="text-lg font-bold text-gray-900 mb-4 flex items-center">
									<svg class="w-5 h-5 mr-2 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
									</svg>
									Order Summary
								</h3>
								<div class="space-y-3">
									<div class="flex justify-between items-center py-2 border-b border-green-200">
										<span class="text-gray-700 font-medium">Total Items:</span>
										<span class="font-bold text-lg text-gray-900">
											{selectedItems.reduce((sum, item) => sum + item.quantity, 0)}
										</span>
									</div>
									<div class="flex justify-between items-center py-2 border-b border-green-200">
										<span class="text-gray-700 font-medium">Subtotal:</span>
										<span class="font-bold text-lg text-gray-900">{formatCurrency(calculateTotal())}</span>
									</div>
									<div class="flex justify-between items-center py-2 bg-green-100 rounded-lg px-3">
										<span class="text-green-800 font-bold">Total with Tax (10%):</span>
										<span class="font-bold text-xl text-green-700">
											{formatCurrency(calculateTotal() * 1.1)}
										</span>
									</div>
								</div>
							</div>
						{/if}

						<!-- Camera Section for Regular Items -->
						<div class="mb-6">
							<div class="flex items-center justify-between mb-4">
								<h3 class="text-lg font-semibold text-gray-900 flex items-center">
									<svg class="w-5 h-5 mr-2 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z"></path>
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z"></path>
									</svg>
									Regular Items - Box Photo Documentation
								</h3>
								<button
									on:click={takePhotoForRegularItems}
									class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm font-medium shadow-sm transition-colors duration-200 flex items-center"
								>
									<svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z"></path>
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z"></path>
									</svg>
									📦 Photo Box
								</button>
							</div>
							<div class="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-xl p-4 border border-blue-200 mb-4">
								<p class="text-sm text-blue-700 flex items-center">
									<svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
									</svg>
									<strong>Regular Items:</strong> Take one photo of all regular items packed together in the box. Special items need individual photos in their section above.
								</p>
							</div>
							<div class="space-y-6">
								<!-- Camera View -->
								<div class="bg-white border-2 border-gray-200 rounded-xl p-4">
									<video bind:this={videoElement} class="w-full h-48 sm:h-64 border-2 border-dashed border-gray-300 rounded-lg bg-gray-100" autoplay muted></video>
									<canvas bind:this={canvasElement} class="hidden"></canvas>
									{#if currentPhotoTarget}
										<div class="mt-2 mb-2 p-2 bg-yellow-50 border border-yellow-200 rounded-lg">
											<p class="text-sm text-yellow-800 font-medium">
												{#if currentPhotoTarget === 'regular'}
													📦 Taking photo for: <strong>Regular Items Box</strong>
												{:else}
													🌟 Taking photo for: <strong>Special Item - {specialItems.find(item => item.id === currentPhotoTarget)?.description || 'Unknown'}</strong>
												{/if}
											</p>
										</div>
									{/if}
									<div class="mt-4 flex flex-col sm:flex-row gap-3">
										<button 
											class="flex-1 bg-blue-600 hover:bg-blue-700 text-white px-4 py-3 rounded-lg text-sm font-medium shadow-md disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
											on:click={startCamera}
											disabled={isCameraActive}
										>
											<svg class="w-4 h-4 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
												<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"></path>
											</svg>
											{isCameraActive ? 'Camera Active' : 'Start Camera'}
										</button>
										<button 
											class="flex-1 bg-green-600 hover:bg-green-700 text-white px-4 py-3 rounded-lg text-sm font-medium shadow-md disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
											on:click={takePhoto}
											disabled={!isCameraActive || !currentPhotoTarget}
										>
											<svg class="w-4 h-4 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
												<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z"></path>
												<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z"></path>
											</svg>
											Take Photo
										</button>
										<button 
											class="flex-1 bg-red-600 hover:bg-red-700 text-white px-4 py-3 rounded-lg text-sm font-medium shadow-md disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
											on:click={stopCamera}
											disabled={!isCameraActive}
										>
											<svg class="w-4 h-4 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
												<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
												<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 10a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1h-4a1 1 0 01-1-1v-4z"></path>
											</svg>
											Stop Camera
										</button>
									</div>
								</div>
								
								<!-- Regular Items Photos Gallery -->
								<div class="bg-white border-2 border-blue-200 rounded-xl p-4">
									<h4 class="font-semibold text-blue-900 mb-3 flex items-center">
										<svg class="w-4 h-4 mr-2 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
											<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
										</svg>
										📦 Regular Items Box Photos ({pickingPhotos.length})
									</h4>
									{#if pickingPhotos.length === 0}
										<div class="text-center py-8 text-gray-500">
											<svg class="w-12 h-12 mx-auto text-gray-400 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
												<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
											</svg>
											<p class="text-sm font-medium">No box photos yet</p>
											<p class="text-xs">Click "📦 Photo Box" button above to take a photo of all regular items together</p>
										</div>
									{:else}
										<div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3 max-h-64 overflow-y-auto">
											{#each pickingPhotos as photo}
												<div class="relative group">
													<img src={photo.url} alt="Regular items box documentation" class="w-full h-24 object-cover rounded-lg border-2 border-blue-200 shadow-sm">
													<button 
														class="absolute -top-2 -right-2 bg-red-500 hover:bg-red-600 text-white rounded-full w-8 h-8 text-sm font-bold shadow-lg transform hover:scale-110 transition-all duration-200"
														on:click={() => removePhoto(photo.id)}
													>
														×
													</button>
												</div>
											{/each}
										</div>
									{/if}
								</div>
							</div>
						</div>

						<!-- Hotel Staff Information -->
						<div class="mb-6">
							<h3 class="text-lg font-semibold text-gray-900 mb-4 flex items-center">
								<svg class="w-5 h-5 mr-2 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
								</svg>
								Hotel Staff Information & Signature
							</h3>
							<div class="bg-white border-2 border-gray-200 rounded-xl p-4 space-y-4">
								<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
									<div>
										<label for="staff-name" class="block text-sm font-semibold text-gray-700 mb-2">Staff Name *</label>
										<select 
											id="staff-name"
											bind:value={hotelStaffName}
											class="w-full px-3 py-3 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-base"
											required
										>
											<option value="">Select hotel staff...</option>
											{#each commonStaffNames as staffName}
												<option value={staffName}>{staffName}</option>
											{/each}
										</select>
										<p class="text-xs text-gray-500 mt-1">Or type custom name if not in list</p>
									</div>
									<div>
										<label for="staff-role" class="block text-sm font-semibold text-gray-700 mb-2">Role/Position *</label>
										<select 
											id="staff-role"
											bind:value={hotelStaffRole}
											class="w-full px-3 py-3 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-base"
											required
										>
											<option value="">Select staff role...</option>
											{#each hotelStaffRoles as role}
												<option value={role}>{role}</option>
											{/each}
										</select>
										<p class="text-xs text-gray-500 mt-1">Select the staff member's position</p>
									</div>
								</div>
								
								<!-- Custom Name Input (if not in dropdown) -->
								{#if hotelStaffName && !commonStaffNames.includes(hotelStaffName)}
									<div>
										<label for="custom-staff-name" class="block text-sm font-semibold text-gray-700 mb-2">Custom Staff Name</label>
										<input 
											id="custom-staff-name"
											type="text" 
											bind:value={hotelStaffName}
											placeholder="Enter custom hotel staff name"
											class="w-full px-3 py-3 border border-orange-300 rounded-lg shadow-sm focus:ring-2 focus:ring-orange-500 focus:border-orange-500 text-base bg-orange-50"
										>
										<p class="text-xs text-orange-600 mt-1">Custom name - not in predefined list</p>
									</div>
								{/if}
								<div>
									<label for="staff-signature" class="block text-sm font-semibold text-gray-700 mb-2">Signature Digital</label>
									<textarea
										id="staff-signature"
										bind:value={hotelStaffSignature}
										placeholder="Hotel staff signature or confirmation"
										rows="4"
										class="w-full px-3 py-3 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-base resize-none"
									></textarea>
								</div>
							</div>
						</div>

						<!-- Notes -->
						<div class="mb-6">
							<label for="picking-notes" class="block text-sm font-semibold text-gray-700 mb-2 flex items-center">
								<svg class="w-4 h-4 mr-2 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
								</svg>
								Picking Notes
							</label>
							<textarea
								id="picking-notes"
								bind:value={pickingNotes}
								placeholder="Any special notes about the picking process..."
								rows="3"
								class="w-full px-3 py-3 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-gray-500 focus:border-gray-500 text-base resize-none"
							></textarea>
						</div>

						<!-- Submit Button -->
						<div class="flex justify-center sm:justify-end">
							<button
								class="w-full sm:w-auto bg-gradient-to-r from-green-600 to-green-700 hover:from-green-700 hover:to-green-800 text-white px-8 py-4 rounded-xl font-bold text-lg shadow-lg transform hover:scale-105 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none"
								on:click={submitPickingOrder}
								disabled={selectedItems.length === 0 || !pickupDate || !pickupTime || !selectedHotel || !hotelConfirmed || !user?.email || !hotelStaffName || !hotelStaffRole}
							>
								<svg class="w-5 h-5 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
								</svg>
								Submit Picking Order
							</button>
						</div>
					</div>
				</div>
			{/if}

			<!-- Picked Data Tab -->
			{#if activeTab === 'picked-data'}
				<div class="bg-white shadow-sm rounded-xl">
					<div class="p-4 sm:p-6">
						<h2 class="text-xl sm:text-2xl font-bold text-gray-900 mb-6">Picked Laundry Data</h2>
						
						<!-- Enhanced Filters -->
						<div class="mb-6 bg-gradient-to-r from-green-50 to-emerald-50 rounded-xl p-6 border border-green-200">
							<div class="flex flex-col sm:flex-row sm:justify-between sm:items-center mb-4">
								<h3 class="text-lg font-semibold text-gray-900 flex items-center">
									<svg class="w-5 h-5 mr-2 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.207A1 1 0 013 6.5V4z"></path>
									</svg>
									Advanced Filter Options
								</h3>
								<button
									on:click={clearAllFilters}
									class="mt-2 sm:mt-0 bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded-lg text-sm font-medium shadow-sm transition-colors duration-200 flex items-center"
								>
									<svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
									</svg>
									Clear All Filters
								</button>
							</div>
							
							<!-- Date Filters -->
							<div class="mb-4">
								<h4 class="text-md font-semibold text-gray-800 mb-3 flex items-center">
									<svg class="w-4 h-4 mr-2 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
									</svg>
									📅 Date Filters
								</h4>
								<div class="grid grid-cols-1 md:grid-cols-3 gap-4">
									<div>
										<label for="single-date-filter" class="block text-sm font-semibold text-gray-700 mb-2">Single Date</label>
										<input
											id="single-date-filter"
											type="date"
											bind:value={selectedDateFilter}
											class="w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-green-500 focus:border-green-500 text-sm"
										>
									</div>
									<div>
										<label for="date-range-start" class="block text-sm font-semibold text-gray-700 mb-2">Date Range Start</label>
										<input
											id="date-range-start"
											type="date"
											bind:value={dateRangeStart}
											class="w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-green-500 focus:border-green-500 text-sm"
										>
									</div>
									<div>
										<label for="date-range-end" class="block text-sm font-semibold text-gray-700 mb-2">Date Range End</label>
										<input
											id="date-range-end"
											type="date"
											bind:value={dateRangeEnd}
											class="w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-green-500 focus:border-green-500 text-sm"
										>
									</div>
								</div>
							</div>
							
							<!-- Time and Location Filters -->
							<div class="mb-4">
								<h4 class="text-md font-semibold text-gray-800 mb-3 flex items-center">
									<svg class="w-4 h-4 mr-2 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
									</svg>
									⏰ Time & Location Filters
								</h4>
								<div class="grid grid-cols-1 md:grid-cols-3 gap-4">
									<div>
										<label for="time-range-start" class="block text-sm font-semibold text-gray-700 mb-2">Time From</label>
										<input
											id="time-range-start"
											type="time"
											bind:value={timeRangeStart}
											class="w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-green-500 focus:border-green-500 text-sm"
										>
									</div>
									<div>
										<label for="time-range-end" class="block text-sm font-semibold text-gray-700 mb-2">Time To</label>
										<input
											id="time-range-end"
											type="time"
											bind:value={timeRangeEnd}
											class="w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-green-500 focus:border-green-500 text-sm"
										>
									</div>
									<div>
										<label for="hotel-filter" class="block text-sm font-semibold text-gray-700 mb-2">Hotel</label>
										<select
											id="hotel-filter"
											bind:value={selectedHotelFilter}
											class="w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-green-500 focus:border-green-500 text-sm"
										>
											<option value="">All Hotels</option>
											{#each availableHotels as hotel}
												<option value={hotel.id}>{hotel.name}</option>
											{/each}
										</select>
									</div>
								</div>
							</div>
							
							<!-- Staff Filter -->
							<div class="mb-4">
								<h4 class="text-md font-semibold text-gray-800 mb-3 flex items-center">
									<svg class="w-4 h-4 mr-2 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
									</svg>
									👤 Staff Picker
								</h4>
								<div class="grid grid-cols-1 md:grid-cols-1 gap-4">
									<div>
										<label for="staff-filter" class="block text-sm font-semibold text-gray-700 mb-2">Select Staff (who signed)</label>
										<select
											id="staff-filter"
											bind:value={selectedStaffFilter}
											class="w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-green-500 focus:border-green-500 text-sm"
										>
											<option value="">All Staff Members</option>
											{#each availableStaff as staffName}
												<option value={staffName}>{staffName}</option>
											{/each}
										</select>
										{#if availableStaff.length === 0}
											<p class="text-xs text-gray-500 mt-1">No staff data available yet</p>
										{:else}
											<p class="text-xs text-gray-500 mt-1">{availableStaff.length} staff member{availableStaff.length !== 1 ? 's' : ''} available</p>
										{/if}
									</div>
								</div>
							</div>
							
							<!-- Active Filters Display -->
							{#if selectedDateFilter || selectedHotelFilter || dateRangeStart || dateRangeEnd || timeRangeStart || timeRangeEnd || selectedStaffFilter}
								<div class="mt-4 p-3 bg-white rounded-lg border border-green-300">
									<div class="flex flex-wrap items-center gap-2">
										<span class="text-sm font-semibold text-green-700 flex items-center">
											<svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
												<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
											</svg>
											Active filters:
										</span>
										{#if selectedDateFilter}
											<span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
												📅 Date: {selectedDateFilter}
												<button class="ml-1 text-blue-600 hover:text-blue-800" on:click={() => selectedDateFilter = ''}>×</button>
											</span>
										{/if}
										{#if dateRangeStart && dateRangeEnd}
											<span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
												📅 Range: {dateRangeStart} to {dateRangeEnd}
												<button class="ml-1 text-blue-600 hover:text-blue-800" on:click={() => { dateRangeStart = ''; dateRangeEnd = ''; }}>×</button>
											</span>
										{/if}
										{#if timeRangeStart && timeRangeEnd}
											<span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
												⏰ Time: {timeRangeStart} - {timeRangeEnd}
												<button class="ml-1 text-purple-600 hover:text-purple-800" on:click={() => { timeRangeStart = ''; timeRangeEnd = ''; }}>×</button>
											</span>
										{/if}
										{#if selectedHotelFilter}
											<span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
												🏨 Hotel: {availableHotels.find(h => h.id === selectedHotelFilter)?.name}
												<button class="ml-1 text-green-600 hover:text-green-800" on:click={() => selectedHotelFilter = ''}>×</button>
											</span>
										{/if}
										{#if selectedStaffFilter}
											<span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-indigo-100 text-indigo-800">
												👤 Staff Hotel: {selectedStaffFilter}
												<button class="ml-1 text-indigo-600 hover:text-indigo-800" on:click={() => selectedStaffFilter = ''}>×</button>
											</span>
										{/if}
									</div>
								</div>
							{/if}
						</div>

						<!-- Data Display -->
						{#if Object.keys(groupedPickedData).length === 0}
							<div class="text-center py-12 text-gray-500 bg-gray-50 rounded-xl border-2 border-dashed border-gray-300">
								<svg class="w-16 h-16 mx-auto text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
								</svg>
								<p class="text-lg font-medium mb-2">No picked data found</p>
								<p class="text-sm">Complete some picking orders to see data here</p>
							</div>
						{:else}
							<div class="space-y-6">
								{#each Object.values(groupedPickedData) as group}
									<div class="bg-white border-2 border-green-200 rounded-xl p-6 shadow-sm">
										<div class="flex flex-col sm:flex-row sm:justify-between sm:items-center mb-4 pb-4 border-b border-green-200">
											<div>
												<h3 class="text-xl font-bold text-green-800">{group.hotel}</h3>
												<p class="text-sm text-green-600">Date: {group.date}</p>
											</div>
											<div class="text-right mt-2 sm:mt-0">
												<p class="text-sm text-gray-600">Total Orders: <span class="font-bold">{group.entries.length}</span></p>
												<p class="text-sm text-gray-600">Total Items: <span class="font-bold">{group.entries.reduce((sum, entry) => sum + entry.totalItems, 0)}</span></p>
											</div>
										</div>
										
										<div class="space-y-4">
											{#each group.entries as entry}
												<div class="bg-green-50 rounded-lg p-4 border border-green-200">
													<div class="flex flex-col lg:flex-row lg:justify-between lg:items-start gap-4">
														<div class="flex-1">
															<div class="flex items-center gap-2 mb-2">
																<span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
																	{entry.time}
																</span>
																{#if entry.pickingId}
																	<span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
																		ID: {entry.pickingId}
																	</span>
																{/if}
																<span class="text-xs text-gray-500">{entry.submittedAt}</span>
															</div>
															<p class="font-medium text-gray-900">Staff Hotel: {entry.staffName} ({entry.staffRole})</p>
															<p class="text-sm text-gray-600 mb-3">{entry.notes || 'No notes'}</p>
															
															<!-- Regular Items -->
															{#if entry.regularItems.length > 0}
																<div class="mb-3">
																	<h4 class="text-sm font-semibold text-gray-800 mb-2">Regular Items:</h4>
																	<div class="grid grid-cols-1 sm:grid-cols-2 gap-2">
																		{#each entry.regularItems as item}
																			<div class="text-xs bg-white rounded p-2 border">
																				<span class="font-medium">{availableItems.find(ai => ai.id === item.itemId)?.name || 'Unknown'}</span>
																				<span class="text-gray-600">× {item.quantity}</span>
																				<span class="float-right font-medium">{formatCurrency(item.total)}</span>
																			</div>
																		{/each}
																	</div>
																</div>
															{/if}
															
															<!-- Special Items -->
															{#if entry.specialItems.length > 0}
																<div class="mb-3">
																	<h4 class="text-sm font-semibold text-purple-800 mb-2">Special Items:</h4>
																	<div class="space-y-2">
																		{#each entry.specialItems as specialItem}
																			<div class="text-xs bg-purple-50 rounded p-2 border border-purple-200">
																				<div class="flex justify-between items-start">
																					<div>
																						<span class="font-medium text-purple-900">{specialItem.description}</span>
																						<span class="block text-purple-700 text-xs">{specialItem.categoryName}</span>
																					</div>
																					<span class="font-mono text-xs bg-purple-200 text-purple-900 px-2 py-1 rounded">
																						{specialItem.trackingCode}
																					</span>
																				</div>
																			</div>
																		{/each}
																	</div>
																</div>
															{/if}
														</div>
														
														<div class="text-right">
															<div class="text-lg font-bold text-green-700 mb-2">
																{formatCurrency(entry.totalValue)}
															</div>
															<div class="text-sm text-gray-600">
																{entry.totalItems} item{entry.totalItems !== 1 ? 's' : ''}
															</div>
															{#if entry.photos.length > 0}
																<div class="text-xs text-gray-500 mt-2">
																	📷 {entry.photos.length} photo{entry.photos.length !== 1 ? 's' : ''}
																</div>
															{/if}
														</div>
													</div>
												</div>
											{/each}
										</div>
									</div>
								{/each}
							</div>
						{/if}
					</div>
				</div>
			{/if}

			<!-- Delivery Tab -->
			{#if activeTab === 'delivery'}
				<div class="bg-white shadow rounded-lg">
					<div class="px-6 py-8">
						<div class="flex flex-col sm:flex-row sm:justify-between sm:items-center mb-6">
							<h2 class="text-xl font-semibold text-gray-900">Delivery Management</h2>
							<div class="flex items-center gap-2 mt-2 sm:mt-0">
								<span class="text-sm text-gray-500">
									{deliveryAvailableOrders.length} order(s) available
								</span>
								{#if selectedDeliveryOrders.length > 0}
									<span class="text-sm font-medium text-blue-600">
										({selectedDeliveryOrders.length} selected)
									</span>
								{/if}
							</div>
						</div>

						<!-- Delivery Filters -->
						<div class="bg-gray-50 rounded-lg p-4 mb-6">
							<h3 class="text-lg font-semibold text-gray-800 mb-4 flex items-center">
								<svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.707A1 1 0 013 7V4z"></path>
								</svg>
								Filter Orders for Delivery
							</h3>
							
							<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
								<!-- Date Filter -->
								<div>
									<label for="delivery-date-filter" class="block text-sm font-semibold text-gray-700 mb-2">Date</label>
									<select id="delivery-date-filter" bind:value={deliveryDateFilter} class="w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm">
										<option value="">All dates</option>
										{#each availableDeliveryDates as date}
											<option value={date}>{date}</option>
										{/each}
									</select>
								</div>

								<!-- Hotel Filter -->
								<div>
									<label for="delivery-hotel-filter" class="block text-sm font-semibold text-gray-700 mb-2">Hotel</label>
									<select id="delivery-hotel-filter" bind:value={deliveryHotelFilter} class="w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm">
										<option value="">All hotels</option>
										{#each availableHotels as hotel}
											<option value={hotel.id}>{hotel.name}</option>
										{/each}
									</select>
								</div>

								<!-- Time Range Start -->
								<div>
									<label for="delivery-time-start" class="block text-sm font-semibold text-gray-700 mb-2">Time From</label>
									<input id="delivery-time-start" type="time" bind:value={deliveryTimeRangeStart} class="w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm">
								</div>

								<!-- Time Range End -->
								<div>
									<label for="delivery-time-end" class="block text-sm font-semibold text-gray-700 mb-2">Time To</label>
									<input id="delivery-time-end" type="time" bind:value={deliveryTimeRangeEnd} class="w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm">
								</div>
							</div>

							<!-- Filter Actions -->
							<div class="flex flex-wrap items-center justify-between gap-2 mt-4 pt-4 border-t border-gray-200">
								<div class="flex flex-wrap items-center gap-2">
									{#if deliveryDateFilter || deliveryHotelFilter || deliveryTimeRangeStart || deliveryTimeRangeEnd}
										<span class="text-sm font-medium text-gray-700">Active filters:</span>
										{#if deliveryDateFilter}
											<span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
												📅 {deliveryDateFilter}
												<button class="ml-1 text-blue-600 hover:text-blue-800" on:click={() => deliveryDateFilter = ''}>×</button>
											</span>
										{/if}
										{#if deliveryHotelFilter}
											<span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
												🏨 {availableHotels.find(h => h.id === deliveryHotelFilter)?.name}
												<button class="ml-1 text-green-600 hover:text-green-800" on:click={() => deliveryHotelFilter = ''}>×</button>
											</span>
										{/if}
										{#if deliveryTimeRangeStart && deliveryTimeRangeEnd}
											<span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
												⏰ {deliveryTimeRangeStart} - {deliveryTimeRangeEnd}
												<button class="ml-1 text-purple-600 hover:text-purple-800" on:click={() => { deliveryTimeRangeStart = ''; deliveryTimeRangeEnd = ''; }}>×</button>
											</span>
										{/if}
									{/if}
								</div>
								<button on:click={clearDeliveryFilters} class="text-sm text-gray-600 hover:text-gray-800 underline">
									Clear all filters
								</button>
							</div>
						</div>

						<!-- Selection Actions -->
						{#if deliveryAvailableOrders.length > 0}
							<div class="flex flex-wrap items-center justify-between gap-4 mb-6 p-4 bg-blue-50 rounded-lg border border-blue-200">
								<div class="flex flex-wrap items-center gap-2">
									<button on:click={selectAllFilteredOrders} class="text-sm bg-blue-600 text-white px-3 py-1 rounded-md hover:bg-blue-700 transition-colors">
										Select All ({deliveryAvailableOrders.length})
									</button>
									{#if selectedDeliveryOrders.length > 0}
										<button on:click={clearOrderSelection} class="text-sm bg-gray-600 text-white px-3 py-1 rounded-md hover:bg-gray-700 transition-colors">
											Clear Selection
										</button>
									{/if}
								</div>
								{#if selectedDeliveryOrders.length > 0}
									<button on:click={submitSelectedOrdersForDelivery} class="bg-green-600 text-white px-6 py-2 rounded-md font-medium hover:bg-green-700 transition-colors flex items-center">
										<svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
											<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
										</svg>
										Mark {selectedDeliveryOrders.length} Order(s) as Delivered
									</button>
								{/if}
							</div>
						{/if}

						<!-- Orders List -->
						{#if deliveryAvailableOrders.length === 0}
							<div class="text-center py-12 text-gray-500 bg-gray-50 rounded-xl border-2 border-dashed border-gray-300">
								<svg class="w-16 h-16 mx-auto text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2M4 13h2m13-8l-1 1m-6 6l-1 1"></path>
								</svg>
								<h3 class="text-lg font-medium text-gray-900 mb-2">No Orders Available for Delivery</h3>
								<p class="text-sm text-gray-500">Complete some picking orders first or adjust your filters</p>
							</div>
						{:else}
							<div class="space-y-4">
								{#each deliveryAvailableOrders as order}
									<div class="border rounded-lg p-6 bg-gray-50 hover:bg-gray-100 transition-colors {selectedDeliveryOrders.includes(order.id) ? 'ring-2 ring-blue-500 bg-blue-50' : ''}">
										<div class="flex items-start gap-4">
											<!-- Selection Checkbox -->
											<div class="flex items-center pt-1">
												<input 
													type="checkbox" 
													id="order-{order.id}"
													checked={selectedDeliveryOrders.includes(order.id)}
													on:change={() => toggleOrderSelection(order.id)}
													class="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
												>
											</div>

											<!-- Order Details -->
											<div class="flex-1">
												<div class="flex flex-col sm:flex-row sm:justify-between sm:items-start mb-3">
													<div>
														<h3 class="text-lg font-medium text-gray-900 flex items-center">
															<svg class="w-5 h-5 mr-2 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
																<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
															</svg>
															{order.pickingId || `Order #${order.id}`}
														</h3>
														<p class="text-sm text-gray-600 font-medium">{order.hotel}</p>
														<div class="flex flex-wrap items-center gap-2 mt-2">
															<span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
																📅 {order.date}
															</span>
															<span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
																⏰ {order.time}
															</span>
															<span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
																👤 {order.pickerName}
															</span>
														</div>
													</div>
													<div class="text-right mt-2 sm:mt-0">
														<div class="text-sm text-gray-600">Total Items: <span class="font-bold text-gray-900">{order.totalItems}</span></div>
														<div class="text-sm text-gray-600">Staff: <span class="font-medium">{order.staffName}</span></div>
													</div>
												</div>

												<!-- Items Summary -->
												<div class="mb-3">
													<h4 class="font-medium text-gray-900 mb-2 text-sm">Items to Deliver:</h4>
													<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-2">
														{#each order.regularItems as item}
															<div class="bg-white p-2 rounded border text-xs">
																<div class="font-medium text-gray-900">{item.itemName}</div>
																<div class="text-gray-600">Qty: {item.quantity}</div>
															</div>
														{/each}
														{#each order.specialItems as item}
															<div class="bg-yellow-50 p-2 rounded border border-yellow-200 text-xs">
																<div class="font-medium text-yellow-800">⭐ {item.description}</div>
																<div class="text-yellow-600">{item.category}</div>
															</div>
														{/each}
													</div>
												</div>

												<!-- Notes -->
												{#if order.notes}
													<div class="mt-2 p-2 bg-white rounded border">
														<div class="text-xs text-gray-600">
															<strong>Notes:</strong> {order.notes}
														</div>
													</div>
												{/if}
											</div>
										</div>
									</div>
								{/each}
							</div>
						{/if}
					</div>
				</div>
			{/if}
		</div>
	{:else}
		<div class="flex items-center justify-center min-h-screen">
			<div class="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
		</div>
	{/if}
</div> 