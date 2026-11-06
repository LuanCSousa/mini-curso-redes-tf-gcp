# Apresentações Visuais (Slides 16:9) — Redes.tf

Esta pasta contém todo o sistema de apresentações visuais do minicurso **"Redes.tf: da Teoria à Prática com Terraform e GCP"** (**e-info / FACAPE**).

---

## Como Abrir os Slides no Dia do Curso

Basta abrir o arquivo [**`slides/index.html`**](./index.html) em qualquer navegador moderno (Chrome, Edge, Firefox ou Brave):

- **[`slides/index.html`](./index.html)** — **Central de Apresentações (Menu Principal)**
- **[`slides/01-manha-teoria-base/index.html`](./01-manha-teoria-base/index.html)** — **Deck 01: Turno da Manhã (`08h00–12h00` | 16 Slides Interativos)**
  - Cobertura: Boas-vindas, Trajetória do Facilitador, Metodologia *Zero ClickOps*, Endereçamento IPv4 e Máscara CIDR `/24`, Os 4 IPs Reservados pelo GCP, SDN Andromeda, Escopo Global (VPC) vs. Regional (Subnet), Fundamentos do Terraform e Guias de *Live Coding* das Etapas 00, 01 (`01-vpc-subnets`) e 02 (`02-firewall-vms` + Cloud IAP).
- **[`slides/02-tarde-pratica-avancada/index.html`](./02-tarde-pratica-avancada/index.html)** — **Deck 02: Turno da Tarde (`14h00–18h00` | 16 Slides Interativos)**
  - Cobertura: Diagnóstico da Tabela de Roteamento (`100% packet loss`), Funcionamento do SNAT, Cloud Router + Cloud NAT (`03-roteamento-nat`), Comparativo de Interconexão (Peering vs. VPN vs. Shared VPC), As 3 Leis do VPC Peering, Sharding de VPC para 40 Alunos + Auto-aceitação no Cloud Run, *Live Coding* Etapa 04 (`04-vpc-peering-hub`), Desafio do Mural ao Vivo, Boas Práticas com Módulos (`05-boas-praticas-modules`) e Encerramento com `terraform destroy`.

---

## Atalhos de Teclado Durante a Apresentação

| Tecla | Ação |
| :---: | :--- |
| `→` / `Espaço` / `PageDown` | Avançar para o próximo slide |
| `←` / `PageUp` | Voltar para o slide anterior |
| `F` ou `F11` | Alternar modo **Tela Cheia (16:9 Auto-scale)** no projetor |
| `Botão Copiar` | Copia qualquer bloco de código Terraform ou comando de terminal com 1 clique |
| `P` ou `Ctrl+P` | Exportar / Imprimir todos os slides em **PDF de alta resolução (16:9)** |

---

## Exportação para PowerPoint (`.pptx`) e PDF (`exportados/`)

- **Gerar os arquivos PowerPoint (`.pptx`) e PDF (`.pdf`) via Script:** Execute o script gerador incluído em [`generate_exports.js`](./generate_exports.js):
  ```bash
  cd slides
  npm run export
  # ou: node generate_exports.js
  ```
  Os 4 arquivos (`01-manha-redes-tf-gcp.pptx`, `01-manha-redes-tf-gcp.pdf`, `02-tarde-redes-tf-gcp.pptx` e `02-tarde-redes-tf-gcp.pdf` — 16 slides cada) já estão gerados e prontos dentro de [`slides/exportados/`](./exportados/README.md).
- **Exportar para PDF via Navegador (Opcional):** Com o deck aberto no navegador, pressione a tecla **`P`** (ou `Ctrl+P`), selecione **"Salvar como PDF"** e marque **"Gráficos de segundo plano" (*Background graphics*)**.
