/* ============================================================================
   REDES.TF — GERADOR DE EXPORTAÇÕES (PDF + PPTX) A PARTIR DO HTML
   ----------------------------------------------------------------------------
   O HTML dos decks é a ÚNICA fonte de conteúdo. Este script:
     1. Abre cada deck no Chromium (Playwright) em 1600x900;
     2. PDF: usa o CSS de impressão (@page 1600x900) -> 1 página vetorial por slide;
     3. PPTX: captura cada slide como imagem (2x) e anexa as notas do apresentador
        extraídas de <aside class="notes">.
   Nunca redigite conteúdo de slide aqui: edite o HTML e rode `npm run export`.

   Pré-requisitos (uma vez):  npm install && npx playwright install chromium
   ============================================================================ */

const path = require('path');
const fs = require('fs');
const { pathToFileURL } = require('url');
const { chromium } = require('playwright');
const PptxGenJS = require('pptxgenjs');

const ROOT = __dirname;
const OUT_DIR = path.join(ROOT, 'exportados');

const DECKS = [
  {
    html: path.join(ROOT, '01-manha-teoria-base', 'index.html'),
    base: '01-manha-redes-tf-gcp',
    title: 'Redes.tf — Turno da Manhã (08h00–12h00)',
  },
  {
    html: path.join(ROOT, '02-tarde-pratica-avancada', 'index.html'),
    base: '02-tarde-redes-tf-gcp',
    title: 'Redes.tf — Turno da Tarde (14h00–18h00)',
  },
];

// Congela animações/transições para capturas determinísticas
const FREEZE_CSS = `
  *, *::before, *::after { transition: none !important; animation: none !important; }
  .notes-drawer, .deck-footer, .progress-track { display: none !important; }
`;

async function exportDeck(browser, deck) {
  const url = pathToFileURL(deck.html).href;

  // ---------- PDF (vetorial, via CSS de impressão) ----------
  const pdfPage = await browser.newPage({ viewport: { width: 1600, height: 900 } });
  await pdfPage.goto(url, { waitUntil: 'load' });
  await pdfPage.evaluate(() => document.fonts.ready);
  const pdfPath = path.join(OUT_DIR, `${deck.base}.pdf`);
  await pdfPage.pdf({ path: pdfPath, printBackground: true, preferCSSPageSize: true });
  await pdfPage.close();

  // ---------- PPTX (imagem por slide + notas) ----------
  // Viewport 1616x916 => o auto-scaler do slides.js resulta em escala 1:1.
  const page = await browser.newPage({ viewport: { width: 1616, height: 916 }, deviceScaleFactor: 2 });
  await page.goto(url, { waitUntil: 'load' });
  await page.addStyleTag({ content: FREEZE_CSS });
  await page.evaluate(() => document.fonts.ready);

  const total = await page.locator('section.slide').count();
  const pptx = new PptxGenJS();
  pptx.layout = 'LAYOUT_16x9'; // 10 x 5.625 in
  pptx.author = 'Luan Sousa';
  pptx.company = 'e-info 2026 • FACAPE';
  pptx.title = deck.title;

  for (let i = 0; i < total; i += 1) {
    await page.evaluate((idx) => {
      document.querySelectorAll('section.slide').forEach((s, j) => s.classList.toggle('active', j === idx));
    }, i);
    const slideEl = page.locator('section.slide').nth(i);
    const img = await slideEl.screenshot({ type: 'jpeg', quality: 88 });
    const notes = await slideEl.evaluate((el) => {
      const aside = el.querySelector('aside.notes');
      return aside ? aside.textContent.trim() : '';
    });

    const s = pptx.addSlide();
    s.background = { color: '0B1120' };
    s.addImage({ data: `data:image/jpeg;base64,${img.toString('base64')}`, x: 0, y: 0, w: 10, h: 5.625 });
    if (notes) s.addNotes(notes);
  }
  await page.close();

  const pptxPath = path.join(OUT_DIR, `${deck.base}.pptx`);
  await pptx.writeFile({ fileName: pptxPath });
  return { pdfPath, pptxPath, total };
}

(async () => {
  fs.mkdirSync(OUT_DIR, { recursive: true });
  const browser = await chromium.launch();
  try {
    for (const deck of DECKS) {
      const r = await exportDeck(browser, deck);
      console.log(`[OK] ${deck.base} (${r.total} slides)`);
      console.log(`     -> ${path.relative(ROOT, r.pdfPath)}`);
      console.log(`     -> ${path.relative(ROOT, r.pptxPath)}`);
    }
  } finally {
    await browser.close();
  }
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
