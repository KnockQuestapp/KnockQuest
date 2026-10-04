(function () {
  const STORAGE_KEY = 'knockquest-tour-v1';
  const PROMPT_DELAY_MS = 1400;

  const steps = [
    {
      title: 'Navigation',
      body: 'Use the top and side areas to move between your main KnockQuest workspaces.',
      rect: () => areaRect('top-left'),
    },
    {
      title: 'Main workspace',
      body: 'This center area is where lists, maps, forms, and deal details appear while you work.',
      rect: () => areaRect('center'),
    },
    {
      title: 'Primary actions',
      body: 'Look to the lower and right-side controls for actions like adding, saving, scanning, or continuing a workflow.',
      rect: () => areaRect('bottom-right'),
    },
    {
      title: 'Need help later?',
      body: 'Tap the question mark anytime to replay this tour without leaving the app.',
      rect: () => helpButtonRect(),
    },
  ];

  let currentStep = 0;
  let active = false;
  let promptEl;
  let helpButton;
  let backdrop;
  let spotlight;
  let card;

  function init() {
    helpButton = document.createElement('button');
    helpButton.type = 'button';
    helpButton.className = 'kq-tour-help';
    helpButton.setAttribute('aria-label', 'Toggle app guide');
    helpButton.setAttribute('aria-pressed', 'false');
    helpButton.title = 'Toggle app guide';
    helpButton.textContent = '?';
    helpButton.addEventListener('click', toggleTour);
    document.body.appendChild(helpButton);

    if (!hasSeenTour()) {
      window.setTimeout(showPrompt, PROMPT_DELAY_MS);
    }

    window.addEventListener('resize', () => {
      if (active) renderStep();
    });
    window.addEventListener('keydown', handleKeydown);
  }

  function hasSeenTour() {
    try {
      return window.localStorage.getItem(STORAGE_KEY) === 'seen';
    } catch (_) {
      return false;
    }
  }

  function markSeen() {
    try {
      window.localStorage.setItem(STORAGE_KEY, 'seen');
    } catch (_) {
      // Storage may be unavailable in private browsing or locked-down embeds.
    }
  }

  function showPrompt() {
    if (active || hasSeenTour()) return;

    promptEl = document.createElement('section');
    promptEl.className = 'kq-tour-card kq-tour-prompt';
    promptEl.setAttribute('role', 'dialog');
    promptEl.setAttribute('aria-label', 'KnockQuest quick tour');
    promptEl.innerHTML = [
      '<h2>Want a quick tour?</h2>',
      '<p>See the key areas and controls while staying inside the app.</p>',
      '<div class="kq-tour-actions">',
      '<span class="kq-tour-progress">First visit</span>',
      '<div class="kq-tour-action-group">',
      '<button class="kq-tour-button ghost" type="button" data-tour-skip>Skip</button>',
      '<button class="kq-tour-button primary" type="button" data-tour-start>Start tour</button>',
      '</div>',
      '</div>',
    ].join('');

    promptEl.querySelector('[data-tour-start]').addEventListener('click', () => startTour(0));
    promptEl.querySelector('[data-tour-skip]').addEventListener('click', () => {
      markSeen();
      removePrompt();
    });
    document.body.appendChild(promptEl);
  }

  function removePrompt() {
    if (promptEl) {
      promptEl.remove();
      promptEl = undefined;
    }
  }

  function startTour(stepIndex) {
    removePrompt();
    active = true;
    currentStep = stepIndex;
    updateHelpButtonState();
    ensureTourElements();
    renderStep();
  }

  function ensureTourElements() {
    if (backdrop) return;

    backdrop = document.createElement('div');
    backdrop.className = 'kq-tour-backdrop';

    spotlight = document.createElement('div');
    spotlight.className = 'kq-tour-spotlight';

    card = document.createElement('section');
    card.className = 'kq-tour-card';
    card.setAttribute('role', 'dialog');
    card.setAttribute('aria-live', 'polite');

    document.body.append(backdrop, spotlight, card);
  }

  function renderStep() {
    const step = steps[currentStep];
    const rect = normalizeRect(step.rect());

    Object.assign(spotlight.style, {
      left: `${rect.left}px`,
      top: `${rect.top}px`,
      width: `${rect.width}px`,
      height: `${rect.height}px`,
    });

    const isLast = currentStep === steps.length - 1;
    card.innerHTML = [
      `<h2>${escapeHtml(step.title)}</h2>`,
      `<p>${escapeHtml(step.body)}</p>`,
      '<div class="kq-tour-actions">',
      `<span class="kq-tour-progress">${currentStep + 1} of ${steps.length}</span>`,
      '<div class="kq-tour-action-group">',
      currentStep > 0 ? '<button class="kq-tour-button" type="button" data-tour-prev>Back</button>' : '',
      '<button class="kq-tour-button ghost" type="button" data-tour-end>Skip</button>',
      `<button class="kq-tour-button primary" type="button" data-tour-next>${isLast ? 'Done' : 'Next'}</button>`,
      '</div>',
      '</div>',
    ].join('');

    const previous = card.querySelector('[data-tour-prev]');
    if (previous) previous.addEventListener('click', previousStep);
    card.querySelector('[data-tour-end]').addEventListener('click', endTour);
    card.querySelector('[data-tour-next]').addEventListener('click', () => {
      if (isLast) endTour();
      else nextStep();
    });

    positionCard(rect);
    card.querySelector('[data-tour-next]').focus({ preventScroll: true });
  }

  function nextStep() {
    currentStep = Math.min(currentStep + 1, steps.length - 1);
    renderStep();
  }

  function previousStep() {
    currentStep = Math.max(currentStep - 1, 0);
    renderStep();
  }

  function endTour() {
    active = false;
    markSeen();
    if (backdrop) backdrop.remove();
    if (spotlight) spotlight.remove();
    if (card) card.remove();
    backdrop = undefined;
    spotlight = undefined;
    card = undefined;
    updateHelpButtonState();
    if (helpButton) helpButton.focus({ preventScroll: true });
  }

  function toggleTour() {
    if (active) {
      endTour();
      return;
    }

    startTour(0);
  }

  function updateHelpButtonState() {
    if (!helpButton) return;
    helpButton.setAttribute('aria-pressed', active ? 'true' : 'false');
    helpButton.title = active ? 'Turn guide off' : 'Turn guide on';
  }

  function handleKeydown(event) {
    if (!active) return;
    if (event.key === 'Escape') endTour();
    if (event.key === 'ArrowRight') nextStep();
    if (event.key === 'ArrowLeft') previousStep();
  }

  function positionCard(rect) {
    const margin = 16;
    const cardWidth = Math.min(360, window.innerWidth - margin * 2);
    const estimatedHeight = card.offsetHeight || 190;
    let left = rect.left;
    let top = rect.bottom + margin;

    if (top + estimatedHeight > window.innerHeight - margin) {
      top = rect.top - estimatedHeight - margin;
    }
    if (top < margin) {
      top = window.innerHeight - estimatedHeight - margin;
    }
    if (top < margin) {
      top = margin;
    }

    if (left + cardWidth > window.innerWidth - margin) {
      left = window.innerWidth - cardWidth - margin;
    }
    if (left < margin) {
      left = margin;
    }

    card.style.left = `${left}px`;
    card.style.top = `${top}px`;
  }

  function areaRect(area) {
    const width = window.innerWidth;
    const height = window.innerHeight;
    const compact = width < 720;

    if (area === 'top-left') {
      return {
        left: 12,
        top: 12,
        width: compact ? Math.min(width - 24, 260) : Math.min(width * 0.38, 360),
        height: compact ? 82 : 96,
      };
    }

    if (area === 'bottom-right') {
      const boxWidth = compact ? Math.min(width - 24, 280) : Math.min(width * 0.36, 360);
      const boxHeight = compact ? 112 : 150;
      return {
        left: width - boxWidth - 12,
        top: height - boxHeight - 72,
        width: boxWidth,
        height: boxHeight,
      };
    }

    return {
      left: compact ? 12 : Math.max(88, width * 0.18),
      top: compact ? 112 : 116,
      width: compact ? width - 24 : Math.min(width * 0.68, width - 140),
      height: compact ? Math.max(220, height - 270) : Math.max(260, height - 250),
    };
  }

  function helpButtonRect() {
    if (!helpButton) return areaRect('bottom-right');
    const rect = helpButton.getBoundingClientRect();
    return {
      left: rect.left - 8,
      top: rect.top - 8,
      width: rect.width + 16,
      height: rect.height + 16,
    };
  }

  function normalizeRect(rect) {
    const padding = 2;
    const left = Math.max(8, rect.left - padding);
    const top = Math.max(8, rect.top - padding);
    const maxWidth = window.innerWidth - left - 8;
    const maxHeight = window.innerHeight - top - 8;

    return {
      left,
      top,
      width: Math.max(44, Math.min(rect.width + padding * 2, maxWidth)),
      height: Math.max(44, Math.min(rect.height + padding * 2, maxHeight)),
      get bottom() {
        return this.top + this.height;
      },
    };
  }

  function escapeHtml(value) {
    return value.replace(/[&<>"']/g, (character) => ({
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#39;',
    })[character]);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init, { once: true });
  } else {
    init();
  }
})();
