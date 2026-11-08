# Documentação da Ementa e Roteiro de Aula — Redes.tf (8h)

Esta pasta reúne o planejamento pedagógico e o guia de condução minuto a minuto do minicurso **"Redes.tf: da Teoria à Prática com Terraform e GCP"** (**e-info / FACAPE**).

## Documentos Disponíveis

1. **[`ementa-completa.md`](./ementa-completa.md) — Ementa Pedagógica e Técnica Completa:**
   - Proposta pedagógica (*Zero ClickOps*, construção do zero ao fim via *Live Coding*).
   - Matriz de correlação: **Conceito Clássico de Redes × Recurso Google Cloud × Recurso Terraform**.
   - Arquitetura do Desafio do Mural Central (*Hub-and-Spoke* com 2 VPCs de Hub — VMs coletoras `e2-micro` em `10.0.1.10` e `10.0.2.10` — + painel em tempo real no **Cloud Run**).
   - Cronograma detalhado dos 8 módulos divididos entre **Manhã (`08h00–12h00`)** e **Tarde (`14h00–18h00`)**.

2. **[`roteiro-minuto-a-minuto.md`](./roteiro-minuto-a-minuto.md) — Guia de Palco e Condução do Facilitador (Luan Sousa):**
   - Checklist da véspera (Hub de pé + ensaio ponta a ponta) e da manhã do curso (30 min antes das `08h00`).
   - Cronograma minuto a minuto indicando o que projetar nos slides, o que codificar ao vivo em cada etapa, quais comandos executar e como conduzir os momentos de validação (como o gancho do *100% packet loss* antes do almoço e o check-in no Mural via VPC Peering à tarde).
   - Dicas rápidas de *troubleshooting* para destravar alunos durante os laboratórios.
