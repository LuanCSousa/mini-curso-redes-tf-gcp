# ==============================================================================
# Interconexão Privada — VPC Network Peering (labs/04-vpc-peering-hub/peering.tf)
# ==============================================================================
# AS 3 LEIS DE OURO DO VPC NETWORK PEERING NO GCP:
# 1. Proibição de CIDR Overlap: Nenhuma sub-rede da VPC A pode colidir com
#    nenhuma sub-rede da VPC B (por isso planejamos 10.<student_id>.0.0/24 e
#    10.0.1.0/24 / 10.0.2.0/24 desde o início da manhã!).
# 2. Acordo Bilateral (Handshake): A VPC do aluno solicita o Peering para o Hub
#    e o Hub Central aceita de volta apontando para a VPC do aluno. Enquanto os
#    dois lados não estiverem configurados, o estado fica `INACTIVE`. Quando os
#    dois lados fecham, o estado muda para `ACTIVE` e as rotas de sub-rede são
#    trocadas automaticamente na SDN Andromeda (zero latência extra!).
# 3. Não-Transitividade: Se Aluno 01 tem Peering com o Hub e Aluno 02 também tem
#    Peering com o Hub, Aluno 01 NÃO enxerga Aluno 02 (isolamento garantido).

resource "google_compute_network_peering" "peering_aluno_para_hub" {
  name = "peer-${local.student_suffix}-to-hub"

  # Nossa VPC local (Spoke):
  network = google_compute_network.vpc_aluno.self_link

  # VPC remota do Facilitador (Hub Turma A ou Turma B conforme student_id):
  peer_network = local.hub_vpc_self_link

  # Troca de rotas customizadas (além das rotas automáticas de sub-rede):
  export_custom_routes = false
  import_custom_routes = false
}
