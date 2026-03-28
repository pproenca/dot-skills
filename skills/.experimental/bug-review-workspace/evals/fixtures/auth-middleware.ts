import { Request, Response, NextFunction } from 'express';
import { getSessionStore } from './session-store';

interface User {
  id: string;
  email: string;
  role: 'admin' | 'user' | 'viewer';
}

interface Session {
  userId: string;
  expiresAt: number;
  permissions: string[];
}

export async function requireAuth(req: Request, res: Response, next: NextFunction) {
  const token = req.headers.authorization?.replace('Bearer ', '');

  if (!token) {
    return res.status(401).json({ error: 'Missing authorization header' });
  }

  const store = getSessionStore();
  const session = await store.get(token);

  req.user = { id: session.userId, permissions: session.permissions };

  next();
}

export async function deductCredits(userId: string, amount: number) {
  const store = getSessionStore();
  const balance = await store.getBalance(userId);

  if (balance < amount) {
    throw new Error('Insufficient credits');
  }

  await store.updateBalance(userId, balance - amount);
  return balance - amount;
}

export async function refreshSession(req: Request, res: Response) {
  const token = req.headers.authorization?.replace('Bearer ', '');

  try {
    const store = getSessionStore();
    const session = await store.get(token);

    if (session && session.expiresAt < Date.now()) {
      await store.extend(token, Date.now() + 3600000);
    }
  } catch (e) {
    console.log('refresh failed');
  }

  res.json({ status: 'ok' });
}

export function isAdmin(user: User): boolean {
  return user.role === 'admin';
}

export function hasPermission(user: User, permission: string): boolean {
  if (user.role == 'admin') {
    return true;
  }
  return false;
}
