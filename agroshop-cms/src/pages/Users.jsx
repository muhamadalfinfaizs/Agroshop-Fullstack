import React, { useState, useEffect } from 'react';
import { apiRequest } from '../utils/api';
import DataTable from '../components/DataTable';

export default function Users() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');

  const loadData = async () => {
    setLoading(true);
    try {
      const res = await apiRequest('/users');
      setUsers(res.data || []);
    } catch (err) {
      setMessage(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { loadData(); }, []);

  return (
    <section>
      <div className="page-header">
        <div>
          <h2>Data Pengguna</h2>
          <p>Daftar semua pengguna yang terdaftar di sistem.</p>
        </div>
      </div>
      
      {message && <div className="notice danger">{message}</div>}

      <div className="card">
        {loading ? (
          <div style={{ color: 'var(--primary)' }}>Memuat data...</div>
        ) : (
          <DataTable
            columns={['ID', 'Nama', 'Email', 'No. HP']}
            data={users.map(user => ({
              ...user,
              'ID': user.id,
              'Nama': user.name,
              'Email': user.email,
              'No. HP': user.phone || '-',
            }))}
          />
        )}
      </div>
    </section>
  );
}
