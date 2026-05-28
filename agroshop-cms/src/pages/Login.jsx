import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { apiRequest, saveSession } from '../utils/api';
import { Leaf } from 'lucide-react';

export default function Login({ onLogin }) {
  const [email, setEmail] = useState('admin@agroshop.test');
  const [password, setPassword] = useState('admin123');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  async function submitLogin(event) {
    event.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await apiRequest('/auth/login', {
        method: 'POST',
        body: JSON.stringify({ email, password }),
      });

      if (response.user?.role !== 'ADMIN') {
        throw new Error('Akses ditolak: Hanya akun ADMIN yang diizinkan masuk ke CMS.');
      }

      const nextSession = { token: response.token, user: response.user };
      saveSession(nextSession);
      onLogin(nextSession);
      navigate('/dashboard');
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="login-page">
      <div className="login-card">
        <div style={{ textAlign: 'center', marginBottom: '8px' }}>
          <Leaf size={48} color="var(--primary)" style={{ margin: '0 auto' }} />
        </div>
        <div>
          <h1>Agroshop CMS</h1>
          <p>Masuk ke dashboard admin</p>
        </div>

        <form className="form-grid" onSubmit={submitLogin}>
          <div className="input-group full-width">
            <label>Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>
          <div className="input-group full-width">
            <label>Password</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>
          
          {error && <div className="notice danger full-width" style={{marginBottom: 0}}>{error}</div>}
          
          <div className="full-width mt-4">
            <button className="btn btn-primary" style={{ width: '100%', padding: '12px' }} disabled={loading} type="submit">
              {loading ? 'Memproses...' : 'Masuk'}
            </button>
          </div>
        </form>
      </div>
    </main>
  );
}
