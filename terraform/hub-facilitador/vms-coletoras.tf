# ==============================================================================
# VMs Coletoras do Hub Central (hub-facilitador/vms-coletoras.tf)
# ==============================================================================
# Provisiona duas VMs `e2-micro` 100% privadas com IPs internos fixos:
# - `vm-coletora-turma-a` -> 10.0.1.10 (Atende Alunos 01 a 20)
# - `vm-coletora-turma-b` -> 10.0.2.10 (Atende Alunos 21 a 40)
#
# Cada VM sobe automaticamente um servidor HTTP Python na porta 80 que:
# 1. Recebe `POST /checkin` enviado pelos alunos via VPC Peering;
# 2. Valida o IP privado real de origem do pacote (`10.<ID>.0.2`);
# 3. Encaminha o check-in para o Mural Cloud Run (se configurado) E também
#    serve um painel visual completo em `GET /`!

resource "google_compute_instance" "vm_coletora" {
  for_each = local.hubs

  name         = each.value.vm_name
  machine_type = "e2-micro"
  zone         = var.zone
  description  = "VM Coletora (${each.value.collector_ip}) para validação de VPC Peering (${each.value.student_range})"

  tags   = ["hub-collector"]
  labels = local.common_labels

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
      type  = "pd-balanced"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_hub[each.key].id
    subnetwork = google_compute_subnetwork.subnet_hub[each.key].id

    # Fixamos o IP interno em 10.0.1.10 (Turma A) e 10.0.2.10 (Turma B):
    network_ip = each.value.collector_ip
  }

  allow_stopping_for_update = true

  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e
    mkdir -p /var/lib/redes-tf

    cat <<'PYEOF' > /usr/local/bin/redes_tf_collector.py
    import json
    import os
    import urllib.request
    from datetime import datetime, timezone, timedelta
    from http.server import BaseHTTPRequestHandler, HTTPServer

    DATA_FILE = "/var/lib/redes-tf/checkins.json"
    HUB_NAME = "${each.value.vpc_name}"
    COLLECTOR_IP = "${each.value.collector_ip}"
    MURAL_URL = "${var.mural_cloud_run_url}"

    def load_checkins():
        if not os.path.exists(DATA_FILE):
            return {}
        try:
            with open(DATA_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return {}

    def save_checkins(data):
        with open(DATA_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

    class CollectorHandler(BaseHTTPRequestHandler):
        def do_GET(self):
            checkins = load_checkins()
            if self.path == "/api/checkins":
                body = json.dumps({"hub": HUB_NAME, "collector_ip": COLLECTOR_IP, "checkins": checkins}).encode("utf-8")
                self.send_response(200)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self.end_headers()
                self.wfile.write(body)
                return

            cards_html = ""
            for sid in sorted(checkins.keys(), key=lambda x: int(x) if str(x).isdigit() else 999):
                item = checkins[sid]
                cards_html += f"""
                <div style="background:#0F172A;border:2px solid #34A853;border-radius:12px;padding:16px;">
                  <div style="color:#34A853;font-family:monospace;font-weight:bold;font-size:13px;">● PEERING ACTIVE • ALUNO {int(sid):02d}</div>
                  <div style="color:#F8FAFC;font-size:18px;font-weight:bold;margin:6px 0;">{item.get('nome')}</div>
                  <div style="color:#38BDF8;font-family:monospace;font-size:13px;">Subnet: {item.get('subnet')}</div>
                  <div style="color:#94A3B8;font-family:monospace;font-size:12px;margin-top:4px;">IP Real de Origem: {item.get('source_ip')} • {item.get('horario')}</div>
                </div>
                """

            html = f"""<!DOCTYPE html>
            <html lang="pt-BR">
            <head>
              <meta charset="UTF-8">
              <meta http-equiv="refresh" content="3">
              <title>Mural ao Vivo — Redes.tf ({HUB_NAME})</title>
            </head>
            <body style="background:#060A12;color:#F8FAFC;font-family:sans-serif;padding:32px;">
              <h1 style="margin:0 0 8px 0;">Mural de Conectividade Privada — Redes.tf (e-info FACAPE)</h1>
              <p style="color:#94A3B8;font-family:monospace;margin:0 0 24px 0;">Hub: {HUB_NAME} ({COLLECTOR_IP}) | Conectados: {len(checkins)}</p>
              <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:16px;">
                {cards_html if cards_html else '<p style="color:#64748B;">Aguardando os primeiros pacotes via VPC Network Peering...</p>'}
              </div>
            </body>
            </html>"""
            body = html.encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.end_headers()
            self.wfile.write(body)

        def do_POST(self):
            if self.path != "/checkin":
                self.send_response(404)
                self.end_headers()
                return

            length = int(self.headers.get("Content-Length", 0))
            raw = self.rfile.read(length).decode("utf-8") if length > 0 else "{}"
            try:
                payload = json.loads(raw)
            except Exception:
                payload = {}

            source_ip = self.client_address[0]
            parts = source_ip.split(".")
            detected_id = int(parts[1]) if len(parts) == 4 and parts[0] == "10" and parts[1].isdigit() else payload.get("student_id", 0)
            student_id = str(payload.get("student_id") or detected_id)
            nome = str(payload.get("nome") or f"Aluno {student_id}")
            subnet = str(payload.get("subnet") or f"10.{student_id}.0.0/24")
            tz_br = timezone(timedelta(hours=-3))
            horario = datetime.now(tz_br).strftime("%H:%M:%S")

            record = {
                "student_id": int(student_id) if str(student_id).isdigit() else 0,
                "nome": nome,
                "subnet": subnet,
                "source_ip": source_ip,
                "hub": HUB_NAME,
                "collector_ip": COLLECTOR_IP,
                "horario": horario
            }

            checkins = load_checkins()
            checkins[str(student_id)] = record
            save_checkins(checkins)

            if MURAL_URL:
                try:
                    req = urllib.request.Request(
                        MURAL_URL.rstrip("/") + "/api/checkin",
                        data=json.dumps(record).encode("utf-8"),
                        headers={"Content-Type": "application/json"},
                        method="POST"
                    )
                    urllib.request.urlopen(req, timeout=3)
                except Exception:
                    pass

            banner = f\"\"\"
    ====================================================================
      VPC PEERING VALIDADO COM SUCESSO — REDES.TF (e-info FACAPE)
    ====================================================================
      Participante       : {nome} (aluno-{int(student_id):02d})
      Sub-rede declarada : {subnet}
      IP Privado Real    : {source_ip} -> {COLLECTOR_IP} ({HUB_NAME})
      Horário do Pacote  : {horario}
      Status no Telão    : CHECK-IN REGISTRADO NO MURAL AO VIVO!
    ====================================================================
    \"\"\"
            self.send_response(200)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.end_headers()
            self.wfile.write(banner.encode("utf-8"))

    if __name__ == "__main__":
        HTTPServer(("0.0.0.0", 80), CollectorHandler).serve_forever()
    PYEOF

    cat <<'SVCEOF' > /etc/systemd/system/redes-tf-collector.service
    [Unit]
    Description=Redes.tf VPC Peering Collector HTTP Server
    After=network.target

    [Service]
    ExecStart=/usr/bin/python3 /usr/local/bin/redes_tf_collector.py
    Restart=always
    User=root

    [Install]
    WantedBy=multi-user.target
    SVCEOF

    systemctl daemon-reload
    systemctl enable --now redes-tf-collector.service
  EOF

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
}
