import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { JWT_SECRET } from '$env/static/private';

export async function hashPassword(password: string): Promise<string> {
	return bcrypt.hash(password, 10);
}

export async function verifyPassword(password: string, hashed: string): Promise<boolean> {
	return bcrypt.compare(password, hashed);
}

export function generateToken(userId: string, role: string): string {
	return jwt.sign({ userId, role }, JWT_SECRET, { expiresIn: '1h' });
}

export function verifyToken(token: string): { userId: string; role: string } | null {
	try {
		return jwt.verify(token, JWT_SECRET) as { userId: string; role: string };
	} catch {
		return null;
	}
}
