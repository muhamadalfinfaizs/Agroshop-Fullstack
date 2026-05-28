import React, { useState, useEffect } from 'react';
import { apiRequest } from '../utils/api';
import CrudLayout from '../components/CrudLayout';
import Input from '../components/Input';
import DataTable, { RowActions } from '../components/DataTable';

const emptyForm = {
  name: '', description: '', price: 0, discountPrice: 0,
  imageUrl: '', images: '', stock: 0, isFeatured: false,
  isAvailable: true, unit: 'pcs', categoryId: ''
};

export default function Products() {
  const [data, setData] = useState([]);
  const [categories, setCategories] = useState([]);
  const [form, setForm] = useState(emptyForm);
  const [editingId, setEditingId] = useState(null);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');
  const [isFormVisible, setIsFormVisible] = useState(false);

  const loadData = async () => {
    try {
      const res = await apiRequest('/products');
      setData(res.data || []);
      const catRes = await apiRequest('/categories');
      setCategories(catRes.data || []);
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
      const path = editingId ? `/products/${editingId}` : '/products';
      const method = editingId ? 'PATCH' : 'POST';
      
      const payload = { ...form };
      if (payload.categoryId) payload.categoryId = Number(payload.categoryId);
      
      await apiRequest(path, { method, body: JSON.stringify(payload) });
      
      setForm(emptyForm);
      setEditingId(null);
      setIsFormVisible(false);
      setMessage(editingId ? 'Produk diperbarui' : 'Produk ditambahkan');
      loadData();
    } catch (err) {
      setMessage(err.message);
    } finally {
      setLoading(false);
    }
  };

  const remove = async (id) => {
    try {
      await apiRequest(`/products/${id}`, { method: 'DELETE' });
      setMessage('Produk dihapus');
      loadData();
    } catch (err) {
      setMessage(err.message);
    }
  };

  return (
    <CrudLayout 
      title="Produk" 
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
            <Input label="Nama Produk" name="name" value={form.name} setForm={setForm} />
          </div>
          
          <Input label="Kategori" name="categoryId" type="select" value={form.categoryId} setForm={setForm} 
                 options={[{value: '', label: 'Pilih Kategori'}, ...categories.map(c => ({value: c.id, label: c.name}))]} />
          
          <Input label="Harga Normal" name="price" type="number" typeFormat="number" value={form.price} setForm={setForm} />
          <Input label="Harga Diskon" name="discountPrice" type="number" typeFormat="number" value={form.discountPrice} setForm={setForm} />
          <Input label="Stok" name="stock" type="number" typeFormat="number" value={form.stock} setForm={setForm} />
          <Input label="Satuan" name="unit" value={form.unit} setForm={setForm} />
          
          <div className="full-width">
            <Input label="URL Gambar Utama" name="imageUrl" value={form.imageUrl} setForm={setForm} hint="Disarankan: Rasio 1:1 (Persegi) resolusi tinggi (contoh: 800x800px)" />
          </div>
          <div className="full-width">
            <Input label="Deskripsi" name="description" type="textarea" value={form.description} setForm={setForm} />
          </div>
          
          <Input label="Tersedia" name="isAvailable" type="select" typeFormat="boolean" value={form.isAvailable} setForm={setForm} 
                 options={[{value: true, label: 'Ya'}, {value: false, label: 'Tidak'}]} />
          <Input label="Unggulan" name="isFeatured" type="select" typeFormat="boolean" value={form.isFeatured} setForm={setForm} 
                 options={[{value: true, label: 'Ya'}, {value: false, label: 'Tidak'}]} />
                 
          <div className="full-width mt-4">
            <button className="btn btn-primary" type="submit">
              {editingId ? 'Update Produk' : 'Tambah Produk'}
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
        columns={['ID', 'Nama', 'Harga', 'Stok', 'Kategori', 'Status']}
        data={data.map(item => ({
          ...item,
          'ID': item.id,
          'Nama': (
            <div style={{display:'flex', alignItems:'center', gap:'8px'}}>
              {item.imageUrl && <img src={item.imageUrl} alt="" height={30} width={30} style={{objectFit:'cover', borderRadius:'4px'}} />}
              {item.name}
            </div>
          ),
          'Harga': `Rp ${item.price?.toLocaleString('id-ID')}`,
          'Stok': `${item.stock} ${item.unit}`,
          'Kategori': categories.find(c => c.id === item.categoryId)?.name || '-',
          'Status': item.isAvailable ? <span className="badge success">Tersedia</span> : <span className="badge danger">Kosong</span>,
        }))}
        actions={(row) => (
          <RowActions
            onEdit={() => {
              const original = data.find(d => d.id === row.ID);
              if (original) {
                setEditingId(original.id);
                setForm({
                  name: original.name || '', description: original.description || '',
                  price: original.price || 0, discountPrice: original.discountPrice || 0,
                  imageUrl: original.imageUrl || '', images: original.images || '',
                  stock: original.stock || 0, isFeatured: original.isFeatured || false,
                  isAvailable: original.isAvailable || false, unit: original.unit || 'pcs',
                  categoryId: original.categoryId || ''
                });
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
