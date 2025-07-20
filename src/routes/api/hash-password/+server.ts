import { json } from '@sveltejs/kit';
import { hashPassword } from '$lib/server/auth';
import type { RequestHandler } from './$types';

export const POST: RequestHandler = async ({ request }) => {
  try {
    const { password } = await request.json();
    
    if (!password) {
      return json({ error: 'Password is required' }, { status: 400 });
    }
    
    const hashedPassword = await hashPassword(password);
    
    return json({ hashedPassword });
  } catch (error) {
    return json({ error: 'Failed to hash password' }, { status: 500 });
  }
}; 