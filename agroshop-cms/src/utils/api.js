export const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:3003/api';

export function getStoredSession() {
  const rawSession = localStorage.getItem('agroshop_cms_session');
  return rawSession ? JSON.parse(rawSession) : null;
}

export function saveSession(session) {
  localStorage.setItem('agroshop_cms_session', JSON.stringify(session));
}

export function clearSession() {
  localStorage.removeItem('agroshop_cms_session');
}

export async function apiRequest(path, options = {}) {
  const session = getStoredSession();
  const headers = {
    'Content-Type': 'application/json',
    ...(options.headers ?? {}),
  };

  if (session?.token) {
    headers.Authorization = `Bearer ${session.token}`;
  }

  const response = await fetch(`${API_BASE_URL}${path}`, {
    ...options,
    headers,
  });

  const text = await response.text();
  const payload = text ? JSON.parse(text) : null;

  if (!response.ok) {
    const message =
      payload?.message ??
      payload?.error ??
      `Request gagal dengan status ${response.status}`;
    throw new Error(Array.isArray(message) ? message.join(', ') : message);
  }

  return payload;
}

