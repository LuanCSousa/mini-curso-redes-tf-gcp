# Etapa 04 — Interconexão Privada Hub-and-Spoke com VPC Peering (`04-vpc-peering-hub`)

> **Horário no Cronograma:** Turno da Tarde (`15h00 – 16h05` e Desafio do Mural `16h25 – 16h40`)  
> **Modo de Ensino:** *Live Coding* evolutivo em `terraform/live-coding/` (adicionando `peering.tf` e testando a conectividade privada ponta a ponta com o Hub Central do Facilitador).

---

## 1. Objetivos de Redes e Cloud desta Etapa

1. **Arquitetura Hub-and-Spoke na Prática:** Conectar a VPC isolada do aluno (*Spoke*) à VPC Central do facilitador (*Hub*) usando exclusivamente a rede interna da Google (SDN Andromeda), sem passar pela internet pública e sem NAT.
2. **As 3 Leis de Ouro do VPC Network Peering:**
   - **Proibição de CIDR Overlap:** Colhendo os frutos do nosso planejamento `10.<student_id>.0.0/24` (Spokes) vs. `10.0.1.0/24` e `10.0.2.0/24` (Hubs).
   - **Acordo Bilateral:** Visualizar o estado mudando de `INACTIVE` para `ACTIVE` assim que o Hub Central aceita o Peering.
   - **Não-Transitividade:** Entender por que os alunos enxergam o Hub, mas continuam 100% isolados entre si.
3. **VPC Sharding para Escala (Cota de 25 Peerings/VPC do GCP):** Demonstrar com expressão condicional ternária (`var.student_id <= 20 ? "vpc-hub-turma-a" : "vpc-hub-turma-b"`) como arquitetar redes que escalam acima do limite de 25 peerings por VPC.

---

## 2. Sequência de Construção no *Live Coding* (`terraform/live-coding/`)

### Passo 1: Atualizar `variables.tf`, `locals.tf` e `terraform.tfvars`
- Adicionamos `hub_project_id` (default `"einfo-redes-hub-central"`) e `student_name` em [`variables.tf`](./variables.tf).
- Adicionamos a lógica condicional `is_turma_a`, `hub_vpc_name`, `hub_target_ip` e `hub_vpc_self_link` em [`locals.tf`](./locals.tf).

### Passo 2: Criar `peering.tf`
Criamos o arquivo [`peering.tf`](./peering.tf) com o recurso `google_compute_network_peering.peering_aluno_para_hub`.

### Passo 3: Atualizar `outputs.tf`
Adicionamos `peering_name`, `peering_state`, `hub_conectado` e `comando_checkin_mural` em [`outputs.tf`](./outputs.tf).

---

## 3. Comandos de Execução e Desafio do Mural ao Vivo

No terminal do seu computador, dentro de `terraform/live-coding/`:

```bash
# 1. Formatar, validar e aplicar o VPC Peering
terraform fmt
terraform validate
terraform apply

# 2. Assim que o Hub Central aceitar automaticamente o Peering, atualize o estado:
terraform apply -refresh-only
# Verifique que `peering_state = "ACTIVE"`!

# 3. Confira a nova rota privada importada automaticamente do Hub Central:
gcloud compute routes list --filter="network~vpc-redes-tf-aluno"
```

### Desafio do Mural ao Vivo (Dentro da sua VM Privada via SSH IAP):

```bash
# 1. Entre via SSH IAP na sua VM privada:
$(terraform output -raw ssh_iap_command)

# 2. Teste a latência de sub-milissegundo até a VM Coletora do Hub Central
#    (10.0.1.10 para Alunos 01..20 | 10.0.2.10 para Alunos 21..40):
ping -c 3 10.0.1.10   # (ou 10.0.2.10)

# 3. Dispare o comando de Check-in Privado copiado do output `comando_checkin_mural`:
curl -s -X POST http://10.0.1.10/checkin \
  -H 'Content-Type: application/json' \
  -d '{"student_id": 7, "nome": "Seu Nome", "subnet": "10.7.0.0/24"}'
```

Seu cartão com Nome, ID, Sub-rede `10.<ID>.0.0/24` e IP de origem real `10.<ID>.0.2` acenderá em verde ao vivo no telão da sala!

---

## 4. Checkpoint de Recuperação Rápida

Se precisar sincronizar sua pasta `terraform/live-coding/` com o gabarito completo desta Etapa 04:

```bash
cp ../labs/04-vpc-peering-hub/*.tf ../live-coding/
```
