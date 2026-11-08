# Etapa 03 — Tabelas de Roteamento, Cloud Router e Cloud NAT (`03-roteamento-nat`)

> **Horário no Cronograma:** Turno da Tarde (`14h00 – 15h00` | 60 min)  
> **Modo de Ensino:** *Live Coding* evolutivo em `terraform/live-coding/` (adicionando `routes.tf` e `nat.tf` sobre o código da Etapa 02).

---

## 1. Objetivos de Redes e Cloud desta Etapa

1. **Diagnóstico de Tabela de Roteamento vs. Endereçamento Roteável:** Entender por que, mesmo com a rota `0.0.0.0/0 -> default-internet-gateway` ativa na VPC e o Firewall de saída liberado, o pacote de uma VM privada (`10.<ID>.0.2`) não consegue navegar na internet sem tradução de endereço.
2. **SNAT (*Source Network Address Translation*):** Compreender como a tabela de tradução do NAT substitui o IP privado + porta de origem por um IP público efêmero compartilhado na saída e devolve a resposta para a VM interna sem abrir portas de entrada.
3. **Tabela de Rotas como Código (`google_compute_route`):** Ler os 3 campos clássicos de uma rota — **destino** (`dest_range`), **next-hop** (`next_hop_gateway`) e **métrica** (`priority`) — e ver que menor prioridade vence (900 da nossa rota explícita vs. 1000 da rota padrão implícita), além de rotas aplicadas só a VMs com uma *network tag*.
4. **Cloud Router + Cloud NAT no GCP:** Entender que o Cloud NAT do Google Cloud é 100% definido por software na SDN Andromeda (sem máquina virtual intermediária/gargalo), sendo configurado como plano de controle no `google_compute_router`.

---

## 2. Sequência de Construção no *Live Coding* (`terraform/live-coding/`)

### Passo 1: Atualizar `locals.tf`
Adicionamos `router_name`, `nat_name` e `route_name` em [`locals.tf`](./locals.tf).

### Passo 2: Criar `routes.tf` (Tabela de Rotas)
Criamos o arquivo [`routes.tf`](./routes.tf) com `google_compute_route.internet_explicita`: `0.0.0.0/0 -> default-internet-gateway`, `priority = 900`, `tags = [local.student_suffix]`.

> **Gancho didático:** aplique só a rota primeiro e refaça o `ping 8.8.8.8` na VM — **continua falhando!** A rota existe, mas a VM não tem IP público de origem. **Rota ≠ NAT.**

### Passo 3: Criar `nat.tf`
Criamos o arquivo [`nat.tf`](./nat.tf) com dois recursos encadeados:
- `google_compute_router.router_aluno`
- `google_compute_router_nat.nat_aluno` com `nat_ip_allocate_option = "AUTO_ONLY"` e `source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"`.

### Passo 4: Atualizar `outputs.tf`
Adicionamos `router_name`, `nat_name` e `routes_list_command` em [`outputs.tf`](./outputs.tf).

---

## 3. Comandos de Execução e Validação

No terminal, dentro de `terraform/live-coding/`:

```bash
# 1. Formatar, validar e inspecionar o plano (+3 recursos: Rota + Router + NAT)
terraform fmt
terraform validate
terraform plan

# 2. Provisionar a rota explícita, o Cloud Router e o Cloud NAT
terraform apply

# 3. Inspecionar a tabela de rotas da VPC (rota de sub-rede, padrão 1000 e a nossa 900)
$(terraform output -raw routes_list_command)
```

### Comprovando o SNAT dentro da VM Privada:

```bash
# 1. Conecte-se novamente à sua VM privada via túnel Cloud IAP:
$(terraform output -raw ssh_iap_command)

# 2. Refaça o teste que havia falhado antes do almoço:
ping -c 3 8.8.8.8
# Resultado: 0% packet loss!

# 3. Descubra com qual IP Público do Cloud NAT você está saindo para a internet:
curl -4 ifconfig.me ; echo ""

# 4. Atualize os pacotes da VM privada com segurança:
sudo apt-get update -y
```

---

## 4. Checkpoint de Recuperação Rápida

Se precisar sincronizar sua pasta `terraform/live-coding/` com o gabarito completo desta Etapa 03:

```bash
cp ../labs/03-roteamento-nat/*.tf ../live-coding/
```
