import { json } from '@sveltejs/kit';
import { verifyPassword } from '$lib/server/auth';
import type { RequestHandler } from './$types';

export const POST: RequestHandler = async ({ request }) => {
  try {
    const { password, hash } = await request.json();
    
    if (!password || !hash) {
      return json({ error: 'Password and hash are required' }, { status: 400 });
    }
    
    const valid = await verifyPassword(password, hash);
    
    return json({ valid });
  } catch (error) {
    return json({ error: 'Failed to verify password', valid: false }, { status: 500 });
  }
}; 