# Apresentações Visuais (Slides 16:9) — Redes.tf

Esta pasta contém todo o sistema de apresentações visuais do minicurso **"Redes.tf: da Teoria à Prática com Terraform e GCP"** (**e-info / FACAPE**).

---

## Como Abrir os Slides no Dia do Curso

Basta abrir o arquivo [**`slides/index.html`**](./index.html) em qualquer navegador moderno (Chrome, Edge, Firefox ou Brave). Os decks funcionam **100% offline**: as fontes ficam em [`assets/fonts/`](./assets/fonts/) e não há dependência de CDN.

- **[`slides/index.html`](./index.html)** — **Central de Apresentações (Menu Principal)**
- **[`slides/01-manha-teoria-base/index.html`](./01-manha-teoria-base/index.html)** — **Deck 01: Turno da Manhã (`08h00–12h00` | 18 slides, incluindo coffee break e almoço)**
  - Cobertura: Boas-vindas, Trajetória do Facilitador, Metodologia *Zero ClickOps*, Endereçamento IPv4 e Máscara CIDR `/24`, Os 4 IPs Reservados pelo GCP, SDN Andromeda, Escopo Global (VPC) vs. Regional (Subnet), Fundamentos do Terraform e Guias de *Live Coding* das Etapas 00, 01 (`01-vpc-subnets`) e 02 (`02-firewall-vms` + Cloud IAP).
- **[`slides/02-tarde-pratica-avancada/index.html`](./02-tarde-pratica-avancada/index.html)** — **Deck 02: Turno da Tarde (`14h00–18h00` | 19 slides, incluindo coffee break)**
  - Cobertura: Diagnóstico da Tabela de Roteamento (`100% packet loss`), Funcionamento do SNAT, Tabela de Rotas como Código (`google_compute_route`) + Cloud Router + Cloud NAT (`03-roteamento-nat`), Comparativo de Interconexão (Peering vs. VPN vs. Shared VPC), As 3 Leis do VPC Peering, Sharding do Hub em 2 VPCs para 40 Alunos + Auto-aceitação via script, *Live Coding* Etapa 04 (`04-vpc-peering-hub`), Desafio do Mural ao Vivo, Boas Práticas com Módulos (`05-boas-praticas-modules`) + migração sem downtime com `moved {}` e Encerramento com `terraform destroy`.

---

## Atalhos de Teclado Durante a Apresentação

| Tecla | Ação |
| :---: | :--- |
| `→` / `Espaço` / `PageDown` | Avançar para o próximo slide |
| `←` / `PageUp` | Voltar para o slide anterior |
| `F` ou `F11` | Alternar modo **Tela Cheia (16:9 Auto-scale)** no projetor |
| `Botão Copiar` | Copia qualquer bloco de código Terraform ou comando de terminal com 1 clique |
| `N` | Abre/fecha o **painel de notas do apresentador** sobre o slide (para ensaio em uma tela) |
| `S` | Abre a **janela do apresentador** (notas, próximo slide, cronômetro e relógio): arraste para o seu monitor e deixe o deck no projetor |
| `Home` / `End` | Primeiro / último slide |
| `P` ou `Ctrl+P` | Exportar / Imprimir todos os slides em **PDF de alta resolução (16:9)** |

> **Notas do apresentador:** ficam em `<aside class="notes">` dentro de cada `<section class="slide">`, nunca aparecem no projetor e são exportadas para o PPTX.

---

## Exportação para PowerPoint (`.pptx`) e PDF (`exportados/`)

- **O HTML é a única fonte.** O script [`generate_exports.js`](./generate_exports.js) abre cada deck no Chromium (Playwright) e gera:
  - **PDF** vetorial pelo CSS de impressão (1 página 16:9 por slide);
  - **PPTX** com 1 imagem por slide + as **notas do apresentador**.
  ```bash
  cd slides
  npm install
  npm run setup    # uma vez: baixa o Chromium do Playwright
  npm run export
  ```
  Sempre que editar um deck, rode `npm run export` de novo. Os 4 arquivos ficam em [`slides/exportados/`](./exportados/README.md).
- **Exportar para PDF via Navegador (Opcional):** Com o deck aberto no navegador, pressione a tecla **`P`** (ou `Ctrl+P`), selecione **"Salvar como PDF"** e marque **"Gráficos de segundo plano" (*Background graphics*)**.
