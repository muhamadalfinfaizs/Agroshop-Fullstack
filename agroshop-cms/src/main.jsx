import React, { useEffect, useMemo, useState } from 'react';
import { createRoot } from 'react-dom/client';
import {
  API_BASE_URL,
  apiRequest,
  clearSession,
  getStoredSession,
  saveSession,
} from './api';
import './styles.css';

const emptyCategory = { name: '', icon: '', imageUrl: '' };
const emptyBanner = { title: '', subtitle: '', imageUrl: '' };
const emptyProduct = {
  name: '',
  description: '',
  price: '',
  discountPrice: '',
  imageUrl: '',
  images: '',
  stock: '',
  isFeatured: false,
  isAvailable: true,
  unit: 'pcs',
  categoryId: '',
};

const shipmentStatusOptions = [
  ['WAITING', 'Menunggu Diproses'],
  ['PACKED', 'Dikemas'],
  ['SHIPPED', 'Dikirim'],
  ['IN_TRANSIT', 'Dalam Perjalanan'],
  ['DELIVERED', 'Terkirim'],
  ['CANCELLED', 'Dibatalkan'],
];

function formatShipmentStatus(status) {
  return (
    shipmentStatusOptions.find(([value]) => value === status)?.[1] ??
    status ??
    '-'
  );
}

function App() {
  const [session, setSession] = useState(getStoredSession());
  const [activeTab, setActiveTab] = useState('dashboard');
  const [message, setMessage] = useState('');

  const isAdmin = session?.user?.role === 'ADMIN';

  function handleLogin(nextSession) {
    saveSession(nextSession);
    setSession(nextSession);
  }

  function handleLogout() {
    clearSession();
    setSession(null);
  }

  if (!session) {
    return <LoginScreen onLogin={handleLogin} />;
  }

  return (
    <div className="app-shell">
      <aside className="sidebar">
        <div>
          <p className="eyebrow">Agroshop</p>
          <h1>CMS Admin</h1>
          <p className="muted">Gateway: {API_BASE_URL}</p>
        </div>

        <nav className="nav-list">
          {[
            ['dashboard', 'Dashboard'],
            ['categories', 'Kategori'],
            ['products', 'Produk'],
            ['banners', 'Banner'],
            ['orders', 'Pesanan'],
            ['users', 'User'],
          ].map(([id, label]) => (
            <button
              className={activeTab === id ? 'nav-item active' : 'nav-item'}
              key={id}
              onClick={() => setActiveTab(id)}
              type="button"
            >
              {label}
            </button>
          ))}
        </nav>

        <div className="user-box">
          <strong>{session.user?.name}</strong>
          <span>{session.user?.email}</span>
          <button className="ghost-button" onClick={handleLogout} type="button">
            Keluar
          </button>
        </div>
      </aside>

      <main className="content">
        {!isAdmin && (
          <div className="notice danger">
            Akun ini bukan ADMIN. Data publik masih bisa dilihat, tetapi aksi
            tambah, edit, dan hapus akan ditolak backend.
          </div>
        )}

        {message && (
          <div className="notice" onClick={() => setMessage('')}>
            {message}
          </div>
        )}

        {activeTab === 'dashboard' && <Dashboard setActiveTab={setActiveTab} />}
        {activeTab === 'categories' && <CategoriesPanel setMessage={setMessage} />}
        {activeTab === 'products' && <ProductsPanel setMessage={setMessage} />}
        {activeTab === 'banners' && <BannersPanel setMessage={setMessage} />}
        {activeTab === 'orders' && <OrdersPanel setMessage={setMessage} />}
        {activeTab === 'users' && <UsersPanel />}
      </main>
    </div>
  );
}

function LoginScreen({ onLogin }) {
  const [email, setEmail] = useState('admin@agroshop.test');
  const [password, setPassword] = useState('admin123');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function submitLogin(event) {
    event.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await apiRequest('/auth/login', {
        method: 'POST',
        body: JSON.stringify({ email, password }),
      });

      onLogin({ token: response.token, user: response.user });
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="login-page">
      <section className="login-panel">
        <p className="eyebrow">Agroshop CMS</p>
        <h1>Masuk Admin</h1>
        <p className="muted">
          Gunakan akun dengan role ADMIN untuk mengelola produk, banner, dan
          pesanan.
        </p>

        <form className="form-grid" onSubmit={submitLogin}>
          <label>
            Email
            <input
              onChange={(event) => setEmail(event.target.value)}
              type="email"
              value={email}
            />
          </label>
          <label>
            Password
            <input
              onChange={(event) => setPassword(event.target.value)}
              type="password"
              value={password}
            />
          </label>
          {error && <div className="notice danger">{error}</div>}
          <button className="primary-button" disabled={loading} type="submit">
            {loading ? 'Memproses...' : 'Masuk'}
          </button>
        </form>
      </section>
    </main>
  );
}

function Dashboard({ setActiveTab }) {
  const cards = [
    ['Kategori', 'Kelola kelompok produk', 'categories'],
    ['Produk', 'Tambah dan ubah data produk', 'products'],
    ['Banner', 'Atur banner promosi', 'banners'],
    ['Pesanan', 'Pantau order dan pengiriman', 'orders'],
  ];

  return (
    <section>
      <div className="page-header">
        <div>
          <p className="eyebrow">Dashboard</p>
          <h2>Ringkasan CMS</h2>
        </div>
      </div>
      <div className="summary-grid">
        {cards.map(([title, desc, tab]) => (
          <button
            className="summary-card"
            key={title}
            onClick={() => setActiveTab(tab)}
            type="button"
          >
            <strong>{title}</strong>
            <span>{desc}</span>
          </button>
        ))}
      </div>
    </section>
  );
}

function CategoriesPanel({ setMessage }) {
  const [categories, setCategories] = useState([]);
  const [form, setForm] = useState(emptyCategory);
  const [editingId, setEditingId] = useState(null);
  const [loading, setLoading] = useState(false);

  async function loadCategories() {
    setLoading(true);
    try {
      const response = await apiRequest('/categories');
      setCategories(response.data ?? []);
    } catch (err) {
      setCategories([]);
      setMessage(err.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadCategories();
  }, []);

  async function submit(event) {
    event.preventDefault();
    const path = editingId ? `/categories/${editingId}` : '/categories';
    const method = editingId ? 'PATCH' : 'POST';

    await apiRequest(path, {
      method,
      body: JSON.stringify(form),
    });

    setForm(emptyCategory);
    setEditingId(null);
    setMessage(editingId ? 'Kategori diperbarui' : 'Kategori ditambahkan');
    loadCategories();
  }

  async function remove(id) {
    await apiRequest(`/categories/${id}`, { method: 'DELETE' });
    setMessage('Kategori dihapus');
    loadCategories();
  }

  return (
    <CrudLayout
      form={
        <form className="form-grid" onSubmit={submit}>
          <Input label="Nama" name="name" setForm={setForm} value={form.name} />
          <Input label="Icon" name="icon" setForm={setForm} value={form.icon} />
          <Input
            label="Image URL"
            name="imageUrl"
            setForm={setForm}
            value={form.imageUrl}
          />
          <button className="primary-button" type="submit">
            {editingId ? 'Update Kategori' : 'Tambah Kategori'}
          </button>
        </form>
      }
      loading={loading}
      title="Kategori"
    >
      <DataTable
        actions={(item) => (
          <RowActions
            onDelete={() => remove(item.id)}
            onEdit={() => {
              setEditingId(item.id);
              setForm({
                name: item.name ?? '',
                icon: item.icon ?? '',
                imageUrl: item.imageUrl ?? '',
              });
            }}
          />
        )}
        columns={[
          ['name', 'Nama'],
          ['icon', 'Icon'],
          ['productCount', 'Produk'],
        ]}
        rows={categories}
      />
    </CrudLayout>
  );
}

function ProductsPanel({ setMessage }) {
  const [products, setProducts] = useState([]);
  const [categories, setCategories] = useState([]);
  const [form, setForm] = useState(emptyProduct);
  const [editingId, setEditingId] = useState(null);
  const [loading, setLoading] = useState(false);

  async function loadData() {
    setLoading(true);
    try {
      const [productResponse, categoryResponse] = await Promise.all([
        apiRequest('/products'),
        apiRequest('/categories'),
      ]);
      setProducts(productResponse.data ?? []);
      setCategories(categoryResponse.data ?? []);
    } catch (err) {
      setMessage(err.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadData();
  }, []);

  const productPayload = useMemo(
    () => ({
      ...form,
      price: Number(form.price),
      discountPrice: form.discountPrice ? Number(form.discountPrice) : undefined,
      images: form.images
        .split(',')
        .map((item) => item.trim())
        .filter(Boolean),
      stock: Number(form.stock),
      categoryId: Number(form.categoryId),
    }),
    [form],
  );

  async function submit(event) {
    event.preventDefault();
    const path = editingId ? `/products/${editingId}` : '/products';
    const method = editingId ? 'PATCH' : 'POST';

    await apiRequest(path, {
      method,
      body: JSON.stringify(productPayload),
    });

    setForm(emptyProduct);
    setEditingId(null);
    setMessage(editingId ? 'Produk diperbarui' : 'Produk ditambahkan');
    loadData();
  }

  async function remove(id) {
    await apiRequest(`/products/${id}`, { method: 'DELETE' });
    setMessage('Produk dihapus');
    loadData();
  }

  return (
    <CrudLayout
      form={
        <form className="form-grid two-cols" onSubmit={submit}>
          <Input label="Nama" name="name" setForm={setForm} value={form.name} />
          <label>
            Kategori
            <select
              onChange={(event) =>
                setForm((current) => ({
                  ...current,
                  categoryId: event.target.value,
                }))
              }
              value={form.categoryId}
            >
              <option value="">Pilih kategori</option>
              {categories.map((category) => (
                <option key={category.id} value={category.id}>
                  {category.name}
                </option>
              ))}
            </select>
          </label>
          <Input label="Harga" name="price" setForm={setForm} type="number" value={form.price} />
          <Input
            label="Harga Diskon"
            name="discountPrice"
            setForm={setForm}
            type="number"
            value={form.discountPrice}
          />
          <Input label="Stok" name="stock" setForm={setForm} type="number" value={form.stock} />
          <Input label="Satuan" name="unit" setForm={setForm} value={form.unit} />
          <Input
            label="Image URL"
            name="imageUrl"
            setForm={setForm}
            value={form.imageUrl}
          />
          <Input
            label="Images lain, pisah koma"
            name="images"
            setForm={setForm}
            value={form.images}
          />
          <label className="full-width">
            Deskripsi
            <textarea
              onChange={(event) =>
                setForm((current) => ({
                  ...current,
                  description: event.target.value,
                }))
              }
              rows="4"
              value={form.description}
            />
          </label>
          <label className="check-row">
            <input
              checked={form.isFeatured}
              onChange={(event) =>
                setForm((current) => ({
                  ...current,
                  isFeatured: event.target.checked,
                }))
              }
              type="checkbox"
            />
            Featured
          </label>
          <label className="check-row">
            <input
              checked={form.isAvailable}
              onChange={(event) =>
                setForm((current) => ({
                  ...current,
                  isAvailable: event.target.checked,
                }))
              }
              type="checkbox"
            />
            Tersedia
          </label>
          <button className="primary-button full-width" type="submit">
            {editingId ? 'Update Produk' : 'Tambah Produk'}
          </button>
        </form>
      }
      loading={loading}
      title="Produk"
    >
      <DataTable
        actions={(item) => (
          <RowActions
            onDelete={() => remove(item.id)}
            onEdit={() => {
              setEditingId(item.id);
              setForm({
                name: item.name ?? '',
                description: item.description ?? '',
                price: item.price ?? '',
                discountPrice: item.discountPrice ?? '',
                imageUrl: item.imageUrl ?? '',
                images: (item.images ?? []).join(', '),
                stock: item.stock ?? '',
                isFeatured: Boolean(item.isFeatured),
                isAvailable: item.isAvailable ?? true,
                unit: item.unit ?? 'pcs',
                categoryId: item.categoryId ?? '',
              });
            }}
          />
        )}
        columns={[
          ['name', 'Nama'],
          ['categoryName', 'Kategori'],
          ['price', 'Harga'],
          ['stock', 'Stok'],
        ]}
        rows={products}
      />
    </CrudLayout>
  );
}

function BannersPanel({ setMessage }) {
  const [banners, setBanners] = useState([]);
  const [form, setForm] = useState(emptyBanner);
  const [editingId, setEditingId] = useState(null);

  async function loadBanners() {
    try {
      const response = await apiRequest('/banners');
      setBanners(response.data ?? []);
    } catch (err) {
      setBanners([]);
      setMessage(err.message);
    }
  }

  useEffect(() => {
    loadBanners();
  }, []);

  async function submit(event) {
    event.preventDefault();
    const path = editingId ? `/banners/${editingId}` : '/banners';
    const method = editingId ? 'PATCH' : 'POST';

    await apiRequest(path, {
      method,
      body: JSON.stringify(form),
    });

    setForm(emptyBanner);
    setEditingId(null);
    setMessage(editingId ? 'Banner diperbarui' : 'Banner ditambahkan');
    loadBanners();
  }

  async function remove(id) {
    await apiRequest(`/banners/${id}`, { method: 'DELETE' });
    setMessage('Banner dihapus');
    loadBanners();
  }

  return (
    <CrudLayout
      form={
        <form className="form-grid" onSubmit={submit}>
          <Input label="Judul" name="title" setForm={setForm} value={form.title} />
          <Input
            label="Subtitle"
            name="subtitle"
            setForm={setForm}
            value={form.subtitle}
          />
          <Input
            label="Image URL"
            name="imageUrl"
            setForm={setForm}
            value={form.imageUrl}
          />
          <button className="primary-button" type="submit">
            {editingId ? 'Update Banner' : 'Tambah Banner'}
          </button>
        </form>
      }
      title="Banner"
    >
      <DataTable
        actions={(item) => (
          <RowActions
            onDelete={() => remove(item.id)}
            onEdit={() => {
              setEditingId(item.id);
              setForm({
                title: item.title ?? '',
                subtitle: item.subtitle ?? '',
                imageUrl: item.imageUrl ?? '',
              });
            }}
          />
        )}
        columns={[
          ['title', 'Judul'],
          ['subtitle', 'Subtitle'],
        ]}
        rows={banners}
      />
    </CrudLayout>
  );
}

function OrdersPanel({ setMessage }) {
  const [orders, setOrders] = useState([]);
  const [selectedOrder, setSelectedOrder] = useState(null);
  const [shipmentForm, setShipmentForm] = useState({
    courier: '',
    trackingNumber: '',
    status: 'PACKED',
  });

  async function loadOrders() {
    try {
      const response = await apiRequest('/orders/admin/all');
      setOrders(response.data ?? []);
    } catch (err) {
      setMessage(err.message);
    }
  }

  useEffect(() => {
    loadOrders();
  }, []);

  async function updateShipment(event) {
    event.preventDefault();
    if (!selectedOrder) return;

    await apiRequest(`/shipments/orders/${selectedOrder.id}`, {
      method: 'PATCH',
      body: JSON.stringify(shipmentForm),
    });

    await apiRequest(`/shipments/orders/${selectedOrder.id}/events`, {
      method: 'POST',
      body: JSON.stringify({
        title: `Status diperbarui menjadi ${formatShipmentStatus(
          shipmentForm.status,
        )}`,
        description: `Kurir ${shipmentForm.courier || '-'} dengan resi ${
          shipmentForm.trackingNumber || '-'
        }`,
        status: shipmentForm.status,
      }),
    });

    setMessage('Pengiriman diperbarui');
    loadOrders();
  }

  return (
    <section>
      <div className="page-header">
        <div>
          <p className="eyebrow">Operasional</p>
          <h2>Pesanan</h2>
        </div>
        <button className="secondary-button" onClick={loadOrders} type="button">
          Refresh
        </button>
      </div>

      <div className="split-grid">
        <DataTable
          actions={(item) => (
            <button
              className="secondary-button"
              onClick={() => {
                setSelectedOrder(item);
                setShipmentForm({
                  courier: item.shipment?.courier ?? '',
                  trackingNumber: item.shipment?.trackingNumber ?? '',
                  status: item.shipment?.status ?? 'PACKED',
                });
              }}
              type="button"
            >
              Pengiriman
            </button>
          )}
          columns={[
            ['id', 'Order'],
            ['status', 'Status'],
            ['total', 'Total'],
            ['shippingAddress', 'Alamat'],
          ]}
          rows={orders}
        />

        <aside className="panel">
          <h3>Update Pengiriman</h3>
          {selectedOrder ? (
            <form className="form-grid" onSubmit={updateShipment}>
              <p className="muted">Order {selectedOrder.id}</p>
              <Input
                label="Kurir"
                name="courier"
                setForm={setShipmentForm}
                value={shipmentForm.courier}
              />
              <Input
                label="Nomor Resi"
                name="trackingNumber"
                setForm={setShipmentForm}
                value={shipmentForm.trackingNumber}
              />
              <label>
                Status
                <select
                  onChange={(event) =>
                    setShipmentForm((current) => ({
                      ...current,
                      status: event.target.value,
                    }))
                  }
              value={shipmentForm.status}
            >
                  {shipmentStatusOptions.map(([value, label]) => (
                    <option key={value} value={value}>
                      {label}
                    </option>
                  ))}
                </select>
              </label>
              <button className="primary-button" type="submit">
                Simpan Pengiriman
              </button>
            </form>
          ) : (
            <p className="muted">Pilih pesanan dari tabel.</p>
          )}
        </aside>
      </div>
    </section>
  );
}

function UsersPanel() {
  const [users, setUsers] = useState([]);
  const [error, setError] = useState('');

  useEffect(() => {
    apiRequest('/users')
      .then((response) => setUsers(response.data ?? []))
      .catch((err) => setError(err.message));
  }, []);

  return (
    <section>
      <div className="page-header">
        <div>
          <p className="eyebrow">Admin</p>
          <h2>User</h2>
        </div>
      </div>
      {error && <div className="notice danger">{error}</div>}
      <DataTable
        columns={[
          ['name', 'Nama'],
          ['email', 'Email'],
          ['phone', 'Telepon'],
          ['address', 'Alamat'],
        ]}
        rows={users}
      />
    </section>
  );
}

function CrudLayout({ children, form, loading, title }) {
  return (
    <section>
      <div className="page-header">
        <div>
          <p className="eyebrow">Master Data</p>
          <h2>{title}</h2>
        </div>
      </div>
      <div className="split-grid">
        <div>{loading ? <div className="notice">Memuat data...</div> : children}</div>
        <aside className="panel">
          <h3>Form {title}</h3>
          {form}
        </aside>
      </div>
    </section>
  );
}

function DataTable({ actions, columns, rows }) {
  return (
    <div className="table-wrap">
      <table>
        <thead>
          <tr>
            {columns.map(([, label]) => (
              <th key={label}>{label}</th>
            ))}
            {actions && <th>Aksi</th>}
          </tr>
        </thead>
        <tbody>
          {rows.length === 0 && (
            <tr>
              <td colSpan={columns.length + (actions ? 1 : 0)}>Belum ada data.</td>
            </tr>
          )}
          {rows.map((row) => (
            <tr key={row.id}>
              {columns.map(([key]) => (
                <td key={key}>{formatCell(row[key])}</td>
              ))}
              {actions && <td>{actions(row)}</td>}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function RowActions({ onDelete, onEdit }) {
  return (
    <div className="row-actions">
      <button className="secondary-button" onClick={onEdit} type="button">
        Edit
      </button>
      <button className="danger-button" onClick={onDelete} type="button">
        Hapus
      </button>
    </div>
  );
}

function Input({ label, name, setForm, type = 'text', value }) {
  return (
    <label>
      {label}
      <input
        onChange={(event) =>
          setForm((current) => ({ ...current, [name]: event.target.value }))
        }
        type={type}
        value={value}
      />
    </label>
  );
}

function formatCell(value) {
  if (value === null || value === undefined || value === '') return '-';
  if (typeof value === 'number') return value.toLocaleString('id-ID');
  if (typeof value === 'boolean') return value ? 'Ya' : 'Tidak';
  return String(value);
}

createRoot(document.getElementById('root')).render(<App />);
