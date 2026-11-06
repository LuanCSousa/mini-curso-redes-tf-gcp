/* ============================================================================
   REDES.TF — CONTROLLER INTERATIVO DOS SLIDES (16:9 Auto-Scaler + Atalhos)
   ============================================================================ */

(function () {
  const STAGE_W = 1600;
  const STAGE_H = 900;

  let currentIndex = 0;
  let slides = [];
  let stageEl = null;
  let counterEl = null;
  let progressEl = null;

  function scaleStage() {
    if (!stageEl) return;
    const vw = window.innerWidth;
    const vh = window.innerHeight;
    const scale = Math.min((vw - 16) / STAGE_W, (vh - 16) / STAGE_H);
    stageEl.style.transform = `scale(${Math.max(0.2, scale)})`;
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

    window.location.hash = `slide-${currentIndex + 1}`;
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

  function setupCopyButtons() {
    document.querySelectorAll('.copy-btn').forEach((btn) => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        const codeWindow = btn.closest('.code-window');
        const pre = codeWindow ? codeWindow.querySelector('pre') : null;
        if (!pre) return;
        navigator.clipboard.writeText(pre.innerText).then(() => {
          const original = btn.textContent;
          btn.textContent = 'Copiado!';
          setTimeout(() => {
            btn.textContent = original;
          }, 1500);
        });
      });
    });
  }

  window.addEventListener('DOMContentLoaded', () => {
    stageEl = document.querySelector('.deck-stage');
    slides = Array.from(document.querySelectorAll('.slide'));
    counterEl = document.getElementById('slide-counter');
    progressEl = document.getElementById('slide-progress');

    // Remove qualquer elemento de notas na tela de projeção
    const legacyNotes = document.getElementById('speaker-notes');
    if (legacyNotes) legacyNotes.remove();
    const legacyBtnNotes = document.getElementById('btn-notes');
    if (legacyBtnNotes) legacyBtnNotes.remove();

    scaleStage();
    window.addEventListener('resize', scaleStage);

    const match = window.location.hash.match(/slide-(\d+)/);
    const startIdx = match ? Math.max(0, parseInt(match[1], 10) - 1) : 0;
    showSlide(startIdx);

    const btnPrev = document.getElementById('btn-prev');
    const btnNext = document.getElementById('btn-next');
    const btnFs = document.getElementById('btn-fs');

    if (btnPrev) btnPrev.addEventListener('click', prevSlide);
    if (btnNext) btnNext.addEventListener('click', nextSlide);
    if (btnFs) btnFs.addEventListener('click', toggleFullscreen);

    setupCopyButtons();

    window.addEventListener('keydown', (e) => {
      if (['INPUT', 'TEXTAREA'].includes(document.activeElement?.tagName)) return;

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
      } else if (e.key === 'p' || e.key === 'P') {
        e.preventDefault();
        window.print();
      }
    });
  });
})();
