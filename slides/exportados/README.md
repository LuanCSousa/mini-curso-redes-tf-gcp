# Slides Exportados (PDF e PPTX)

Este diretório armazena as versões exportadas em **`.pdf`** e **`.pptx`** das apresentações da manhã (`01-manha-redes-tf-gcp`) e da tarde (`02-tarde-redes-tf-gcp`).

## Como gerar ou atualizar os arquivos desta pasta

1. **Via Navegador (PDF 16:9 com diagramas vetoriais):**
   - Abra [`../01-manha-teoria-base/index.html`](../01-manha-teoria-base/index.html) ou [`../02-tarde-pratica-avancada/index.html`](../02-tarde-pratica-avancada/index.html) no Chrome/Edge.
   - Pressione a tecla **`P`** (ou `Ctrl+P`) -> Destino: **Salvar como PDF** (Paisagem, sem margens, com gráficos de fundo ativos).
2. **Via Script Automatizado (`.pptx` nativo):**
   - Na pasta `slides/`, execute:
     ```bash
     node generate_exports.js
     ```
