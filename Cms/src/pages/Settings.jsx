import React, { useState, useEffect } from 'react';
import { User, Shield, Building2 } from 'lucide-react';
import { changePassword, updateProfile, getStoredSession, saveSession } from '../utils/api';

export default function Settings() {
  const [session, setSession] = useState(getStoredSession());
  
  // State for Change Password
  const [passData, setPassData] = useState({ oldPassword: '', newPassword: '', confirmPassword: '' });
  const [passLoading, setPassLoading] = useState(false);
  const [passError, setPassError] = useState(null);
  const [passSuccess, setPassSuccess] = useState(null);

  // State for Edit Profile
  const [profileData, setProfileData] = useState({ name: '', email: '' });
  const [profileLoading, setProfileLoading] = useState(false);
  const [profileError, setProfileError] = useState(null);
  const [profileSuccess, setProfileSuccess] = useState(null);

  useEffect(() => {
    if (session?.user) {
      setProfileData({
        name: session.user.name || '',
        email: session.user.email || '',
      });
    }
  }, [session]);

  const handlePassChange = (e) => {
    setPassData({ ...passData, [e.target.name]: e.target.value });
    setPassError(null); setPassSuccess(null);
  };

  const handleProfileChange = (e) => {
    setProfileData({ ...profileData, [e.target.name]: e.target.value });
    setProfileError(null); setProfileSuccess(null);
  };

  const handlePassSubmit = async (e) => {
    e.preventDefault();
    setPassError(null); setPassSuccess(null);

    if (passData.newPassword !== passData.confirmPassword) {
      return setPassError('Password baru dan konfirmasi tidak cocok.');
    }
    if (passData.newPassword.length < 6) {
      return setPassError('Password baru minimal 6 karakter.');
    }

    try {
      setPassLoading(true);
      const res = await changePassword({ oldPassword: passData.oldPassword, newPassword: passData.newPassword });
      setPassSuccess(res.message || 'Password berhasil diubah.');
      setPassData({ oldPassword: '', newPassword: '', confirmPassword: '' });
    } catch (err) {
      setPassError(err.message);
    } finally {
      setPassLoading(false);
    }
  };

  const handleProfileSubmit = async (e) => {
    e.preventDefault();
    setProfileError(null); setProfileSuccess(null);

    try {
      setProfileLoading(true);
      const res = await updateProfile({ name: profileData.name, email: profileData.email });
      setProfileSuccess(res.message || 'Profil berhasil diperbarui.');
      
      // Update session local storage so header/sidebar updates
      const updatedSession = { ...session, user: { ...session.user, ...res.user } };
      saveSession(updatedSession);
      setSession(updatedSession);
      // Optional: window.location.reload() to trigger full UI refresh if needed, but state update is better.
    } catch (err) {
      setProfileError(err.message);
    } finally {
      setProfileLoading(false);
    }
  };

  return (
    <div>
      <div className="page-header">
        <div>
          <h2>Pengaturan</h2>
          <p>Kelola profil admin, keamanan akun, dan preferensi toko Anda.</p>
        </div>
      </div>

      <div className="form-grid">
        {/* CARD 1: EDIT PROFILE */}
        <div className="card">
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '20px' }}>
            <div style={{ padding: '8px', backgroundColor: 'var(--primary-light)', borderRadius: '8px', color: 'var(--primary-dark)' }}>
              <User size={24} />
            </div>
            <h3 style={{ fontSize: '1.2rem' }}>Profil Admin</h3>
          </div>
          
          {profileError && <div className="notice danger">{profileError}</div>}
          {profileSuccess && <div className="notice success">{profileSuccess}</div>}

          <form onSubmit={handleProfileSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            <div className="input-group">
              <label>Nama Lengkap</label>
              <input type="text" name="name" value={profileData.name} onChange={handleProfileChange} required />
            </div>
            <div className="input-group">
              <label>Alamat Email</label>
              <input type="email" name="email" value={profileData.email} onChange={handleProfileChange} required />
            </div>
            <button type="submit" className="btn btn-primary" disabled={profileLoading} style={{ marginTop: '10px' }}>
              {profileLoading ? 'Menyimpan...' : 'Simpan Profil'}
            </button>
          </form>
        </div>

        {/* CARD 2: KEAMANAN (GANTI PASSWORD) */}
        <div className="card">
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '20px' }}>
            <div style={{ padding: '8px', backgroundColor: '#fee2e2', borderRadius: '8px', color: '#b91c1c' }}>
              <Shield size={24} />
            </div>
            <h3 style={{ fontSize: '1.2rem' }}>Keamanan Akun</h3>
          </div>

          {passError && <div className="notice danger">{passError}</div>}
          {passSuccess && <div className="notice success">{passSuccess}</div>}

          <form onSubmit={handlePassSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            <div className="input-group">
              <label>Password Lama</label>
              <input type="password" name="oldPassword" value={passData.oldPassword} onChange={handlePassChange} required />
            </div>
            <div className="input-group">
              <label>Password Baru</label>
              <input type="password" name="newPassword" value={passData.newPassword} onChange={handlePassChange} required />
            </div>
            <div className="input-group">
              <label>Konfirmasi Password Baru</label>
              <input type="password" name="confirmPassword" value={passData.confirmPassword} onChange={handlePassChange} required />
            </div>
            <button type="submit" className="btn btn-danger" disabled={passLoading} style={{ marginTop: '10px' }}>
              {passLoading ? 'Mengubah...' : 'Ubah Password'}
            </button>
          </form>
        </div>

      </div>
    </div>
  );
}
