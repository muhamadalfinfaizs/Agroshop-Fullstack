import React, { useState, useEffect } from 'react';
import { apiRequest } from '../utils/api';
import DataTable from '../components/DataTable';

const statusOptions = [
  { value: 'WAITING', label: 'Menunggu Diproses', color: 'warning' },
  { value: 'PACKED', label: 'Dikemas', color: 'primary' },
  { value: 'SHIPPED', label: 'Dikirim', color: 'primary' },
  { value: 'IN_TRANSIT', label: 'Dalam Perjalanan', color: 'warning' },
  { value: 'DELIVERED', label: 'Terkirim', color: 'success' },
  { value: 'CANCELLED', label: 'Dibatalkan', color: 'danger' },
];

export default function Orders() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');

  const loadData = async () => {
    setLoading(true);
    try {
      const res = await apiRequest('/orders');
      setOrders(res.data || []);
    } catch (err) {
      setMessage(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { loadData(); }, []);

  const updateShipmentStatus = async (orderCode, newStatus) => {
    try {
      await apiRequest(`/shipments/orders/${orderCode}`, {
        method: 'PATCH',
        body: JSON.stringify({ status: newStatus }),
      });
      setMessage(`Status pengiriman ${orderCode} diupdate`);
      loadData();
    } catch (err) {
      alert(err.message);
    }
  };

  const deleteOrder = async (orderCode) => {
    try {
      if (window.confirm(`Yakin ingin menghapus pesanan ${orderCode}?`)) {
        await apiRequest(`/orders/${orderCode}`, { method: 'DELETE' });
        setMessage(`Pesanan ${orderCode} berhasil dihapus`);
        loadData();
      }
    } catch (err) {
      alert(err.message);
    }
  };

  return (
    <section>
      <div className="page-header">
        <div>
          <h2>Pesanan Pelanggan</h2>
          <p>Pantau order dan update status pengiriman.</p>
        </div>
      </div>
      
      {message && <div className="notice success">{message}</div>}

      <div className="card">
        {loading ? (
          <div style={{ color: 'var(--primary)' }}>Memuat data...</div>
        ) : (
          <DataTable
            columns={['Kode', 'Pelanggan', 'Total', 'Status Pembayaran', 'Status Pengiriman', 'Update Status', 'Aksi']}
            data={orders.map(order => {
              const shipment = order.shipment || {};
              const currentStatus = shipment.status || 'WAITING';
              
              const statusDef = statusOptions.find(o => o.value === currentStatus);
              const statusBadge = <span className={`badge ${statusDef?.color || 'warning'}`}>{statusDef?.label || currentStatus}</span>;
              
              return {
                ...order,
                'Kode': order.orderCode,
                'Pelanggan': order.user?.name || `User #${order.userId}`,
                'Total': `Rp ${order.totalAmount?.toLocaleString('id-ID')}`,
                'Status Pembayaran': order.status,
                'Status Pengiriman': statusBadge,
                'Update Status': (
                  <select 
                    value={currentStatus} 
                    onChange={(e) => updateShipmentStatus(order.orderCode, e.target.value)}
                    style={{ padding: '6px', borderRadius: '4px', border: '1px solid var(--border)' }}
                  >
                    {statusOptions.map(opt => (
                      <option key={opt.value} value={opt.value}>{opt.label}</option>
                    ))}
                  </select>
                ),
                'Aksi': (
                  <button className="btn btn-ghost" style={{ padding: '6px' }} onClick={() => deleteOrder(order.orderCode)} title="Hapus">
                    <span style={{ color: 'var(--danger)' }}>Hapus</span>
                  </button>
                )
              };
            })}
          />
        )}
      </div>
    </section>
  );
}
