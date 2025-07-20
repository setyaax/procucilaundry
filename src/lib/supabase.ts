import { createClient } from '@supabase/supabase-js';
import { env } from '$env/dynamic/public';

// Only create Supabase client if valid URLs are provided
export const supabase = (env.PUBLIC_SUPABASE_URL && env.PUBLIC_SUPABASE_URL !== 'your_supabase_url') 
  ? createClient(env.PUBLIC_SUPABASE_URL, env.PUBLIC_SUPABASE_ANON_KEY)
  : null;
 