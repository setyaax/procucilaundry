import { supabase } from '$lib/supabase';
import { verifyPassword, generateToken } from '$lib/server/auth';
import { redirect, fail } from '@sveltejs/kit';
import type { Actions } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  // If user is already logged in, redirect to dashboard
  if (locals.user) {
    throw redirect(303, '/dashboard');
  }
  
  return {};
};

export const actions: Actions = {
  default: async ({ request, cookies }) => {
    const form = await request.formData();
    const email = form.get('email') as string;
    const password = form.get('password') as string;
    const role = form.get('role') as string;

    if (!email || !password || !role) {
      return fail(400, { error: 'Missing fields' });
    }

    // TEST MODE: Allow demo login without database
    if (email === 'demo@example.com' && password === 'demo123') {
      const token = generateToken('demo-user-id', role);
      cookies.set('session', token, {
        path: '/',
        httpOnly: true,
        sameSite: 'strict',
        secure: false,
        maxAge: 3600
      });

      throw redirect(303, '/dashboard');
    }

    // PRODUCTION MODE: Use Supabase
    if (!supabase) {
      return fail(500, { error: 'Database not configured. Use demo@example.com / demo123 for testing.' });
    }

    try {
      console.log('Login attempt:', { email, role });
      
      const { data, error } = await supabase
        .from('users')
        .select('*')
        .eq('email', email)
        .eq('role', role)
        .single();

      console.log('Query result:', { data, error });

      if (error || !data) {
        console.log('User not found or query error:', error);
        return fail(401, { error: 'Invalid credentials' });
      }

      console.log('Verifying password for user:', data.email);
      const valid = await verifyPassword(password, data.password);

      if (!valid) {
        console.log('Password verification failed');
        return fail(401, { error: 'Invalid credentials' });
      }

      const token = generateToken(data.user_id, data.role);

      cookies.set('session', token, {
        path: '/',
        httpOnly: true,
        sameSite: 'strict',
        secure: false,
        maxAge: 3600
      });

      console.log('Login successful, redirecting to dashboard');
      // Move redirect outside try-catch to avoid confusion
    } catch (err) {
      console.error('Database error:', err);
      // Provide more specific error message
      const errorMessage = err instanceof Error ? err.message : 'Unknown error';
      
      // Check if it's a network/connectivity error
      if (errorMessage.includes('fetch failed') || errorMessage.includes('ENOTFOUND') || errorMessage.includes('ECONNREFUSED')) {
        return fail(500, { 
          error: `Database connection failed. This might be a temporary network issue. Please try again in a moment, or use demo@example.com / demo123 for testing.` 
        });
      }
      
      return fail(500, { 
        error: `Database error: ${errorMessage}. Use demo@example.com / demo123 for testing.` 
      });
    }
    
    // If we get here, login was successful - redirect
    throw redirect(303, '/dashboard');
  }
}; 