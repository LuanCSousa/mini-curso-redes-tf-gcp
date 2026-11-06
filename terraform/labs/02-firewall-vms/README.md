# Etapa 02 — Firewall Stateful, Network Tags, Cloud IAP e VM Privada (`02-firewall-vms`)

> **Horário no Cronograma:** Turno da Manhã (`11h00 – 12h00` | 60 min)  
> **Modo de Ensino:** *Live Coding* evolutivo em `terraform/live-coding/` (adicionando `firewall.tf` e `compute.tf` sobre o código da Etapa 01).

---

## 1. Objetivos de Redes e Cloud desta Etapa

1. **Firewall Stateful e Regras Implícitas:** Entender que toda VPC nasce com `Deny All Ingress` (`65535`) e `Allow All Egress` (`65535`), e que o Firewall do GCP rastreia estado (*conntrack*): basta autorizar a entrada do pacote (`SYN` ou `Echo Request`) para que a resposta volte automaticamente.
2. **Microsegmentação com Network Tags (`target_tags`):** Aprender a restringir regras de firewall apenas às VMs que possuam a tag correspondente (`tags = ["ssh-iap"]`), em vez de abrir portas para toda a VPC.
3. **Arquitetura Zero-Trust com Cloud IAP (`35.235.240.0/20`):** Eliminar a necessidade de IP público e de `0.0.0.0/0` na porta `22`, acessando nossa VM 100% privada por meio do túnel TCP autenticado pelo IAM da Google.
4. **O Primeiro IP Utilizável (`.2`) e o *Cliffhanger* para a Tarde:** Comprovar que a VM recebe o IP `10.<ID>.0.2` e descobrir na prática por que `ping -c 3 8.8.8.8` falha (`100% packet loss`) em uma VM sem IP externo e sem NAT!

---

## 2. Sequência de Construção no *Live Coding* (`terraform/live-coding/`)

### Passo 1: Atualizar `locals.tf`
Adicionamos `vm_name = "vm-teste-${local.student_suffix}"` no arquivo [`locals.tf`](./locals.tf).

### Passo 2: Criar `firewall.tf`
Criamos o arquivo [`firewall.tf`](./firewall.tf) com duas regras explícitas:
- `google_compute_firewall.allow_ssh_iap`: libera `tcp:22` exclusivamente para `source_ranges = ["35.235.240.0/20"]` e `target_tags = ["ssh-iap"]`.
- `google_compute_firewall.allow_internal_icmp`: libera `icmp` e `tcp:80,8080` entre `local.subnet_cidr` e as redes do Hub Central (`10.0.1.0/24` e `10.0.2.0/24`).

### Passo 3: Criar `compute.tf`
Criamos o arquivo [`compute.tf`](./compute.tf):
- Recurso `google_compute_instance.vm_aluno` (`e2-micro`, `debian-cloud/debian-12`, `tags = ["ssh-iap", local.student_suffix]`).
- **Destaque didático:** Dentro de `network_interface`, **não** declaramos o bloco `access_config {}`, garantindo que a VM nasça sem IP público.

### Passo 4: Atualizar `outputs.tf`
Adicionamos `vm_name`, `vm_internal_ip` e `ssh_iap_command` em [`outputs.tf`](./outputs.tf).

---

## 3. Comandos de Execução e Validação

No terminal, dentro de `terraform/live-coding/`:

```bash
# 1. Formatar, validar e inspecionar o plano (+3 recursos: 2 Firewalls + 1 VM)
terraform fmt
terraform validate
terraform plan

# 2. Aplicar as mudanças
terraform apply
```

### Testando o Túnel SSH via Cloud IAP e o *Cliffhanger* do Almoço:

```bash
# 1. Copie e execute o comando gerado no output `ssh_iap_command`:
$(terraform output -raw ssh_iap_command)

# 2. Dentro da VM privada no GCP, inspecione a placa de rede e a tabela de rotas:
ip -br addr
ip route

# 3. Teste conectividade com a internet pública:
ping -c 3 8.8.8.8
# Resultado esperado: 100% packet loss!
# Pergunta para a volta do almoço: "Por que o pacote não voltou se a VPC tem rota para a internet e o Firewall libera saída?"
```

---

## 4. Checkpoint de Recuperação Rápida

Se precisar sincronizar sua pasta `terraform/live-coding/` com o gabarito completo desta Etapa 02:

```bash
cp ../labs/02-firewall-vms/*.tf ../live-coding/
```
