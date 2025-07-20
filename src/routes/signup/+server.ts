import { supabase } from '$lib/supabase';
import { hashPassword } from '$lib/server/auth';
import { json } from '@sveltejs/kit';
import type { RequestHandler } from '@sveltejs/kit';

export const POST: RequestHandler = async ({ request }) => {
  const { email, password, role } = await request.json();

  if (!email || !password || !role) {
    return json({ error: 'Missing fields' }, { status: 400 });
  }

  if (!supabase) {
    return json({ error: 'Database not configured' }, { status: 500 });
  }

  const hashedPassword = await hashPassword(password);

  const { data, error } = await supabase
    .from('users')
    .insert([{ email, password: hashedPassword, role }])
    .select()
    .single();

  if (error) {
    return json({ error: error.message }, { status: 400 });
  }

  return json({ success: true, user: { email: data.email, role: data.role } });
}; 