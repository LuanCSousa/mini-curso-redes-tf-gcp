const pptxgen = require('pptxgenjs');
const PDFDocument = require('pdfkit');
const fs = require('fs');
const path = require('path');

const OUT_DIR = path.join(__dirname, 'exportados');
if (!fs.existsSync(OUT_DIR)) {
  fs.mkdirSync(OUT_DIR, { recursive: true });
}

const LOGO_EINFO_PATH = path.join(__dirname, 'assets', 'logo-einfo.png');
const FOTO_PERFIL_PATH = path.join(__dirname, 'assets', 'foto-perfil.jpeg');

const C = {
  BG_DARK: '0B1120',
  BG_CARD: '131C31',
  BG_CODE: '080D1A',
  BORDER: '293548',
  TEXT_MAIN: 'F8FAFC',
  TEXT_SUB: 'CBD5E1',
  TEXT_MUTED: '94A3B8',
  BLUE: '3B82F6',
  CYAN: '38BDF8',
  GREEN: '10B981',
  AMBER: 'F59E0B',
  PURPLE: '8B5CF6'
};

// ============================================================================
// DEFINIÇÃO COMPLETA DOS 16 SLIDES — TURNO DA MANHÃ (08H00–12H00)
// ============================================================================
const MORNING_SLIDES = [
  {
    isCover: true,
    eyebrow: 'E-INFO • FACAPE • TURNO DA MANHÃ (08H00–12H00)',
    title: 'Redes.tf: da Teoria à Prática com Terraform e GCP',
    subtitle: 'Um mergulho 100% prático nos fundamentos de VPC, Sub-redes, CIDR, Firewalls, Cloud IAP, Cloud NAT e VPC Peering construídos como código do zero ao fim.',
    footerHighlight: 'Facilitador: Luan Sousa — Cloud Engineer @ SantoDigital | Google Cloud Digital Leader | CC FACAPE',
    accent: C.BLUE
  },
  {
    eyebrow: '02 • Boas-vindas e Metodologia',
    title: 'Quem vai guiar essa jornada e como vamos trabalhar',
    left: {
      title: 'Facilitador: Luan Sousa',
      accent: C.BLUE,
      hasFacilitatorPhoto: true,
      bullets: [
        'Cloud Engineer na SantoDigital (Parceira Premier Google Cloud).',
        'Atuação prática em Fullstack, DevOps, Infraestrutura e SecOps.',
        'Certificado Google Cloud Digital Leader.',
        'Bacharelando em Ciência da Computação pela FACAPE.',
        'Foco em conectar a teoria clássica de redes com engenharia real.'
      ]
    },
    right: {
      title: 'Regra de Ouro: 100% Live Coding',
      accent: C.GREEN,
      bullets: [
        'Zero ClickOps: não criamos recursos clicando em botões no painel.',
        'Construção do zero ao fim em terraform/live-coding/.',
        'Checkpoints prontos em terraform/labs/ caso alguém atrase.',
        'Evolução de recursos nativos (Labs 01–04) até Módulos (Lab 05).'
      ]
    }
  },
  {
    eyebrow: '03 • Cronograma Oficial (8 Horas)',
    title: 'Nossa Trilha de Construção: Manhã vs. Tarde',
    left: {
      title: 'Manhã (08h00 – 12h00): Fundação e Segurança',
      accent: C.BLUE,
      bullets: [
        '08h00–09h00 (M1): IPv4, CIDR /24, IPs reservados e SDN Andromeda.',
        '09h00–09h50 (M2): Terraform do Zero (Providers, State e Setup).',
        '10h10–11h00 (M3): Lab 01 — VPC Customizada e Sub-rede Regional.',
        '11h00–12h00 (M4): Lab 02 — Firewall Stateful, IAP e VM Privada.'
      ]
    },
    right: {
      title: 'Tarde (14h00 – 18h00): NAT, Peering e Módulos',
      accent: C.PURPLE,
      bullets: [
        '14h00–15h00 (M5): Lab 03 — Roteamento, Cloud Router e Cloud NAT.',
        '15h00–16h05 (M6): Lab 04 — VPC Peering com Hub + Mural Ao Vivo.',
        '16h25–17h30 (M7): Lab 05 — Boas Práticas com Módulos Terraform.',
        '17h30–18h00 (M8): FinOps com terraform destroy e encerramento.'
      ]
    }
  },
  {
    eyebrow: '04 • Alinhamento Inicial',
    title: 'Check-in do Ambiente: student_id e project_id',
    left: {
      title: 'Por que cada aluno tem um student_id (1 a 40)?',
      accent: C.GREEN,
      bullets: [
        'À tarde conectaremos todas as redes ao Hub via VPC Peering.',
        'Duas redes em Peering nunca podem ter o mesmo CIDR!',
        'Sua sub-rede é calculada como 10.<student_id>.0.0/24.',
        'Alunos 01–20: vpc-hub-turma-a | Alunos 21–40: vpc-hub-turma-b.',
        'Até 4 alunos dividem 1 projeto isolados pelo sufixo aluno-XX.'
      ]
    },
    rightCode: {
      label: 'Terminal — Verificação Rápida',
      code: `# 1. Verifique se o Terraform está instalado
terraform -version

# 2. Confira seu projeto ativo no gcloud
gcloud config get-value project

# 3. Autentique o ADC (usado pelo Terraform!)
gcloud auth application-default login

# 4. Entre na pasta onde vamos codar do zero
cd terraform/live-coding`
    }
  },
  {
    eyebrow: '05 • Módulo 01 — Redes Físicas vs. Nuvem',
    title: 'Onde foram parar os cabos, switches e roteadores na Nuvem?',
    left: {
      title: 'Rede Tradicional (On-Premises)',
      accent: C.AMBER,
      bullets: [
        'Hardware dedicado: switches L2, roteadores L3 e cabos físicos.',
        'Mudança lenta: criar VLAN ou rota exige configurar caixas via SSH.',
        'Ponto único de gargalo: tráfego passa por appliance físico central.',
        'Escopo local: restrita a um prédio ou datacenter regional.'
      ]
    },
    right: {
      title: 'Google Cloud Andromeda (SDN)',
      accent: C.GREEN,
      bullets: [
        'Software-Defined Networking: rotas, NAT e firewall via API.',
        'Virtualização no Hipervisor: firewall direto na vNIC de cada VM.',
        'Backbone Privado Global: cabos submarinos próprios da Google.',
        'Provisionamento em segundos com poucas linhas de Terraform.'
      ]
    }
  },
  {
    eyebrow: '06 • Módulo 01 — Fundamentos IPv4 e CIDR',
    title: 'Entendendo o Bloco 10.<student_id>.0.0/24 na Prática',
    left: {
      title: 'Anatomia dos 32 Bits (4 Octetos de 8 Bits)',
      accent: C.BLUE,
      bullets: [
        '1º Octeto (10): Rede Privada RFC 1918 (8 bits fixos).',
        '2º Octeto (<ID>): Seu número de aluno de 1 a 40 (+8 = 16 bits).',
        '3º Octeto (0): Identificador da sub-rede principal (+8 = 24 bits).',
        '4º Octeto (0..255): 8 bits livres para máquinas (2^8 = 256 IPs)!'
      ]
    },
    right: {
      title: 'Analogia Prática das Máscaras CIDR',
      accent: C.PURPLE,
      bullets: [
        '/24 (256 IPs): Os 3 primeiros números são a rua; o último é a casa.',
        '/16 (65.536 IPs): Fixa apenas os 2 primeiros octetos.',
        '/32 (1 IP exato): Trava todos os 32 bits (usado em regras de firewall).',
        '/0 (0.0.0.0/0): Representa qualquer IP da internet inteira!'
      ]
    }
  },
  {
    eyebrow: '07 • Módulo 01 — Pegadinha Clássica de Cloud',
    title: 'Por que nossa 1ª VM no GCP recebe o IP .2 e não o .1?',
    left: {
      title: 'Os 4 Endereços Reservados pelo GCP em toda Subnet',
      accent: C.AMBER,
      bullets: [
        '10.7.0.0 — Endereço de Rede (identifica a própria sub-rede).',
        '10.7.0.1 — Default Gateway Virtual (roteador SDN Andromeda).',
        '10.7.0.2 a .253 — 252 IPs livres para VMs (1ª VM nasce com .2!).',
        '10.7.0.254 — Penúltimo IP reservado internamente pela Google.',
        '10.7.0.255 — Endereço de Broadcast (padrão RFC).'
      ]
    },
    right: {
      title: 'Fórmula de Endereços Utilizáveis no GCP',
      accent: C.GREEN,
      bullets: [
        'Em redes tradicionais perdemos 2 IPs (Rede e Broadcast).',
        'No Google Cloud sempre perdemos 4 IPs por sub-rede!',
        'Fórmula GCP: 2^(32 - CIDR) - 4.',
        'Para /24: 2^8 - 4 = 256 - 4 = 252 hosts utilizáveis.',
        'Comprovaremos o gateway 10.<ID>.0.1 no output do Lab 01!'
      ]
    }
  },
  {
    eyebrow: '08 • Módulo 01 — O Grande Diferencial do GCP',
    title: 'Escopo: VPC é Global, Sub-rede é Regional, VM é Zonal',
    left: {
      title: 'Hierarquia de Rede no Google Cloud',
      accent: C.BLUE,
      bullets: [
        '1. VPC Network (Global): atravessa o planeta inteiro sem região.',
        '2. Subnetwork (Regional): fatia CIDR em uma região (us-central1).',
        '3. Máquina Virtual (Zonal): vive em um datacenter (us-central1-a).',
        'VMs em zonas diferentes da mesma região compartilham a mesma /24!'
      ]
    },
    right: {
      title: 'Vantagem frente a outras Nuvens',
      accent: C.GREEN,
      bullets: [
        'Uma única VPC pode ter uma sub-rede nos EUA (us-central1) e outra em São Paulo (southamerica-east1).',
        'As duas conversam por IP privado via fibra global da Google sem precisar configurar VPN ou Peering entre regiões!'
      ]
    }
  },
  {
    eyebrow: '09 • Módulo 02 — Infraestrutura como Código',
    title: 'Por que gerenciar Redes com Terraform em vez do Console?',
    left: {
      title: 'Os Riscos do ClickOps (Painel Manual)',
      accent: C.AMBER,
      bullets: [
        'Impossível replicar dev, staging e prod sem esquecer configurações.',
        'Regras de firewall abertas "só para teste" que nunca são removidas.',
        'Sem histórico de auditoria (quem mudou, quando e por quê).',
        'Sem revisão de código (Pull Request) antes de aplicar em produção.'
      ]
    },
    right: {
      title: 'O Poder do Terraform + .tfstate',
      accent: C.PURPLE,
      bullets: [
        'Linguagem Declarativa (HCL): você descreve o estado final desejado.',
        'Grafo de Dependências: cria VPC -> Subnet -> VM na ordem certa.',
        'Memória (.tfstate): mapeia seu código para os recursos reais no GCP.',
        'Previsibilidade total com terraform plan antes de aplicar mudanças.'
      ]
    }
  },
  {
    eyebrow: '10 • Módulo 02 — Sintaxe HCL e Ciclo de Vida',
    title: 'Os 5 Blocos e os 5 Comandos do Terraform',
    leftCode: {
      label: 'Sintaxe de Recursos e Referência Implícita',
      code: `resource "google_compute_network" "vpc_aluno" {
  name                    = "vpc-redes-tf-aluno-07"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "subnet-us-central1-aluno-07"
  ip_cidr_range = "10.7.0.0/24"
  network       = google_compute_network.vpc_aluno.id
}`
    },
    right: {
      title: 'Os 5 Comandos Essenciais',
      accent: C.GREEN,
      bullets: [
        '1. terraform init — Baixa o provider hashicorp/google.',
        '2. terraform fmt & validate — Formata e valida a sintaxe HCL.',
        '3. terraform plan — Simula e mostra o diff (+ criar, ~ alterar, - destruir).',
        '4. terraform apply — Provisiona no GCP e salva no .tfstate.',
        '5. terraform destroy — Remove tudo na ordem reversa exata.'
      ]
    }
  },
  {
    eyebrow: '11 • Mão na Massa — Live Coding 00 (09h20–09h50)',
    title: 'Preparando nossa Fundação em terraform/live-coding/',
    left: {
      title: 'Roteiro de Construção Inicial',
      accent: C.GREEN,
      bullets: [
        '1. Criar versions.tf definindo Terraform >= 1.5 e google ~> 5.0.',
        '2. Criar providers.tf apontando para var.project_id e var.region.',
        '3. Criar variables.tf validando student_id entre 1 e 40.',
        '4. Criar terraform.tfvars com seus dados e rodar terraform init!',
        'Meta antes do intervalo: "Terraform has been successfully initialized!"'
      ]
    },
    rightCode: {
      label: 'terraform/live-coding/versions.tf & providers.tf',
      code: `terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}`
    }
  },
  {
    eyebrow: '12 • Módulo 03 — Decisão de Arquitetura',
    title: 'Modo Auto vs. Modo Custom: auto_create_subnetworks = false',
    left: {
      title: 'VPC em Modo Automático (true) — Evite!',
      accent: C.AMBER,
      bullets: [
        'Cria 1 sub-rede /20 em cada uma das +40 regiões automaticamente.',
        'Usa sempre o mesmo bloco fixo: 10.128.0.0/9.',
        'Fatal para VPC Peering: duas VPCs em modo Auto têm os mesmos IPs e nunca conseguem fazer Peering entre si!'
      ]
    },
    right: {
      title: 'VPC em Modo Customizado (false) — Padrão Real',
      accent: C.GREEN,
      bullets: [
        'A VPC nasce 100% limpa, apenas com as sub-redes que declararmos.',
        'Permite planejar nosso CIDR exclusivo 10.<student_id>.0.0/24.',
        'Garante zero colisão de IPs com o Hub Central e VPNs.',
        'Habilitamos private_ip_google_access = true na sub-rede.'
      ]
    }
  },
  {
    eyebrow: '13 • Mão na Massa — Etapa 01 (10h20–11h00)',
    title: 'Construindo nossa VPC Customizada e Sub-rede Regional',
    left: {
      title: 'Passo a Passo (Checkpoint: labs/01-vpc-subnets/)',
      accent: C.GREEN,
      bullets: [
        '1. locals.tf: calcular student_suffix e subnet_cidr (10.<ID>.0.0/24).',
        '2. vpc.tf: criar google_compute_network e google_compute_subnetwork.',
        '3. outputs.tf: exibir vpc_name, subnet_cidr e gateway_address.',
        '4. Executar terraform plan, terraform apply e conferir no Console!'
      ]
    },
    rightCode: {
      label: 'terraform/live-coding/vpc.tf',
      code: `resource "google_compute_network" "vpc_aluno" {
  name                    = local.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "subnet_principal" {
  name                     = local.subnet_name
  ip_cidr_range            = local.subnet_cidr
  region                   = var.region
  network                  = google_compute_network.vpc_aluno.id
  private_ip_google_access = true
}`
    }
  },
  {
    eyebrow: '14 • Módulo 04 — Segurança de Perímetro no GCP',
    title: 'Firewall Stateful, Regras Implícitas e Network Tags',
    left: {
      title: 'Regras Implícitas e Estado (Conntrack)',
      accent: C.BLUE,
      bullets: [
        'Deny All Ingress (65535): bloqueia toda entrada não liberada.',
        'Allow All Egress (65535): permite que VMs iniciem conexões de saída.',
        'Stateful Firewall: se o pacote de entrada foi permitido, a resposta volta automaticamente sem precisar de regra extra!'
      ]
    },
    right: {
      title: 'Microsegmentação com Network Tags',
      accent: C.PURPLE,
      bullets: [
        'Evite aplicar regras de firewall para todas as máquinas da VPC.',
        'Usamos target_tags = ["ssh-iap"] na regra de firewall.',
        'Apenas VMs que possuam tags = ["ssh-iap"] recebem a liberação da porta 22!'
      ]
    }
  },
  {
    eyebrow: '15 • Módulo 04 — Arquitetura Zero-Trust',
    title: 'Como fazer SSH em uma VM 100% Privada usando Cloud IAP?',
    left: {
      title: 'O Perigo do IP Público na Porta 22',
      accent: C.AMBER,
      bullets: [
        'Expor IP público com 0.0.0.0/0 na porta 22 atrai ataques de força bruta imediatos da internet.',
        'Em produção, máquinas internas e bancos nunca têm IP externo!'
      ]
    },
    right: {
      title: 'Solução: Cloud IAP TCP Forwarding',
      accent: C.GREEN,
      bullets: [
        'Criamos a VM sem bloco access_config (IP Externo = Nenhum).',
        'O Cloud IAP valida sua conta Google via IAM e cria um túnel HTTPS.',
        'Liberamos a porta 22 apenas para o range oficial do IAP: 35.235.240.0/20.',
        'Comando: gcloud compute ssh ... --tunnel-through-iap.'
      ]
    }
  },
  {
    eyebrow: '16 • Mão na Massa — Etapa 02 (11h20–12h00)',
    title: 'Subindo Firewall + VM Privada e o Mistério antes do Almoço!',
    left: {
      title: 'Passo a Passo (Checkpoint: labs/02-firewall-vms/)',
      accent: C.GREEN,
      bullets: [
        '1. firewall.tf: liberar tcp:22 p/ 35.235.240.0/20 e icmp p/ 10.0.0.0/8.',
        '2. compute.tf: criar VM e2-micro Debian 12 sem access_config.',
        '3. Rodar terraform apply e conectar via SSH IAP!',
        'Desafio das 11h50: rode ping -c 3 8.8.8.8 dentro da VM. Por que dá 100% packet loss? Resolveremos às 14h00!'
      ]
    },
    rightCode: {
      label: 'terraform/live-coding/firewall.tf & compute.tf',
      code: `resource "google_compute_firewall" "allow_ssh_iap" {
  name          = "fw-allow-ssh-iap-\${local.student_suffix}"
  network       = google_compute_network.vpc_aluno.name
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["ssh-iap"]
  allow { protocol = "tcp", ports = ["22"] }
}

resource "google_compute_instance" "vm_aluno" {
  name         = "vm-teste-\${local.student_suffix}"
  machine_type = "e2-micro"
  zone         = var.zone
  tags         = ["ssh-iap"]
  boot_disk { initialize_params { image = "debian-cloud/debian-12" } }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet_principal.id
  }
}`
    }
  }
];

// ============================================================================
// DEFINIÇÃO COMPLETA DOS 16 SLIDES — TURNO DA TARDE (14H00–18H00)
// ============================================================================
const AFTERNOON_SLIDES = [
  {
    isCover: true,
    eyebrow: 'E-INFO • FACAPE • TURNO DA TARDE (14H00–18H00)',
    title: 'Redes.tf // Parte 2: Cloud NAT, VPC Peering e Módulos',
    subtitle: 'Tabelas de Roteamento, Saída Segura com Cloud Router e Cloud NAT, Interconexão Hub-and-Spoke via VPC Peering, Desafio do Mural Ao Vivo e Terraform Modules.',
    footerHighlight: 'Facilitador: Luan Sousa — Cloud Engineer @ SantoDigital | Google Cloud Digital Leader | CC FACAPE',
    accent: C.PURPLE
  },
  {
    eyebrow: '02 • Módulo 05 — Diagnóstico de Roteamento',
    title: 'Por que o ping 8.8.8.8 deu 100% packet loss na nossa VM?',
    left: {
      title: 'As 2 Rotas Automáticas de toda VPC',
      accent: C.BLUE,
      bullets: [
        '1. Rota Local (10.<ID>.0.0/24 -> Virtual Network): entrega pacotes dentro da própria sub-rede.',
        '2. Rota Padrão (0.0.0.0/0 -> Default Internet Gateway): envia pacotes externos para o gateway de internet da VPC.'
      ]
    },
    right: {
      title: 'Se a rota 0.0.0.0/0 existe, por que falhou?',
      accent: C.AMBER,
      bullets: [
        'Endereços Privados (RFC 1918) não navegam na internet pública!',
        'Nossa VM possui apenas o IP privado 10.<ID>.0.2.',
        'O servidor 8.8.8.8 não saberia para qual rede 10.x.x.x devolver a resposta.',
        'O Internet Gateway descarta pacotes sem IP público ou sem Cloud NAT!'
      ]
    }
  },
  {
    eyebrow: '03 • Módulo 05 — Fundamentos Clássicos de NAT',
    title: 'Como o SNAT (Source NAT) traduz IPs privados na saída',
    left: {
      title: 'Ida: Tradução do Endereço de Origem',
      accent: C.BLUE,
      bullets: [
        '1. A VM cria o pacote: Origem 10.7.0.2:49152 -> Destino 8.8.8.8.',
        '2. O Cloud NAT intercepta na saída e troca a origem por um IP público real (ex: 34.122.10.55:61001).',
        '3. O Cloud NAT anota essa correspondência na tabela de estado.'
      ]
    },
    right: {
      title: 'Volta: Retorno Seguro e Unidirecional',
      accent: C.GREEN,
      bullets: [
        '1. O 8.8.8.8 responde para o IP público 34.122.10.55:61001.',
        '2. O Cloud NAT consulta sua tabela e devolve o pacote para 10.7.0.2.',
        'Segurança máxima: ninguém na internet consegue iniciar uma conexão de fora para dentro através do Cloud NAT!'
      ]
    }
  },
  {
    eyebrow: '04 • Módulo 05 — Arquitetura GCP',
    title: 'Dupla Dinâmica no Terraform: Cloud Router + Cloud NAT',
    left: {
      title: '1. Cloud Router (google_compute_router)',
      accent: C.BLUE,
      bullets: [
        'É o Plano de Controle Regional da rede.',
        'Em cenários de VPN/Interconnect, gerencia sessões BGP.',
        'Para o Cloud NAT, funciona como o controlador regional onde vinculamos o serviço de tradução.'
      ]
    },
    right: {
      title: '2. Cloud NAT (google_compute_router_nat)',
      accent: C.GREEN,
      bullets: [
        'Serviço de tradução definido por software (sem VM de gargalo).',
        'nat_ip_allocate_option = "AUTO_ONLY": o GCP aloca IPs públicos automaticamente.',
        'ALL_SUBNETWORKS_ALL_IP_RANGES: atende toda a sub-rede regional.'
      ]
    }
  },
  {
    eyebrow: '05 • Mão na Massa — Etapa 03 (14h20–15h00)',
    title: 'Destravando a Internet da VM Privada com Cloud NAT',
    left: {
      title: 'Roteiro (Checkpoint: labs/03-roteamento-nat/)',
      accent: C.GREEN,
      bullets: [
        '1. Criar nat.tf declarando google_compute_router e google_compute_router_nat.',
        '2. Executar terraform plan e terraform apply.',
        '3. Voltar ao SSH da VM privada e testar: ping -c 3 8.8.8.8 e curl ifconfig.me!'
      ]
    },
    rightCode: {
      label: 'terraform/live-coding/nat.tf',
      code: `resource "google_compute_router" "router_aluno" {
  name    = "router-\${var.region}-\${local.student_suffix}"
  network = google_compute_network.vpc_aluno.id
  region  = var.region
}

resource "google_compute_router_nat" "nat_aluno" {
  name   = "nat-\${var.region}-\${local.student_suffix}"
  router = google_compute_router.router_aluno.name
  region = google_compute_router.router_aluno.region
  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}`
    }
  },
  {
    eyebrow: '06 • Módulo 06 — Interconexão de Redes no GCP',
    title: 'Como conectar duas VPCs no Google Cloud? (Comparativo)',
    left: {
      title: 'VPC Network Peering & Shared VPC',
      accent: C.GREEN,
      bullets: [
        'VPC Network Peering (Nosso Lab 04): troca direta de rotas na SDN entre 2 VPCs (mesmo em projetos diferentes), sem latência extra.',
        'Shared VPC: um projeto Host centraliza a VPC e compartilha sub-redes com projetos de serviço da mesma Organização.'
      ]
    },
    right: {
      title: 'Cloud VPN & Private Service Connect',
      accent: C.BLUE,
      bullets: [
        'Cloud VPN (HA VPN): túnel criptografado IPsec + BGP via internet; ideal para conectar Datacenter On-Premises ou outra Cloud.',
        'Private Service Connect (PSC): expõe apenas 1 serviço específico via endpoint privado, mesmo com conflito de CIDR.'
      ]
    }
  },
  {
    eyebrow: '07 • Módulo 06 — Regras de Ouro',
    title: 'As 3 Leis Inquebráveis do VPC Network Peering',
    left: {
      title: '1. Zero Overlap & 2. Acordo Bilateral',
      accent: C.AMBER,
      bullets: [
        'Lei 1 — Proibido CIDR Overlap: duas redes em Peering jamais podem ter sub-redes com a mesma faixa de IPs (por isso usamos 10.<ID>.0.0/24!).',
        'Lei 2 — Acordo Bilateral: o Peering só muda de INACTIVE para ACTIVE quando o Aluno aponta para o Hub e o Hub aponta para o Aluno.'
      ]
    },
    right: {
      title: '3. Não-Transitividade (Isolamento entre Alunos)',
      accent: C.PURPLE,
      bullets: [
        'Lei 3 — Peering NÃO é transitivo ("o amigo do meu amigo não é meu amigo").',
        'O Aluno 01 conversa com o Hub e o Aluno 02 conversa com o Hub.',
        'Porém o Aluno 01 NÃO enxerga a rede do Aluno 02! Seus ambientes continuam isolados.'
      ]
    }
  },
  {
    eyebrow: '08 • Módulo 06 — Engenharia de Limites (Quotas)',
    title: 'Arquitetura do Hub Central: Suportando 40 Alunos',
    left: {
      title: 'Limite do GCP: 25 Peerings por VPC',
      accent: C.BLUE,
      bullets: [
        'O GCP possui limite padrão de 25 peerings ativos por VPC.',
        'Para suportar até 40 alunos na sala, aplicamos Sharding no Hub:',
        '• Alunos 01 a 20 -> vpc-hub-turma-a (10.0.1.0/24 | Alvo: 10.0.1.10).',
        '• Alunos 21 a 40 -> vpc-hub-turma-b (10.0.2.0/24 | Alvo: 10.0.2.10).'
      ]
    },
    right: {
      title: 'Auto-Aceitação via API no Cloud Run',
      accent: C.GREEN,
      bullets: [
        'O serviço Cloud Run que exibe o Mural no telão possui permissão compute.networks.addPeering no Projeto Hub.',
        'Assim que o aluno registra seu Peering, o Hub cria o lado recíproco automaticamente via API, deixando o status ACTIVE na hora!'
      ]
    }
  },
  {
    eyebrow: '09 • Mão na Massa — Etapa 04 (15h20–15h45)',
    title: 'Construindo o VPC Peering com o Projeto Central',
    left: {
      title: 'Passo a Passo (Checkpoint: labs/04-vpc-peering-hub/)',
      accent: C.GREEN,
      bullets: [
        '1. Adicionar hub_project_id no variables.tf.',
        '2. Criar peering.tf conectando sua VPC à VPC do Hub correspondente ao seu student_id.',
        '3. Rodar terraform apply e ver a rota 10.0.X.0/24 surgir na sua tabela de rotas!'
      ]
    },
    rightCode: {
      label: 'terraform/live-coding/peering.tf',
      code: `resource "google_compute_network_peering" "aluno_para_hub" {
  name         = "peering-\${local.student_suffix}-to-hub"
  network      = google_compute_network.vpc_aluno.self_link
  peer_network = "projects/\${var.hub_project_id}/global/networks/\${local.hub_vpc_name}"

  export_custom_routes = false
  import_custom_routes = false
}`
    }
  },
  {
    eyebrow: '10 • Desafio Ao Vivo no Projetor (15h45–16h05)',
    title: 'Hora da Verdade: Acendendo seu Card no Mural Central!',
    left: {
      title: 'Validação Ponta a Ponta da Arquitetura',
      accent: C.GREEN,
      bullets: [
        '1. Acesso à VM privada (10.<ID>.0.2) via túnel Cloud IAP.',
        '2. Pacotes utilitários instalados via saída pelo Cloud NAT.',
        '3. Pacote ICMP (ping) e HTTP POST viajando por IP privado pelo VPC Peering até a VM coletora do Hub e atualizando o Cloud Run!'
      ]
    },
    rightCode: {
      label: 'Dentro do SSH da sua VM Privada',
      code: `# Alunos 01 a 20 -> HUB_IP="10.0.1.10"
# Alunos 21 a 40 -> HUB_IP="10.0.2.10"
HUB_IP="10.0.1.10"

# 1. Teste a latência privada via VPC Peering:
ping -c 3 $HUB_IP

# 2. Envie seu Check-in para aparecer no Projetor!
curl -X POST http://$HUB_IP:8080/checkin \\
  -H "Content-Type: application/json" \\
  -d '{"student_id": 7, "student_name": "Seu Nome"}'`
    }
  },
  {
    eyebrow: '11 • Módulo 07 — Boas Práticas de Engenharia Cloud',
    title: 'Como organizamos Terraform na vida real? (Modules)',
    left: {
      title: 'O Problema da Duplicação em Produção',
      accent: C.AMBER,
      bullets: [
        'Em empresas reais temos múltiplos ambientes (dev, staging, prod) e dezenas de projetos.',
        'Copiar e colar arquivos .tf soltos gera código impossível de dar manutenção e padronizar.'
      ]
    },
    right: {
      title: 'O Conceito de Módulos (modules/)',
      accent: C.PURPLE,
      bullets: [
        'Funciona como uma função reutilizável de engenharia:',
        '• variables.tf: contrato de entrada tipado e validado.',
        '• main.tf: recursos encapsulados com boas práticas.',
        '• outputs.tf: valores exportados para conectar outros módulos.'
      ]
    }
  },
  {
    eyebrow: '12 • Módulo 07 — Arquitetura Modular',
    title: 'Os 3 Módulos Padrão do Nosso Repositório (terraform/modules/)',
    left: {
      title: '1. vpc-network & 2. firewall-rules',
      accent: C.BLUE,
      bullets: [
        'modules/vpc-network: encapsula VPC Custom, Sub-rede regional, Cloud Router e Cloud NAT (ativado via enable_nat = true).',
        'modules/firewall-rules: provisiona regras padronizadas de SSH via Cloud IAP (35.235.240.0/20) e ICMP interno.'
      ]
    },
    right: {
      title: '3. vpc-peering & Reaproveitamento',
      accent: C.PURPLE,
      bullets: [
        'modules/vpc-peering: padroniza o fechamento de Peering entre Spoke e Hub.',
        'Todos os 3 módulos já estão 100% construídos e documentados no repositório para você usar após o curso!'
      ]
    }
  },
  {
    eyebrow: '13 • Tour Guiado — Etapa 05 (16h45–17h30)',
    title: 'Como toda a nossa rede vira 3 chamadas de Módulo limpas',
    left: {
      title: 'Vantagens da Arquitetura Modular',
      accent: C.PURPLE,
      bullets: [
        'Legibilidade imediata: em poucas linhas entendemos toda a topologia.',
        'Encadeamento seguro: firewall_rules consome module.vpc_network.network_name.',
        'Pronto para replicar em dev, homologação e produção!'
      ]
    },
    rightCode: {
      label: 'terraform/labs/05-boas-praticas-modules/main.tf',
      code: `module "vpc_network" {
  source      = "../../modules/vpc-network"
  project_id  = var.project_id
  region      = var.region
  vpc_name    = local.vpc_name
  subnet_name = local.subnet_name
  subnet_cidr = local.subnet_cidr
  enable_nat  = true
}

module "firewall_rules" {
  source       = "../../modules/firewall-rules"
  project_id   = var.project_id
  network_name = module.vpc_network.network_name
  name_suffix  = local.student_suffix
}`
    }
  },
  {
    eyebrow: '14 • Módulo 07 — Visão de Mercado',
    title: 'O que muda quando levamos esse Terraform para Produção?',
    left: {
      title: 'Remote State no GCS & State Locking',
      accent: C.BLUE,
      bullets: [
        'Em equipe, o terraform.tfstate nunca fica salvo na máquina local.',
        'Usamos backend "gcs" em um Bucket do Cloud Storage com versionamento e State Locking (impede dois apply simultâneos).'
      ]
    },
    right: {
      title: 'Versionamento Git & Pipelines CI/CD',
      accent: C.GREEN,
      bullets: [
        'Módulos versionados com tags semânticas (?ref=v1.2.0).',
        'Pipelines no GitHub Actions / GitLab CI rodando terraform fmt, validate, tfsec e comentando o plan no Pull Request!'
      ]
    }
  },
  {
    eyebrow: '15 • Módulo 08 — FinOps e Ciclo de Vida (17h30–17h45)',
    title: 'Desmontando a Infraestrutura com terraform destroy',
    left: {
      title: 'O Grafo Reverso de Destruição',
      accent: C.AMBER,
      bullets: [
        'Tentar deletar uma VPC manualmente no painel falha se houver sub-redes, VMs, routers ou peerings ativos.',
        'Com terraform destroy, o Terraform percorre o grafo de trás para frente e remove 100% dos recursos sem deixar sobras na fatura!'
      ]
    },
    rightCode: {
      label: 'Terminal — Limpeza Completa (17h30)',
      code: `# 1. Saia do SSH da VM privada
exit

# 2. Destrua os recursos na ordem inversa automática:
terraform destroy

# [-] google_compute_instance.vm_aluno
# [-] google_compute_network_peering.aluno_para_hub
# [-] google_compute_router_nat.nat_aluno
# [-] google_compute_router.router_aluno
# [-] google_compute_subnetwork.subnet_principal
# [-] google_compute_network.vpc_aluno`
    }
  },
  {
    eyebrow: '16 • Missão Cumprida — Retrospectiva das 8 Horas',
    title: 'Parabéns! Olha o que você construiu em Código hoje',
    left: {
      title: 'Checklist de Conquistas do Dia',
      accent: C.GREEN,
      bullets: [
        'VPC Customizada + Sub-rede CIDR /24 planejada sem colisão.',
        'Firewall Stateful, Network Tags e SSH via Cloud IAP em VM privada.',
        'Saída segura para a internet com Cloud Router e Cloud NAT.',
        'Interconexão Hub-and-Spoke via VPC Network Peering.',
        'Organização profissional com Módulos Reutilizáveis do Terraform!'
      ]
    },
    right: {
      title: 'Obrigado, turma do e-info / FACAPE!',
      accent: C.PURPLE,
      hasFacilitatorPhoto: true,
      bullets: [
        'Todo o código, os gabaritos das 5 etapas e os módulos ficam disponíveis no repositório para seus estudos e portfólio.',
        'Facilitador: Luan Sousa — Cloud Engineer @ SantoDigital | Ciência da Computação FACAPE.'
      ]
    }
  }
];

// ============================================================================
// GERADOR PPTX (16 SLIDES POR DECK)
// ============================================================================
async function generatePptx(slidesData, outFile, deckTitle) {
  const pres = new pptxgen();
  pres.layout = 'LAYOUT_16x9'; // 10" x 5.625"
  pres.title = deckTitle;
  pres.author = 'Luan Sousa';

  for (const s of slidesData) {
    const slide = pres.addSlide();
    slide.background = { color: C.BG_DARK };

    if (s.isCover) {
      slide.addShape('roundRect', {
        x: 0.55, y: 0.55, w: 8.9, h: 4.5, rectRadius: 0.12,
        fill: { color: C.BG_CARD }, line: { color: s.accent, width: 1.5 }
      });
      if (fs.existsSync(LOGO_EINFO_PATH)) {
        slide.addImage({ path: LOGO_EINFO_PATH, x: 7.75, y: 0.78, w: 1.4, h: 0.66 });
      }
      slide.addText(s.eyebrow, {
        x: 0.95, y: 0.95, w: 6.6, h: 0.3,
        fontFace: 'Courier New', fontSize: 10.5, bold: true, color: C.CYAN, margin: 0
      });
      slide.addText(s.title, {
        x: 0.95, y: 1.4, w: 8.1, h: 1.15,
        fontFace: 'Arial', fontSize: 26, bold: true, color: C.TEXT_MAIN, margin: 0
      });
      slide.addText(s.subtitle, {
        x: 0.95, y: 2.65, w: 8.1, h: 0.9,
        fontFace: 'Calibri', fontSize: 13.5, color: C.TEXT_SUB, margin: 0
      });
      if (fs.existsSync(FOTO_PERFIL_PATH)) {
        slide.addImage({ path: FOTO_PERFIL_PATH, x: 0.95, y: 3.78, w: 0.72, h: 0.72, rounding: true });
        slide.addText(s.footerHighlight, {
          x: 1.82, y: 3.92, w: 7.2, h: 0.45,
          fontFace: 'Arial', fontSize: 12.5, bold: true, color: C.GREEN, margin: 0
        });
      } else {
        slide.addText(s.footerHighlight, {
          x: 0.95, y: 3.95, w: 8.1, h: 0.45,
          fontFace: 'Arial', fontSize: 12.5, bold: true, color: C.GREEN, margin: 0
        });
      }
      continue;
    }

    // Header
    slide.addText(s.eyebrow.toUpperCase(), {
      x: 0.55, y: 0.32, w: 7.5, h: 0.24,
      fontFace: 'Courier New', fontSize: 9.5, bold: true, color: C.CYAN, margin: 0
    });
    slide.addText(s.title, {
      x: 0.55, y: 0.58, w: 7.5, h: 0.52,
      fontFace: 'Arial', fontSize: 19.5, bold: true, color: C.TEXT_MAIN, margin: 0
    });
    if (fs.existsSync(LOGO_EINFO_PATH)) {
      slide.addImage({ path: LOGO_EINFO_PATH, x: 8.25, y: 0.36, w: 1.18, h: 0.56 });
    }

    // Coluna Esquerda
    if (s.left) {
      slide.addShape('roundRect', {
        x: 0.55, y: 1.25, w: 4.3, h: 3.8, rectRadius: 0.08,
        fill: { color: C.BG_CARD }, line: { color: s.left.accent || C.BORDER, width: 1.2 }
      });
      if (s.left.hasFacilitatorPhoto && fs.existsSync(FOTO_PERFIL_PATH)) {
        slide.addImage({ path: FOTO_PERFIL_PATH, x: 0.75, y: 1.42, w: 0.82, h: 0.82, rounding: true });
        slide.addText(s.left.title, {
          x: 1.7, y: 1.52, w: 2.95, h: 0.36,
          fontFace: 'Arial', fontSize: 14, bold: true, color: C.TEXT_MAIN, margin: 0
        });
        slide.addText('Cloud Engineer @ SantoDigital • CC FACAPE', {
          x: 1.7, y: 1.86, w: 2.95, h: 0.28,
          fontFace: 'Calibri', fontSize: 10.5, bold: true, color: C.CYAN, margin: 0
        });
      } else {
        slide.addText(s.left.title, {
          x: 0.75, y: 1.42, w: 3.9, h: 0.36,
          fontFace: 'Arial', fontSize: 13, bold: true, color: C.TEXT_MAIN, margin: 0
        });
      }
      const runs = s.left.bullets.map((b, i) => ({
        text: b,
        options: {
          bullet: true,
          breakLine: i < s.left.bullets.length - 1,
          paraSpaceAfter: 5,
          color: C.TEXT_SUB,
          fontFace: 'Calibri',
          fontSize: 11.5
        }
      }));
      const textY = s.left.hasFacilitatorPhoto ? 2.38 : 1.85;
      const textH = s.left.hasFacilitatorPhoto ? 2.52 : 3.05;
      slide.addText(runs, {
        x: 0.75, y: textY, w: 3.9, h: textH, valign: 'top', margin: 0
      });
    } else if (s.leftCode) {
      slide.addShape('roundRect', {
        x: 0.55, y: 1.25, w: 4.3, h: 3.8, rectRadius: 0.08,
        fill: { color: C.BG_CODE }, line: { color: C.PURPLE, width: 1.2 }
      });
      slide.addText(s.leftCode.label, {
        x: 0.75, y: 1.4, w: 3.9, h: 0.25,
        fontFace: 'Courier New', fontSize: 9.5, bold: true, color: C.CYAN, margin: 0
      });
      slide.addText(s.leftCode.code, {
        x: 0.75, y: 1.72, w: 3.9, h: 3.2,
        fontFace: 'Courier New', fontSize: 9.5, color: C.TEXT_MAIN, valign: 'top', margin: 0
      });
    }

    // Coluna Direita
    if (s.right) {
      slide.addShape('roundRect', {
        x: 5.15, y: 1.25, w: 4.3, h: 3.8, rectRadius: 0.08,
        fill: { color: C.BG_CARD }, line: { color: s.right.accent || C.BORDER, width: 1.2 }
      });
      if (s.right.hasFacilitatorPhoto && fs.existsSync(FOTO_PERFIL_PATH)) {
        slide.addImage({ path: FOTO_PERFIL_PATH, x: 5.35, y: 1.42, w: 0.82, h: 0.82, rounding: true });
        slide.addText(s.right.title, {
          x: 6.3, y: 1.52, w: 2.95, h: 0.36,
          fontFace: 'Arial', fontSize: 13.5, bold: true, color: C.TEXT_MAIN, margin: 0
        });
        slide.addText('Luan Sousa • Facilitador', {
          x: 6.3, y: 1.86, w: 2.95, h: 0.28,
          fontFace: 'Calibri', fontSize: 10.5, bold: true, color: C.CYAN, margin: 0
        });
      } else {
        slide.addText(s.right.title, {
          x: 5.35, y: 1.42, w: 3.9, h: 0.36,
          fontFace: 'Arial', fontSize: 13, bold: true, color: C.TEXT_MAIN, margin: 0
        });
      }
      const runs = s.right.bullets.map((b, i) => ({
        text: b,
        options: {
          bullet: true,
          breakLine: i < s.right.bullets.length - 1,
          paraSpaceAfter: 5,
          color: C.TEXT_SUB,
          fontFace: 'Calibri',
          fontSize: 11.5
        }
      }));
      const textY = s.right.hasFacilitatorPhoto ? 2.38 : 1.85;
      const textH = s.right.hasFacilitatorPhoto ? 2.52 : 3.05;
      slide.addText(runs, {
        x: 5.35, y: textY, w: 3.9, h: textH, valign: 'top', margin: 0
      });
    } else if (s.rightCode) {
      slide.addShape('roundRect', {
        x: 5.15, y: 1.25, w: 4.3, h: 3.8, rectRadius: 0.08,
        fill: { color: C.BG_CODE }, line: { color: C.PURPLE, width: 1.2 }
      });
      slide.addText(s.rightCode.label, {
        x: 5.35, y: 1.4, w: 3.9, h: 0.25,
        fontFace: 'Courier New', fontSize: 9.5, bold: true, color: C.CYAN, margin: 0
      });
      slide.addText(s.rightCode.code, {
        x: 5.35, y: 1.72, w: 3.9, h: 3.2,
        fontFace: 'Courier New', fontSize: 9, color: C.TEXT_MAIN, valign: 'top', margin: 0
      });
    }

    // Rodapé limpo
    slide.addText('Redes.tf • Luan Sousa • e-info FACAPE', {
      x: 0.55, y: 5.22, w: 8.9, h: 0.22,
      fontFace: 'Calibri', fontSize: 9.5, color: C.TEXT_MUTED, margin: 0
    });
  }

  await pres.writeFile({ fileName: outFile });
}

// ============================================================================
// GERADOR PDF NATIVO 16:9 (16 SLIDES POR DECK)
// ============================================================================
function generatePdf(slidesData, outFile, deckTitle) {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({
      size: [960, 540], // 16:9 widescreen
      margins: { top: 0, bottom: 0, left: 0, right: 0 },
      info: { Title: deckTitle, Author: 'Luan Sousa' }
    });

    const stream = fs.createWriteStream(outFile);
    doc.pipe(stream);

    slidesData.forEach((s, idx) => {
      if (idx > 0) doc.addPage({ size: [960, 540], margins: { top: 0, bottom: 0, left: 0, right: 0 } });

      // Fundo escuro do slide
      doc.rect(0, 0, 960, 540).fill('#' + C.BG_DARK);

      if (s.isCover) {
        doc.roundedRect(48, 48, 864, 444, 12).fillAndStroke('#' + C.BG_CARD, '#' + s.accent);
        if (fs.existsSync(LOGO_EINFO_PATH)) {
          doc.image(LOGO_EINFO_PATH, 745, 70, { width: 135 });
        }
        doc.font('Courier-Bold').fontSize(11).fillColor('#' + C.CYAN)
           .text(s.eyebrow, 84, 88, { width: 640 });
        doc.font('Helvetica-Bold').fontSize(28).fillColor('#' + C.TEXT_MAIN)
           .text(s.title, 84, 130, { width: 792 });
        doc.font('Helvetica').fontSize(14).fillColor('#' + C.TEXT_SUB)
           .text(s.subtitle, 84, 235, { width: 792, lineGap: 4 });
        if (fs.existsSync(FOTO_PERFIL_PATH)) {
          doc.save();
          doc.circle(114, 408, 30).clip();
          doc.image(FOTO_PERFIL_PATH, 84, 378, { width: 60, height: 60 });
          doc.restore();
          doc.circle(114, 408, 30).lineWidth(2).strokeColor('#' + C.BLUE).stroke();
          doc.font('Helvetica-Bold').fontSize(13).fillColor('#' + C.GREEN)
             .text(s.footerHighlight, 158, 398, { width: 718 });
        } else {
          doc.font('Helvetica-Bold').fontSize(13).fillColor('#' + C.GREEN)
             .text(s.footerHighlight, 84, 395, { width: 792 });
        }
        return;
      }

      // Header
      doc.font('Courier-Bold').fontSize(10).fillColor('#' + C.CYAN)
         .text(s.eyebrow.toUpperCase(), 48, 30, { width: 740 });
      doc.font('Helvetica-Bold').fontSize(20).fillColor('#' + C.TEXT_MAIN)
         .text(s.title, 48, 50, { width: 740 });
      if (fs.existsSync(LOGO_EINFO_PATH)) {
        doc.image(LOGO_EINFO_PATH, 804, 30, { width: 108 });
      }

      // Linha divisória sutil
      doc.moveTo(48, 92).lineTo(912, 92).strokeColor('#' + C.BORDER).lineWidth(1).stroke();

      // Função auxiliar para desenhar coluna
      const drawBox = (x, boxData, isCode) => {
        if (!boxData) return;
        const bg = isCode ? '#' + C.BG_CODE : '#' + C.BG_CARD;
        const border = isCode ? '#' + C.PURPLE : '#' + (boxData.accent || C.BORDER);
        doc.roundedRect(x, 110, 420, 376, 8).fillAndStroke(bg, border);

        if (isCode) {
          doc.font('Courier-Bold').fontSize(10).fillColor('#' + C.CYAN)
             .text(boxData.label, x + 18, 126, { width: 384 });
          doc.font('Courier').fontSize(9.5).fillColor('#' + C.TEXT_MAIN)
             .text(boxData.code, x + 18, 154, { width: 384, lineGap: 3 });
        } else {
          let curY = 166;
          if (boxData.hasFacilitatorPhoto && fs.existsSync(FOTO_PERFIL_PATH)) {
            const cx = x + 52;
            const cy = 158;
            doc.save();
            doc.circle(cx, cy, 32).clip();
            doc.image(FOTO_PERFIL_PATH, cx - 32, cy - 32, { width: 64, height: 64 });
            doc.restore();
            doc.circle(cx, cy, 32).lineWidth(2).strokeColor('#' + C.BLUE).stroke();
            doc.font('Helvetica-Bold').fontSize(14).fillColor('#' + C.TEXT_MAIN)
               .text(boxData.title, x + 98, 138, { width: 302 });
            doc.font('Courier-Bold').fontSize(9.5).fillColor('#' + C.CYAN)
               .text('Cloud Engineer @ SantoDigital • CC FACAPE', x + 98, 160, { width: 302 });
            curY = 206;
          } else {
            doc.font('Helvetica-Bold').fontSize(13.5).fillColor('#' + C.TEXT_MAIN)
               .text(boxData.title, x + 20, 128, { width: 380 });
          }
          boxData.bullets.forEach((b) => {
            doc.circle(x + 24, curY + 5, 2.5).fill('#' + C.CYAN);
            doc.font('Helvetica').fontSize(11.5).fillColor('#' + C.TEXT_SUB)
               .text(b.replace(/→/g, '->'), x + 36, curY, { width: 364, lineGap: 2 });
            curY = doc.y + 10;
          });
        }
      };

      drawBox(48, s.left || s.leftCode, Boolean(s.leftCode));
      drawBox(492, s.right || s.rightCode, Boolean(s.rightCode));

      // Rodapé
      const slideNum = String(idx + 1).padStart(2, '0') + ' / ' + String(slidesData.length).padStart(2, '0');
      doc.font('Courier').fontSize(9.5).fillColor('#' + C.TEXT_MUTED)
         .text(`Redes.tf • Luan Sousa • e-info FACAPE`, 48, 504, { width: 600 });
      doc.font('Courier-Bold').fontSize(9.5).fillColor('#' + C.TEXT_MAIN)
         .text(slideNum, 800, 504, { width: 112, align: 'right' });
    });

    doc.end();
    stream.on('finish', resolve);
    stream.on('error', reject);
  });
}

(async () => {
  await generatePptx(MORNING_SLIDES, path.join(OUT_DIR, '01-manha-redes-tf-gcp.pptx'), 'Redes.tf — Turno da Manhã (08h00–12h00)');
  await generatePptx(AFTERNOON_SLIDES, path.join(OUT_DIR, '02-tarde-redes-tf-gcp.pptx'), 'Redes.tf — Turno da Tarde (14h00–18h00)');
  await generatePdf(MORNING_SLIDES, path.join(OUT_DIR, '01-manha-redes-tf-gcp.pdf'), 'Redes.tf — Turno da Manhã (08h00–12h00)');
  await generatePdf(AFTERNOON_SLIDES, path.join(OUT_DIR, '02-tarde-redes-tf-gcp.pdf'), 'Redes.tf — Turno da Tarde (14h00–18h00)');
  console.log('Exported PPTX & PDF decks (16 slides each) successfully in:', OUT_DIR);
})();
