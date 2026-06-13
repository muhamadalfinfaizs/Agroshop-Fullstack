import React from 'react';

export default function CrudLayout({ title, loading, form, children, isFormVisible, onToggleForm }) {
  return (
    <section>
      <div className="page-header">
        <div>
          <h2>{title}</h2>
        </div>
        <div>
          {onToggleForm && (
            <button className="btn btn-primary" onClick={onToggleForm}>
              {isFormVisible ? 'Tutup Form' : `Tambah ${title}`}
            </button>
          )}
        </div>
      </div>

      <div style={{ display: 'flex', gap: '24px', alignItems: 'flex-start', flexWrap: 'wrap' }}>
        {/* Form Panel */}
        {isFormVisible && (
          <div className="card" style={{ flex: '1 1 350px', position: 'sticky', top: '24px' }}>
            <h3 style={{ marginBottom: '16px', fontSize: '1.1rem' }}>Form {title}</h3>
            {form}
            {loading && <div style={{ marginTop: '12px', color: 'var(--primary)', fontSize: '0.85rem' }}>Memproses...</div>}
          </div>
        )}
        
        {/* Data Panel */}
        <div className="card" style={{ flex: '2 1 500px' }}>
          <h3 style={{ marginBottom: '16px', fontSize: '1.1rem' }}>Daftar {title}</h3>
          {children}
        </div>
      </div>
    </section>
  );

}

