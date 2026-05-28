import React from 'react';
import { Pencil, Trash2 } from 'lucide-react';

export default function DataTable({ columns, data, actions }) {
  if (!data || data.length === 0) {
    return (
      <div className="card" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-muted)' }}>
        Belum ada data yang ditambahkan.
      </div>
    );
  }

  return (
    <div className="table-container">
      <table className="data-table">
        <thead>
          <tr>
            {columns.map((col, idx) => (
              <th key={idx}>{col}</th>
            ))}
            {actions && <th>Aksi</th>}
          </tr>
        </thead>
        <tbody>
          {data.map((row, idx) => (
            <tr key={idx}>
              {columns.map((col, cIdx) => (
                <td key={cIdx}>{row[col]}</td>
              ))}
              {actions && <td>{actions(row)}</td>}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export function RowActions({ onEdit, onDelete }) {
  return (
    <div className="flex-row">
      {onEdit && (
        <button className="btn btn-ghost" style={{ padding: '6px' }} onClick={onEdit} title="Edit">
          <Pencil size={18} color="var(--primary)" />
        </button>
      )}
      {onDelete && (
        <button className="btn btn-ghost" style={{ padding: '6px' }} onClick={() => {
          if(window.confirm('Yakin ingin menghapus data ini?')) {
            onDelete();
          }
        }} title="Hapus">
          <Trash2 size={18} color="var(--danger)" />
        </button>
      )}
    </div>
  );
}
