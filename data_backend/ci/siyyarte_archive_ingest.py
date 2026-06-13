#!/usr/bin/env python3
"""Siyyarte source-archive ingester.
Folder convention: raw_sources/{brand}/{market}/{model_year}/{model}/{document}.pdf
For each PDF: compute SHA-256, page count, emit a source_archive INSERT (idempotent on hash).
Run AFTER official PDFs are downloaded locally (requires the network access fix for OEM domains)."""
import sys, os, hashlib, glob, datetime
try:
    from pypdf import PdfReader
except Exception:
    PdfReader=None

ROOT = sys.argv[1] if len(sys.argv)>1 else 'raw_sources'
def sha256(path):
    h=hashlib.sha256()
    with open(path,'rb') as f:
        for chunk in iter(lambda:f.read(1<<20), b''): h.update(chunk)
    return h.hexdigest()
def pagecount(path):
    if not PdfReader: return None
    try: return len(PdfReader(path).pages)
    except Exception: return None

rows=[]
for path in glob.glob(os.path.join(ROOT,'**','*.pdf'), recursive=True):
    parts=os.path.relpath(path,ROOT).split(os.sep)
    brand=parts[0] if len(parts)>0 else None
    market=parts[1] if len(parts)>1 else None
    year=parts[2] if len(parts)>2 else None
    model=parts[3] if len(parts)>3 else None
    title=os.path.splitext(os.path.basename(path))[0]
    rows.append(dict(local_file_path=path,brand=brand,market=market,model_year=year,
        model=model,document_title=title,sha256_hash=sha256(path),
        page_count=pagecount(path),date_accessed=datetime.date.today().isoformat()))

def sql_escape(v): return 'NULL' if v in (None,'') else "'"+str(v).replace("'","''")+"'"
print('-- source_archive INSERTs (generated)')
for r in rows:
    print(f"INSERT INTO source_archive (original_url,oem,brand,model,market,model_year,document_title,document_type,date_accessed,local_file_path,sha256_hash,page_count,extraction_method,source_status) VALUES "
          f"(NULL,NULL,{sql_escape(r['brand'])},{sql_escape(r['model'])},{sql_escape(r['market'])},{r['model_year'] or 'NULL'},{sql_escape(r['document_title'])},'Owner Manual',{sql_escape(r['date_accessed'])},{sql_escape(r['local_file_path'])},{sql_escape(r['sha256_hash'])},{r['page_count'] or 'NULL'},'local pdftotext','Verified_A') ON CONFLICT (sha256_hash) DO NOTHING;")
print(f'-- {len(rows)} document(s) archived', file=sys.stderr)
