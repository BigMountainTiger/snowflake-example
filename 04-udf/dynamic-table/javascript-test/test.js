s = '~:4ab-c-;d@@@v@';

s = s.replace(/[^a-zA-Z0-9]/g, '_');
s = s.replace(/_+/g, '_');
s = s.replace(/^_/, '');
s = s.replace(/_$/,'');

if (/^[0-9]/.test(s)) {
  s = `COLUMN_${s}`;
}

console.log(s);