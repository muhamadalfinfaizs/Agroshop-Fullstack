import React, { useState } from 'react';
import { changePassword } from '../utils/api';

export default function Settings() {
  const [formData, setFormData] = useState({
    oldPassword: '',
    newPassword: '',
    confirmPassword: '',
  });

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
    setError(null);
    setSuccess(null);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError(null);
    setSuccess(null);

    if (formData.newPassword !== formData.confirmPassword) {
      setError('Password baru dan konfirmasi password tidak cocok.');
      return;
    }

    if (formData.newPassword.length < 6) {
      setError('Password baru minimal 6 karakter.');
      return;
    }

    try {
      setLoading(true);
      const res = await changePassword({
        oldPassword: formData.oldPassword,
        newPassword: formData.newPassword,
      });
      setSuccess(res.message || 'Password berhasil diubah.');
      setFormData({ oldPassword: '', newPassword: '', confirmPassword: '' });
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <div className="header-box">
        <h2>Pengaturan Akun</h2>
        <p>Ganti password dan keamanan akun Anda</p>
      </div>

      <div style={{ maxWidth: '400px', marginTop: '20px' }}>
        {error && <div className="notice danger">{error}</div>}
        {success && <div className="notice success">{success}</div>}

        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          <div className="form-group">
            <label>Password Lama</label>
            <input
              type="password"
              name="oldPassword"
              className="input-field"
              value={formData.oldPassword}
              onChange={handleChange}
              required
            />
          </div>

          <div className="form-group">
            <label>Password Baru</label>
            <input
              type="password"
              name="newPassword"
              className="input-field"
              value={formData.newPassword}
              onChange={handleChange}
              required
            />
          </div>

          <div className="form-group">
            <label>Konfirmasi Password Baru</label>
            <input
              type="password"
              name="confirmPassword"
              className="input-field"
              value={formData.confirmPassword}
              onChange={handleChange}
              required
            />
          </div>

          <button type="submit" className="btn btn-primary" disabled={loading} style={{ marginTop: '10px' }}>
            {loading ? 'Menyimpan...' : 'Simpan Password Baru'}
          </button>
        </form>
      </div>
    </div>
  );
}
