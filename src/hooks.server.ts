import type { Handle } from '@sveltejs/kit';
import { verifyToken } from '$lib/server/auth';

export const handle: Handle = async ({ event, resolve }) => {
	const token = event.cookies.get('session');

	if (token) {
		const user = verifyToken(token);
		if (user) {
			event.locals.user = user;
		}
	}

	// List of public routes that don't require authentication
	const publicRoutes = ['/', '/test-connection', '/signup', '/auth-test', '/test-db', '/create-test-user', '/view-users', '/check-user', '/debug-login', '/database-setup'];
	const isPublicRoute = publicRoutes.includes(event.url.pathname) || event.url.pathname.startsWith('/api/');
	
	if (!event.locals.user && !isPublicRoute) {
		return Response.redirect(event.url.origin + '/', 303);
	}

	return resolve(event);
};
