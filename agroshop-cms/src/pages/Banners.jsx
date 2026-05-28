import React, { useState, useEffect } from 'react';
import { apiRequest } from '../utils/api';
import CrudLayout from '../components/CrudLayout';
import Input from '../components/Input';
import DataTable, { RowActions } from '../components/DataTable';

const emptyForm = { title: '', subtitle: '', imageUrl: '' };

export default function Banners() {
  const [data, setData] = useState([]);
  const [form, setForm] = useState(emptyForm);
  const [editingId, setEditingId] = useState(null);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');
  const [isFormVisible, setIsFormVisible] = useState(false);

  const loadData = async () => {
    try {
      const res = await apiRequest('/banners');
      setData(res.data || []);
    } catch (err) {
      setMessage(err.message);
    }
  };

  useEffect(() => { loadData(); }, []);

  const submit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setMessage('');
    try {
      const path = editingId ? `/banners/${editingId}` : '/banners';
      const method = editingId ? 'PATCH' : 'POST';
      await apiRequest(path, { method, body: JSON.stringify(form) });
      
      setForm(emptyForm);
      setEditingId(null);
      setIsFormVisible(false);
      setMessage(editingId ? 'Banner diperbarui' : 'Banner ditambahkan');
      loadData();
    } catch (err) {
      setMessage(err.message);
    } finally {
      setLoading(false);
    }
  };

  const remove = async (id) => {
    try {
      await apiRequest(`/banners/${id}`, { method: 'DELETE' });
      setMessage('Banner dihapus');
      loadData();
    } catch (err) {
      setMessage(err.message);
    }
  };

  return (
    <CrudLayout 
      title="Banner Promosi" 
      loading={loading}
      isFormVisible={isFormVisible}
      onToggleForm={() => {
        setIsFormVisible(!isFormVisible);
        if (isFormVisible) {
          setEditingId(null);
          setForm(emptyForm);
        }
      }}
      form={
        <form className="form-grid" onSubmit={submit}>
          {message && <div className="notice success full-width">{message}</div>}
          <div className="full-width">
            <Input label="Judul" name="title" value={form.title} setForm={setForm} />
          </div>
          <div className="full-width">
            <Input label="Sub Judul" name="subtitle" value={form.subtitle} setForm={setForm} />
          </div>
          <div className="full-width">
            <Input label="URL Gambar" name="imageUrl" value={form.imageUrl} setForm={setForm} hint="Disarankan: Rasio 16:9 atau 2:1 (Lebar) agar pas di layar (contoh: 1024x512px)" />
          </div>
          <div className="full-width mt-4">
            <button className="btn btn-primary" type="submit">
              {editingId ? 'Update Banner' : 'Tambah Banner'}
            </button>
            {editingId && (
              <button type="button" className="btn btn-ghost" style={{marginLeft: '8px'}} onClick={() => { setEditingId(null); setForm(emptyForm); setIsFormVisible(false); }}>
                Batal
              </button>
            )}
          </div>
        </form>
      }
    >
      <DataTable
        columns={['ID', 'Judul', 'Sub Judul', 'Gambar']}
        data={data.map(item => ({
          ...item,
          'ID': item.id,
          'Judul': item.title,
          'Sub Judul': item.subtitle,
          'Gambar': item.imageUrl ? <img src={item.imageUrl} alt={item.title} height={40} style={{borderRadius: '4px', maxWidth: '100px', objectFit: 'cover'}} /> : '-',
        }))}
        actions={(row) => (
          <RowActions
            onEdit={() => {
              const original = data.find(d => d.id === row.ID);
              if (original) {
                setEditingId(original.id);
                setForm({ title: original.title || '', subtitle: original.subtitle || '', imageUrl: original.imageUrl || '' });
                setIsFormVisible(true);
              }
            }}
            onDelete={() => remove(row.ID)}
          />
        )}
      />
    </CrudLayout>
  );
}
