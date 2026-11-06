import json
import os
from datetime import datetime, timezone, timedelta
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = int(os.environ.get("PORT", "8080"))
CHECKINS = {}


class MuralHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/api/checkins":
            body = json.dumps({"total": len(CHECKINS), "checkins": CHECKINS}).encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.end_headers()
            self.wfile.write(body)
            return

        cards = ""
        for sid in range(1, 41):
            key = str(sid)
            hub_label = "vpc-hub-turma-a (10.0.1.10)" if sid <= 20 else "vpc-hub-turma-b (10.0.2.10)"
            if key in CHECKINS:
                item = CHECKINS[key]
                cards += f"""
                <div class="card active">
                  <div class="badge">● ACTIVE • ALUNO {sid:02d}</div>
                  <div class="name">{item.get('nome')}</div>
                  <div class="meta">Subnet: {item.get('subnet')} | Origem: {item.get('source_ip')}</div>
                  <div class="hub">{item.get('hub')} • {item.get('horario')}</div>
                </div>"""
            else:
                cards += f"""
                <div class="card pending">
                  <div class="badge-pending">○ AGUARDANDO • ALUNO {sid:02d}</div>
                  <div class="name">10.{sid}.0.0/24</div>
                  <div class="hub">{hub_label}</div>
                </div>"""

        html = f"""<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="refresh" content="3">
  <title>Mural ao Vivo — Redes.tf (e-info FACAPE)</title>
  <style>
    body {{ background:#060A12; color:#F8FAFC; font-family:system-ui,sans-serif; margin:0; padding:24px 32px; }}
    .header {{ display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; border-bottom:1px solid #1E293B; padding-bottom:14px; }}
    h1 {{ margin:0; font-size:26px; }}
    .counter {{ background:rgba(52,168,83,0.15); border:1px solid #34A853; color:#4ADE80; padding:8px 16px; border-radius:999px; font-family:monospace; font-size:16px; font-weight:bold; }}
    .grid {{ display:grid; grid-template-columns:repeat(8, 1fr); gap:10px; }}
    .card {{ border-radius:10px; padding:10px 12px; font-size:12px; }}
    .card.active {{ background:rgba(22,101,52,0.22); border:1.5px solid #34A853; }}
    .card.pending {{ background:#0D1526; border:1px dashed #1E293B; opacity:0.65; }}
    .badge {{ color:#4ADE80; font-family:monospace; font-weight:bold; font-size:11px; }}
    .badge-pending {{ color:#64748B; font-family:monospace; font-size:11px; }}
    .name {{ font-weight:bold; font-size:13px; margin:4px 0; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }}
    .meta {{ color:#38BDF8; font-family:monospace; font-size:10.5px; }}
    .hub {{ color:#94A3B8; font-family:monospace; font-size:10px; margin-top:3px; }}
  </style>
</head>
<body>
  <div class="header">
    <div>
      <h1>Redes<span style="color:#A78BFA;">.tf</span> — Mural de Conectividade Privada (VPC Peering)</h1>
      <div style="color:#94A3B8;font-family:monospace;font-size:13px;margin-top:4px;">e-info • FACAPE | Facilitador: Luan Sousa | Turma A (10.0.1.10) & Turma B (10.0.2.10)</div>
    </div>
    <div class="counter">{len(CHECKINS)} / 40 Redes Conectadas</div>
  </div>
  <div class="grid">{cards}</div>
</body>
</html>"""
        body = html.encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        if self.path != "/api/checkin":
            self.send_response(404)
            self.end_headers()
            return
        length = int(self.headers.get("Content-Length", 0))
        raw = self.rfile.read(length).decode("utf-8") if length > 0 else "{}"
        payload = json.loads(raw)
        sid = str(payload.get("student_id", "0"))
        tz_br = timezone(timedelta(hours=-3))
        payload.setdefault("horario", datetime.now(tz_br).strftime("%H:%M:%S"))
        CHECKINS[sid] = payload
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(b'{"status":"ok"}')


if __name__ == "__main__":
    HTTPServer(("0.0.0.0", PORT), MuralHandler).serve_forever()
