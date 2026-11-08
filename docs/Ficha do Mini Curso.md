Redes.tf: da Teoria à Prática com Terraform e GCP — Ficha do Minicurso 

Redes.tf: da Teoria à Prática com Terraform e GCP 

Ficha executiva do minicurso — e-info 

**Facilitador:** Luan Sousa 

**Carga horária:** 8 horas 

**Modalidade:** Prática, com laboratório em nuvem (Google Cloud Platform) **Público:** Todos os níveis 

Facilitador 

**Luan Sousa** é Cloud Engineer na SantoDigital, parceira Google Cloud, onde atua no desenho, na implantação e na sustentação de infraestrutura em nuvem. Sua trajetória inclui projetos de fullstack, DevOps, infraestrutura e SecOps, o que traz ao curso uma visão completa de como redes são projetadas, automatizadas e protegidas em ambientes reais. É certificado Google Cloud Digital Leader e bacharelando em Ciência da Computação pela FACAPE. 

Ementa 

Um mergulho prático de 8 horas nos fundamentos de Infraestrutura de Redes, saindo da teoria de sala de aula direto para a nuvem. Usando o Google Cloud Platform e as boas práticas do Terraform, o curso conecta conceitos clássicos de redes (sub-redes, CIDR, roteamento, firewalls, NAT e interconexão privada via VPC Peering — com um comparativo com VPN, Shared VPC e PSC) com sua aplicação real em ambientes cloud modernos. 

Ao final, o participante terá construído e versionado, como código, uma infraestrutura de rede completa, entendendo o porquê de cada componente e não apenas como configurá-lo. 

Pré-requisitos para os participantes 

Noções básicas de GCP (o que é um projeto, como navegar no console). Noções básicas de redes, como endereço IP e o que é uma rede. Os demais conceitos serão revisados ao longo das aulas. 

Familiaridade básica com o terminal (linha de comando) é desejável. Conta Google (Gmail) ativa. 

Page 1 of 2  
Redes.tf: da Teoria à Prática com Terraform e GCP — Ficha do Minicurso 

**Pré-material:** antes do curso, cada participante receberá um material de preparação para validar o seu ambiente (*foundation*) no projeto GCP do seu grupo, incluindo conceitos como VPC peering. Os participantes são organizados em projetos de grupo (até 4 por projeto), onde cada um constrói a sua própria rede isolada; durante o curso, todas as redes são integradas a um projeto central mantido pelo facilitador. A conclusão do pré-material é necessária para acompanhar as atividades. 

Requisitos nos computadores 

Os participantes poderão usar os **laboratórios da instituição** ou o **notebook pessoal**. O projeto GCP do curso é fornecido pelo facilitador, portanto não é necessário cartão de crédito nem conta de cobrança. 

**Instalações necessárias (laboratório e notebook pessoal):** 

Terraform, versão 1.5 ou superior. 

Google Cloud CLI (gcloud). 

Git. 

Editor de código, preferencialmente VS Code, com a extensão *HashiCorp Terraform*. Navegador atualizado (Chrome, Firefox ou Edge). 

Cliente SSH (já incluso em Linux, macOS e Windows 10 ou superior). 

**Alternativa sem instalação:** quem preferir não instalar nada na máquina pessoal poderá usar o **Google Cloud Shell**, ambiente acessado pelo navegador que já vem com Terraform, gcloud e Git prontos. Basta uma conta Google. 

Solicitações à equipe técnica dos laboratórios 

Pré-instalar as ferramentas listadas acima nas máquinas, com antecedência ao dia do curso. 

Garantir acesso à internet com saída HTTPS (porta 443) liberada para os domínios do Google Cloud (*.googleapis.com, console.cloud.google.com, accounts.google.com e tunnel.cloudproxy.app — este último usado pelo SSH via Cloud IAP), para o registro e os downloads do Terraform (registry.terraform.io e releases.hashicorp.com) e para o GitHub (github.com). Não é necessário liberar a porta 22: o acesso SSH às VMs é feito por túnel HTTPS do Cloud IAP. 

Permitir o login em contas Google pessoais nos navegadores das máquinas. Page 2 of 2