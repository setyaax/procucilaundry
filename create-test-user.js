// Run this script to create a test user
// Usage: node create-test-user.js

async function createTestUser() {
  const users = [
    { email: 'admin@example.com', password: 'password123', role: 'main_admin' },
    { email: 'staff@example.com', password: 'password123', role: 'laundry_staff' },
    { email: 'hotel@example.com', password: 'password123', role: 'hotel_staff' }
  ];

  for (const user of users) {
    try {
      const response = await fetch('http://localhost:5174/signup', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(user)
      });

      const result = await response.json();
      
      if (response.ok) {
        console.log(`✅ Created user: ${user.email} with role: ${user.role}`);
      } else {
        console.log(`❌ Failed to create ${user.email}: ${result.error}`);
      }
    } catch (error) {
      console.error(`❌ Error creating ${user.email}:`, error.message);
    }
  }
}

createTestUser().then(() => {
  console.log('\nYou can now login with:');
  console.log('Email: admin@example.com, Password: password123, Role: Main Admin');
  console.log('Email: staff@example.com, Password: password123, Role: Laundry Staff');
  console.log('Email: hotel@example.com, Password: password123, Role: Hotel Staff');
}); 