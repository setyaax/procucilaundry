import { supabase } from '$lib/supabase';
import { json } from '@sveltejs/kit';
import type { RequestHandler } from '@sveltejs/kit';

export const GET: RequestHandler = async () => {
  if (!supabase) {
    return json({ 
      connected: false, 
      error: 'Supabase client not initialized' 
    });
  }

  try {
    // Test connection by checking if users table exists
    const { data, error } = await supabase
      .from('users')
      .select('count')
      .limit(1);

    if (error) {
      // Table might not exist
      return json({ 
        connected: true,
        database_connected: true,
        users_table_exists: false,
        error: error.message,
        hint: 'Connected to Supabase, but users table not found. Create it using the SQL provided in README.md'
      });
    }

    return json({ 
      connected: true,
      database_connected: true,
      users_table_exists: true,
      message: 'Successfully connected to Supabase!'
    });
  } catch (err) {
    return json({ 
      connected: false, 
      error: err instanceof Error ? err.message : 'Unknown error' 
    });
  }
}; 