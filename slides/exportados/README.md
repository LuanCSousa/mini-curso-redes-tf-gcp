# Slides Exportados (PDF e PPTX)

Versões exportadas das apresentações da manhã (`01-manha-redes-tf-gcp`) e da tarde (`02-tarde-redes-tf-gcp`).

| Arquivo | Conteúdo |
| :--- | :--- |
| `*.pdf` | PDF vetorial 16:9 (1 página por slide), gerado pelo CSS de impressão do próprio deck |
| `*.pptx` | PowerPoint com 1 imagem em alta resolução por slide + **notas do apresentador** |

## Como gerar ou atualizar

O HTML dos decks é a **única fonte** — nunca edite estes arquivos à mão. Na pasta `slides/`:

```bash
npm install
npm run setup    # uma vez: baixa o Chromium do Playwright
npm run export   # regenera os 4 arquivos desta pasta
```

> Alternativa manual (só PDF): abra o deck no Chrome/Edge, pressione **`P`** → **Salvar como PDF** (sem margens, com gráficos de fundo).
