import React from 'react';

export default function Input({ label, name, type = 'text', value, setForm, typeFormat = 'string', options = [], hint }) {
  const handleChange = (e) => {
    let val = e.target.value;
    if (typeFormat === 'number' && val !== '') val = Number(val);
    if (typeFormat === 'boolean') val = val === 'true';
    
    setForm((prev) => ({ ...prev, [name]: val }));
  };

  return (
    <div className="input-group">
      <label>{label}</label>
      {type === 'textarea' ? (
        <textarea name={name} value={value} onChange={handleChange} rows={3} />
      ) : type === 'select' ? (
        <select name={name} value={value} onChange={handleChange}>
          {options.map((opt) => (
            <option key={opt.value} value={opt.value}>
              {opt.label}
            </option>
          ))}
        </select>
      ) : (
        <input name={name} type={type} value={value} onChange={handleChange} />
      )}
      {hint && <small style={{ color: 'var(--text-muted)', fontSize: '0.75rem', marginTop: '4px', display: 'block' }}>{hint}</small>}
    </div>
  );
}
