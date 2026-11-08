/* ============================================================================
   REDES.TF — CONTROLLER INTERATIVO DOS SLIDES (16:9 Auto-Scaler + Atalhos)
   ----------------------------------------------------------------------------
   Atalhos:  → / PageDown / Espaço = próximo   ← / PageUp = anterior
             Home / End = primeiro / último     F = tela cheia
             N = painel de notas (ensaio)       S = janela do apresentador
             P = imprimir / PDF
   Notas do apresentador: <aside class="notes"> dentro de cada <section class="slide">.
   ============================================================================ */

(function () {
  const STAGE_W = 1600;
  const STAGE_H = 900;

  let currentIndex = 0;
  let slides = [];
  let stageEl = null;
  let counterEl = null;
  let progressEl = null;
  let notesDrawer = null;
  let presenterWin = null;
  let presenterStart = null;

  function scaleStage() {
    if (!stageEl) return;
    const vw = window.innerWidth;
    const vh = window.innerHeight;
    const scale = Math.min((vw - 16) / STAGE_W, (vh - 16) / STAGE_H);
    stageEl.style.transform = `scale(${Math.max(0.2, scale)})`;
  }

  function slideNotes(idx) {
    const aside = slides[idx] ? slides[idx].querySelector('aside.notes') : null;
    return aside ? aside.textContent.trim() : '';
  }

  function slideTitle(idx) {
    if (!slides[idx]) return '';
    const h = slides[idx].querySelector('h2, h1');
    return h ? h.textContent.replace(/\s+/g, ' ').trim() : `Slide ${idx + 1}`;
  }

  function indexFromHash() {
    const match = window.location.hash.match(/slide-(\d+)/);
    return match ? Math.max(0, parseInt(match[1], 10) - 1) : 0;
  }

  function showSlide(index) {
    if (!slides.length) return;
    currentIndex = Math.max(0, Math.min(index, slides.length - 1));

    slides.forEach((s, idx) => {
      s.classList.toggle('active', idx === currentIndex);
    });

    if (counterEl) {
      const cur = String(currentIndex + 1).padStart(2, '0');
      const tot = String(slides.length).padStart(2, '0');
      counterEl.textContent = `${cur} / ${tot}`;
    }

    if (progressEl) {
      const pct = ((currentIndex + 1) / slides.length) * 100;
      progressEl.style.width = `${pct}%`;
    }

    // replaceState: atualiza o link sem empilhar uma entrada no histórico por slide
    const hash = `#slide-${currentIndex + 1}`;
    if (window.location.hash !== hash) {
      try {
        history.replaceState(null, '', hash);
      } catch (e) {
        window.location.hash = hash;
      }
    }

    updateNotesDrawer();
    updatePresenter();
  }

  function nextSlide() {
    showSlide(currentIndex + 1);
  }

  function prevSlide() {
    showSlide(currentIndex - 1);
  }

  function toggleFullscreen() {
    if (!document.fullscreenElement) {
      document.documentElement.requestFullscreen().catch(() => {});
    } else {
      document.exitFullscreen().catch(() => {});
    }
  }

  /* ---------------- Notas: painel sobreposto (ensaio em 1 tela) ---------------- */
  function buildNotesDrawer() {
    notesDrawer = document.createElement('div');
    notesDrawer.className = 'notes-drawer';
    notesDrawer.setAttribute('aria-live', 'polite');
    document.body.appendChild(notesDrawer);
  }

  function updateNotesDrawer() {
    if (!notesDrawer) return;
    const txt = slideNotes(currentIndex) || 'Sem notas para este slide.';
    notesDrawer.innerHTML = '';
    const head = document.createElement('div');
    head.className = 'notes-drawer-head';
    head.textContent = `Notas • Slide ${currentIndex + 1}/${slides.length}  (N fecha • S abre a janela do apresentador)`;
    const body = document.createElement('div');
    body.textContent = txt;
    notesDrawer.append(head, body);
  }

  function toggleNotesDrawer() {
    if (!notesDrawer) return;
    notesDrawer.classList.toggle('open');
  }

  /* ---------------- Janela do apresentador (2º monitor) ---------------- */
  function openPresenter() {
    if (presenterWin && !presenterWin.closed) {
      presenterWin.focus();
      return;
    }
    presenterWin = window.open('', 'redes-tf-presenter', 'width=900,height=640');
    if (!presenterWin) return; // pop-up bloqueado
    presenterStart = Date.now();
    const d = presenterWin.document;
    d.open();
    d.write(`<!DOCTYPE html><html lang="pt-BR"><head><meta charset="UTF-8"><title>Apresentador — Redes.tf</title>
<style>
  body{margin:0;padding:24px;background:#0B1120;color:#F8FAFC;font-family:system-ui,sans-serif}
  .top{display:flex;justify-content:space-between;font-family:monospace;color:#94A3B8;font-size:15px}
  h1{font-size:24px;margin:12px 0 4px}
  #notes{font-size:22px;line-height:1.5;white-space:pre-wrap;margin-top:16px;color:#E2E8F0}
  #next{margin-top:24px;color:#94A3B8;font-size:16px}
  button{background:#1A2642;color:#F8FAFC;border:1px solid #334155;border-radius:8px;padding:8px 14px;font-size:15px;cursor:pointer;margin-right:8px}
</style></head><body>
<div class="top"><span id="counter"></span><span id="timer">00:00</span><span id="clock"></span></div>
<h1 id="title"></h1>
<div><button id="prev">← Anterior</button><button id="next-btn">Próximo →</button></div>
<div id="notes"></div>
<div id="next"></div>
</body></html>`);
    d.close();
    d.getElementById('prev').addEventListener('click', prevSlide);
    d.getElementById('next-btn').addEventListener('click', nextSlide);
    presenterWin.addEventListener('keydown', handleKey);
    updatePresenter();
  }

  function pad(n) {
    return String(n).padStart(2, '0');
  }

  function updatePresenter() {
    if (!presenterWin || presenterWin.closed) return;
    const d = presenterWin.document;
    const set = (id, txt) => {
      const el = d.getElementById(id);
      if (el) el.textContent = txt;
    };
    set('counter', `Slide ${currentIndex + 1} / ${slides.length}`);
    set('title', slideTitle(currentIndex));
    set('notes', slideNotes(currentIndex) || 'Sem notas para este slide.');
    set('next', currentIndex + 1 < slides.length ? `Próximo: ${slideTitle(currentIndex + 1)}` : 'Fim do deck.');
  }

  function tickPresenter() {
    if (!presenterWin || presenterWin.closed) return;
    const d = presenterWin.document;
    const secs = Math.floor((Date.now() - presenterStart) / 1000);
    const t = d.getElementById('timer');
    const c = d.getElementById('clock');
    if (t) t.textContent = `⏱ ${pad(Math.floor(secs / 60))}:${pad(secs % 60)}`;
    if (c) c.textContent = new Date().toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
  }

  /* ---------------- Botões "Copiar" (com fallback fora de HTTPS) ---------------- */
  function copyText(text) {
    if (navigator.clipboard && window.isSecureContext) {
      return navigator.clipboard.writeText(text);
    }
    return new Promise((resolve, reject) => {
      const ta = document.createElement('textarea');
      ta.value = text;
      ta.setAttribute('readonly', '');
      ta.style.position = 'fixed';
      ta.style.opacity = '0';
      document.body.appendChild(ta);
      ta.select();
      try {
        document.execCommand('copy') ? resolve() : reject(new Error('copy falhou'));
      } catch (err) {
        reject(err);
      } finally {
        ta.remove();
      }
    });
  }

  function setupCopyButtons() {
    document.querySelectorAll('.copy-btn').forEach((btn) => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        const codeWindow = btn.closest('.code-window');
        const pre = codeWindow ? codeWindow.querySelector('pre') : null;
        if (!pre) return;
        const original = btn.textContent;
        copyText(pre.innerText)
          .then(() => {
            btn.textContent = 'Copiado!';
          })
          .catch(() => {
            btn.textContent = 'Selecione e copie';
          })
          .finally(() => {
            setTimeout(() => {
              btn.textContent = original;
            }, 1500);
          });
      });
    });
  }

  /* ---------------- Teclado ---------------- */
  function handleKey(e) {
    const active = (e.target && e.target.ownerDocument ? e.target.ownerDocument.activeElement : document.activeElement);
    if (active && ['INPUT', 'TEXTAREA'].includes(active.tagName)) return;

    if (e.key === 'ArrowRight' || e.key === 'PageDown' || e.key === ' ') {
      e.preventDefault();
      nextSlide();
    } else if (e.key === 'ArrowLeft' || e.key === 'PageUp') {
      e.preventDefault();
      prevSlide();
    } else if (e.key === 'Home') {
      e.preventDefault();
      showSlide(0);
    } else if (e.key === 'End') {
      e.preventDefault();
      showSlide(slides.length - 1);
    } else if (e.key === 'f' || e.key === 'F') {
      e.preventDefault();
      toggleFullscreen();
    } else if (e.key === 'n' || e.key === 'N') {
      e.preventDefault();
      toggleNotesDrawer();
    } else if (e.key === 's' || e.key === 'S') {
      e.preventDefault();
      openPresenter();
    } else if (e.key === 'p' || e.key === 'P') {
      e.preventDefault();
      window.print();
    }
  }

  window.addEventListener('DOMContentLoaded', () => {
    stageEl = document.querySelector('.deck-stage');
    slides = Array.from(document.querySelectorAll('.slide'));
    counterEl = document.getElementById('slide-counter');
    progressEl = document.getElementById('slide-progress');

    buildNotesDrawer();
    scaleStage();
    window.addEventListener('resize', scaleStage);

    showSlide(indexFromHash());

    // Navegação por link/hash manual (ex: colar ...#slide-7 na barra de endereço)
    window.addEventListener('hashchange', () => {
      const idx = indexFromHash();
      if (idx !== currentIndex) showSlide(idx);
    });

    const btnPrev = document.getElementById('btn-prev');
    const btnNext = document.getElementById('btn-next');
    const btnFs = document.getElementById('btn-fs');

    if (btnPrev) btnPrev.addEventListener('click', prevSlide);
    if (btnNext) btnNext.addEventListener('click', nextSlide);
    if (btnFs) btnFs.addEventListener('click', toggleFullscreen);

    setupCopyButtons();
    window.addEventListener('keydown', handleKey);
    setInterval(tickPresenter, 1000);
    window.addEventListener('beforeunload', () => {
      if (presenterWin && !presenterWin.closed) presenterWin.close();
    });
  });
})();
