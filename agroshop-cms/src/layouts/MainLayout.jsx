import React from 'react';
import { NavLink, Outlet, useNavigate } from 'react-router-dom';
import { LayoutDashboard, Tag, Package, Image as ImageIcon, ShoppingCart, Users, LogOut } from 'lucide-react';
import { clearSession, API_BASE_URL } from '../utils/api';

export default function MainLayout({ session, setSession }) {
  const navigate = useNavigate();
  const isAdmin = session?.user?.role === 'ADMIN';

  const handleLogout = () => {
    clearSession();
    setSession(null);
    navigate('/login');
  };

  const menuItems = [
    { path: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },
    { path: '/categories', label: 'Kategori', icon: Tag },
    { path: '/products', label: 'Produk', icon: Package },
    { path: '/banners', label: 'Banner', icon: ImageIcon },
    { path: '/orders', label: 'Pesanan', icon: ShoppingCart },
    { path: '/users', label: 'User', icon: Users },
  ];

  return (
    <div className="app-layout">
      {/* Sidebar */}
      <aside className="sidebar">
        <div className="sidebar-header">
          <h1>Agroshop</h1>
          <p style={{ fontSize: '0.75rem', color: '#9ca3af', marginTop: '4px' }}>CMS Admin Panel</p>
        </div>

        <nav className="nav-list">
          {menuItems.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              className={({ isActive }) => (isActive ? 'nav-item active' : 'nav-item')}
            >
              <item.icon size={20} />
              {item.label}
            </NavLink>
          ))}
        </nav>

        <div className="user-box">
          <strong>{session?.user?.name}</strong>
          <span>{session?.user?.email}</span>
          <button className="btn btn-ghost" onClick={handleLogout} style={{ marginTop: '8px', color: '#ef4444' }}>
            <LogOut size={18} /> Keluar
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <main className="main-content">
        <header className="topbar">
          <div>
            <span style={{ fontSize: '0.85rem', color: '#6b7280' }}>Gateway: {API_BASE_URL}</span>
          </div>
          <div>
            <span className={`badge ${isAdmin ? 'success' : 'danger'}`}>
              Role: {session?.user?.role || 'GUEST'}
            </span>
          </div>
        </header>

        <div className="page-wrapper">
          {!isAdmin && (
            <div className="notice danger">
              Akun ini bukan ADMIN. Data publik masih bisa dilihat, tetapi aksi tambah, edit, dan hapus akan ditolak backend.
            </div>
          )}
          <Outlet />
        </div>
      </main>
    </div>
  );
}
