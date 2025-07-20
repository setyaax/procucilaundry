import { redirect } from '@sveltejs/kit';
import type { RequestHandler } from './$types';

export const POST: RequestHandler = async ({ cookies }) => {
  // Clear the session cookie
  cookies.delete('session', { path: '/' });
  
  // Redirect to login page
  throw redirect(303, '/');
}; 