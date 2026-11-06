# Etapa 03 — Tabelas de Roteamento, Cloud Router e Cloud NAT (`03-roteamento-nat`)

> **Horário no Cronograma:** Turno da Tarde (`14h00 – 15h00` | 60 min)  
> **Modo de Ensino:** *Live Coding* evolutivo em `terraform/live-coding/` (adicionando `nat.tf` sobre o código da Etapa 02).

---

## 1. Objetivos de Redes e Cloud desta Etapa

1. **Diagnóstico de Tabela de Roteamento vs. Endereçamento Roteável:** Entender por que, mesmo com a rota `0.0.0.0/0 -> default-internet-gateway` ativa na VPC e o Firewall de saída liberado, o pacote de uma VM privada (`10.<ID>.0.2`) não consegue navegar na internet sem tradução de endereço.
2. **SNAT (*Source Network Address Translation*):** Compreender como a tabela de tradução do NAT substitui o IP privado + porta de origem por um IP público efêmero compartilhado na saída e devolve a resposta para a VM interna sem abrir portas de entrada.
3. **Cloud Router + Cloud NAT no GCP:** Entender que o Cloud NAT do Google Cloud é 100% definido por software na SDN Andromeda (sem máquina virtual intermediária/gargalo), sendo configurado como plano de controle no `google_compute_router`.

---

## 2. Sequência de Construção no *Live Coding* (`terraform/live-coding/`)

### Passo 1: Atualizar `locals.tf`
Adicionamos `router_name` e `nat_name` em [`locals.tf`](./locals.tf).

### Passo 2: Criar `nat.tf`
Criamos o arquivo [`nat.tf`](./nat.tf) com dois recursos encadeados:
- `google_compute_router.router_aluno`
- `google_compute_router_nat.nat_aluno` com `nat_ip_allocate_option = "AUTO_ONLY"` e `source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"`.

### Passo 3: Atualizar `outputs.tf`
Adicionamos `router_name` e `nat_name` em [`outputs.tf`](./outputs.tf).

---

## 3. Comandos de Execução e Validação

No terminal, dentro de `terraform/live-coding/`:

```bash
# 1. Formatar, validar e inspecionar o plano (+2 recursos: Router + NAT)
terraform fmt
terraform validate
terraform plan

# 2. Provisionar o Cloud Router e Cloud NAT
terraform apply
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
