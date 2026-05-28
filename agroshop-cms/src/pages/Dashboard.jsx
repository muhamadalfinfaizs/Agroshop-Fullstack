import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Tag, Package, ImageIcon, ShoppingCart } from 'lucide-react';

export default function Dashboard() {
  const navigate = useNavigate();

  const cards = [
    { title: 'Kategori', desc: 'Kelola kelompok produk', path: '/categories', icon: Tag, color: '#10b981' },
    { title: 'Produk', desc: 'Tambah dan ubah data produk', path: '/products', icon: Package, color: '#3b82f6' },
    { title: 'Banner', desc: 'Atur banner promosi', path: '/banners', icon: ImageIcon, color: '#f59e0b' },
    { title: 'Pesanan', desc: 'Pantau order dan pengiriman', path: '/orders', icon: ShoppingCart, color: '#ef4444' },
  ];

  return (
    <section>
      <div className="page-header">
        <div>
          <p className="eyebrow" style={{ color: 'var(--primary)', fontWeight: 600, fontSize: '0.85rem', textTransform: 'uppercase' }}>Dashboard</p>
          <h2>Ringkasan CMS</h2>
        </div>
      </div>
      
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '20px' }}>
        {cards.map((card) => (
          <div 
            key={card.title} 
            className="card" 
            style={{ cursor: 'pointer', transition: 'transform 0.2s', display: 'flex', flexDirection: 'column', gap: '12px' }}
            onClick={() => navigate(card.path)}
            onMouseOver={(e) => e.currentTarget.style.transform = 'translateY(-4px)'}
            onMouseOut={(e) => e.currentTarget.style.transform = 'translateY(0)'}
          >
            <div style={{ backgroundColor: card.color + '20', width: '48px', height: '48px', borderRadius: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <card.icon color={card.color} size={24} />
            </div>
            <div>
              <strong style={{ fontSize: '1.2rem', display: 'block', marginBottom: '4px' }}>{card.title}</strong>
              <span style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>{card.desc}</span>
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}
