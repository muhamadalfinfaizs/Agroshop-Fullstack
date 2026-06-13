import React, { useState, useEffect } from 'react';
import { apiRequest } from '../utils/api';
import CrudLayout from '../components/CrudLayout';
import Input from '../components/Input';
import DataTable, { RowActions } from '../components/DataTable';

const emptyForm = { name: '', description: '', keywords: '', responseText: '', solution: '', recommendProduct: '' };

export default function ChatbotKnowledge() {
  const [data, setData] = useState([]);
  const [form, setForm] = useState(emptyForm);
  const [editingId, setEditingId] = useState(null);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');
  const [isFormVisible, setIsFormVisible] = useState(false);

  const loadData = async () => {
    try {
      const res = await apiRequest('/admin/chatbot/intents');
      setData(res.data || []);
    } catch (err) {
      setMessage(err.message);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const submit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setMessage('');
    try {
      const path = editingId ? `/admin/chatbot/intents/${editingId}` : '/admin/chatbot/intents';
      const method = editingId ? 'PUT' : 'POST';
      
      const payload = {
        name: form.name,
        description: form.description,
        keywords: form.keywords.split(',').map(k => k.trim()).filter(k => k),
        responseText: form.responseText,
        solution: form.solution,
        recommendProduct: form.recommendProduct
      };

      await apiRequest(path, { method, body: JSON.stringify(payload) });
      
      setForm(emptyForm);
      setEditingId(null);
      setIsFormVisible(false);
      setMessage(editingId ? 'Data berhasil diupdate' : 'Data berhasil ditambah');
      loadData();
    } catch (err) {
      setMessage(err.message);
    } finally {
      setLoading(false);
    }
  };

  const remove = async (id) => {
    try {
      await apiRequest(`/admin/chatbot/intents/${id}`, { method: 'DELETE' });
      setMessage('Data dihapus');
      loadData();
    } catch (err) {
      setMessage(err.message);
    }
  };

  return (
    <CrudLayout 
      title="Chatbot Knowledge" 
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
            <Input label="Nama Topik/Intent" name="name" value={form.name} setForm={setForm} hint="Misal: Hama Wereng, Info Pupuk Jagung" required />
          </div>
          <div className="full-width">
            <Input label="Keywords (pisahkan dengan koma)" name="keywords" value={form.keywords} setForm={setForm} hint="Misal: hama, wereng, padi" required />
          </div>
          <div className="full-width">
            <Input label="Teks Jawaban Chatbot" name="responseText" value={form.responseText} setForm={setForm} required />
          </div>
          <div className="full-width">
            <Input label="Rekomendasi Produk (Opsional)" name="recommendProduct" value={form.recommendProduct} setForm={setForm} hint="Masukkan kata pencarian produk, pisahkan koma. Misal: insektisida, wereng" />
          </div>
          <div className="full-width mt-4">
            <button className="btn btn-primary" type="submit">
              {editingId ? 'Update Intent' : 'Tambah Intent'}
            </button>
            {editingId && (
              <button 
                type="button" 
                className="btn btn-ghost" 
                style={{marginLeft: '8px'}}
                onClick={() => { setEditingId(null); setForm(emptyForm); setIsFormVisible(false); }}
              >
                Batal
              </button>
            )}
          </div>
        </form>
      }
    >
      <DataTable
        columns={['ID', 'Nama Topik', 'Keywords', 'Jawaban']}
        data={data.map(item => ({
          ...item,
          'ID': item.id,
          'Nama Topik': item.name,
          'Keywords': item.Keyword?.map(k => k.keyword).join(', ') || '-',
          'Jawaban': item.Response && item.Response.length > 0 ? (item.Response[0].text.substring(0, 50) + '...') : '-',
        }))}
        actions={(row) => (
          <RowActions
            onEdit={() => {
              const original = data.find(d => d.id === row.ID);
              if (original) {
                setEditingId(original.id);
                const resp = original.Response && original.Response.length > 0 ? original.Response[0] : {};
                setForm({ 
                  name: original.name || '', 
                  description: original.description || '', 
                  keywords: original.Keyword?.map(k => k.keyword).join(', ') || '',
                  responseText: resp.text || '',
                  solution: resp.solution || '',
                  recommendProduct: resp.recommendProduct || ''
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
