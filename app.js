/**
 * BrainUp – app.js
 * Brain-training mini-games: Memory Match, Math Sprint, Reaction Time
 */

/* ═══════════════════════════════════════════════════
   NAVIGATION
   ═══════════════════════════════════════════════════ */
const screens = {
  home:     document.getElementById('screen-home'),
  memory:   document.getElementById('screen-memory'),
  math:     document.getElementById('screen-math'),
  reaction: document.getElementById('screen-reaction'),
};

function showScreen(name) {
  Object.values(screens).forEach(s => s.classList.remove('active'));
  screens[name].classList.add('active');
}

// Game cards on home screen
document.querySelectorAll('.game-card').forEach(btn => {
  btn.addEventListener('click', () => {
    const game = btn.dataset.game;
    showScreen(game);
    if (game === 'memory')   initMemory();
    if (game === 'math')     initMath();
    if (game === 'reaction') initReaction();
  });
});

// Back buttons
document.querySelectorAll('.back-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    stopAll();
    showScreen('home');
    renderScores();
  });
});

/* ═══════════════════════════════════════════════════
   SCORE STORAGE
   ═══════════════════════════════════════════════════ */
const SCORE_KEY = 'brainup_scores';

function getScores() {
  try { return JSON.parse(localStorage.getItem(SCORE_KEY)) || {}; }
  catch { return {}; }
}

function saveScore(game, value) {
  // All scores are stored as "higher = better".
  // For Reaction Time the raw avg-ms is inverted before being passed here
  // (score = 1000 − avg), so higher stored values still mean better performance.
  const scores = getScores();
  if (scores[game] === undefined || value > scores[game]) {
    scores[game] = value;
    localStorage.setItem(SCORE_KEY, JSON.stringify(scores));
  }
}

function renderScores() {
  const body  = document.getElementById('score-table-body');
  const scores = getScores();
  const labels = { memory: 'Memory Match', math: 'Math Sprint', reaction: 'Reaction Time' };
  const units  = { memory: ' pts', math: ' pts', reaction: ' pts' };
  body.innerHTML = '';
  Object.keys(labels).forEach(key => {
    const tr = document.createElement('tr');
    tr.innerHTML = `<td>${labels[key]}</td><td>${
      scores[key] !== undefined ? scores[key] + units[key] : '—'
    }</td>`;
    body.appendChild(tr);
  });
}

renderScores();

/* ═══════════════════════════════════════════════════
   STOP-ALL  (called when navigating back)
   ═══════════════════════════════════════════════════ */
function stopAll() {
  clearInterval(memoryTimer);
  clearInterval(mathTimer);
  clearTimeout(reactionTimeout);
}

/* ═══════════════════════════════════════════════════
   1. MEMORY MATCH
   ═══════════════════════════════════════════════════ */
const EMOJIS = ['🐶','🐱','🦊','🐸','🦁','🐼','🦄','🐙'];

let memoryMoves      = 0;
let memorySeconds    = 0;
let memoryTimer      = null;
let memoryFlipped    = [];
let memoryLocked     = false;
let memoryMatchCount = 0;

function initMemory() {
  memoryMoves = memorySeconds = memoryMatchCount = 0;
  memoryFlipped = [];
  memoryLocked  = false;

  document.getElementById('memory-moves').textContent = '0';
  document.getElementById('memory-time').textContent  = '0s';
  document.getElementById('memory-result').classList.add('hidden');

  clearInterval(memoryTimer);

  const pairs = [...EMOJIS, ...EMOJIS];
  shuffle(pairs);

  const board = document.getElementById('memory-board');
  board.innerHTML = '';

  pairs.forEach((emoji, i) => {
    const card = document.createElement('div');
    card.className = 'mem-card';
    card.dataset.emoji = emoji;
    card.dataset.index = i;
    card.innerHTML = `
      <div class="mem-back">❓</div>
      <div class="mem-front">${emoji}</div>`;
    card.addEventListener('click', onMemoryCardClick);
    board.appendChild(card);
  });

  memoryTimer = setInterval(() => {
    memorySeconds++;
    document.getElementById('memory-time').textContent = memorySeconds + 's';
  }, 1000);
}

function onMemoryCardClick(e) {
  const card = e.currentTarget;
  if (memoryLocked) return;
  if (card.classList.contains('flipped') || card.classList.contains('matched')) return;

  card.classList.add('flipped');
  memoryFlipped.push(card);

  if (memoryFlipped.length === 2) {
    memoryLocked = true;
    memoryMoves++;
    document.getElementById('memory-moves').textContent = memoryMoves;

    const [a, b] = memoryFlipped;
    if (a.dataset.emoji === b.dataset.emoji) {
      a.classList.add('matched');
      b.classList.add('matched');
      memoryFlipped = [];
      memoryLocked  = false;
      memoryMatchCount++;
      if (memoryMatchCount === EMOJIS.length) endMemory();
    } else {
      setTimeout(() => {
        a.classList.remove('flipped');
        b.classList.remove('flipped');
        memoryFlipped = [];
        memoryLocked  = false;
      }, 900);
    }
  }
}

function endMemory() {
  clearInterval(memoryTimer);
  // Score: higher is better; penalise extra moves and time
  const score = Math.max(0, 1000 - memoryMoves * 10 - memorySeconds * 2);
  saveScore('memory', score);

  const el = document.getElementById('memory-result');
  el.classList.remove('hidden');
  document.getElementById('memory-result-text').innerHTML =
    `🎉 Completed in <strong>${memorySeconds}s</strong> with <strong>${memoryMoves}</strong> moves!<br>Score: <strong>${score} pts</strong>`;
}

document.getElementById('memory-play-again').addEventListener('click', initMemory);

/* ═══════════════════════════════════════════════════
   2. MATH SPRINT
   ═══════════════════════════════════════════════════ */
const MATH_DURATION = 30; // seconds

let mathScore     = 0;
let mathRemaining = MATH_DURATION;
let mathTimer     = null;
let mathAnswered  = false;

function initMath() {
  mathScore     = 0;
  mathRemaining = MATH_DURATION;
  mathAnswered  = false;

  document.getElementById('math-score').textContent = '0';
  document.getElementById('math-timer').textContent = MATH_DURATION + 's';
  document.getElementById('math-result').classList.add('hidden');
  document.getElementById('math-content').classList.remove('hidden');

  clearInterval(mathTimer);
  mathTimer = setInterval(() => {
    mathRemaining--;
    document.getElementById('math-timer').textContent = mathRemaining + 's';
    if (mathRemaining <= 0) endMath();
  }, 1000);

  nextMathQuestion();
}

function nextMathQuestion() {
  if (mathRemaining <= 0) return;
  mathAnswered = false;

  const ops = ['+', '-', '×'];
  const op  = ops[randInt(0, ops.length - 1)];
  let a, b, answer;

  if (op === '+')      { a = randInt(1, 50);  b = randInt(1, 50);  answer = a + b; }
  else if (op === '-') { a = randInt(10, 99); b = randInt(1, a);   answer = a - b; }
  else                 { a = randInt(2, 12);  b = randInt(2, 12);  answer = a * b; }

  document.getElementById('math-question').textContent = `${a} ${op} ${b} = ?`;

  // Build 4 answer choices (one correct, three distractors)
  const choices = generateChoices(answer);
  const grid = document.getElementById('math-options');
  grid.innerHTML = '';

  choices.forEach(choice => {
    const btn = document.createElement('button');
    btn.className = 'option-btn';
    btn.textContent = choice;
    btn.addEventListener('click', () => onMathChoice(btn, choice, answer));
    grid.appendChild(btn);
  });
}

function onMathChoice(btn, chosen, correct) {
  if (mathAnswered) return;
  mathAnswered = true;

  const allBtns = document.querySelectorAll('.option-btn');
  allBtns.forEach(b => {
    b.disabled = true;
    if (Number(b.textContent) === correct) b.classList.add('correct');
  });

  if (chosen === correct) {
    mathScore++;
    document.getElementById('math-score').textContent = mathScore;
    btn.classList.add('correct');
  } else {
    btn.classList.add('wrong');
  }

  setTimeout(nextMathQuestion, 600);
}

function endMath() {
  clearInterval(mathTimer);
  document.getElementById('math-content').classList.add('hidden');
  saveScore('math', mathScore);

  const el = document.getElementById('math-result');
  el.classList.remove('hidden');
  document.getElementById('math-result-text').innerHTML =
    `Time's up! You answered <strong>${mathScore}</strong> question${mathScore !== 1 ? 's' : ''} correctly.<br>Score: <strong>${mathScore} pts</strong>`;
}

document.getElementById('math-play-again').addEventListener('click', initMath);

/* ═══════════════════════════════════════════════════
   3. REACTION TIME
   ═══════════════════════════════════════════════════ */
const REACTION_ROUNDS = 5;

let reactionRound    = 0;
let reactionTimes    = [];
let reactionStart    = 0;
let reactionWaiting  = false;
let reactionTimeout  = null;
let reactionActive   = false;

function initReaction() {
  reactionRound   = 0;
  reactionTimes   = [];
  reactionWaiting = false;
  reactionActive  = false;

  clearTimeout(reactionTimeout);

  const target = document.getElementById('reaction-target');
  target.classList.add('hidden');
  target.classList.remove('go');

  document.getElementById('reaction-round').textContent = '1';
  document.getElementById('reaction-avg').textContent   = '—';
  document.getElementById('reaction-instruction').textContent = 'Press Start to begin.';
  document.getElementById('reaction-start-btn').classList.remove('hidden');
  document.getElementById('reaction-result').classList.add('hidden');
  document.getElementById('reaction-arena').classList.remove('hidden');
}

document.getElementById('reaction-start-btn').addEventListener('click', () => {
  document.getElementById('reaction-start-btn').classList.add('hidden');
  startReactionRound();
});

function startReactionRound() {
  if (reactionRound >= REACTION_ROUNDS) { endReaction(); return; }

  reactionActive  = false;
  reactionWaiting = true;

  const target = document.getElementById('reaction-target');
  target.classList.add('hidden');
  target.classList.remove('go');
  document.getElementById('reaction-instruction').textContent = 'Wait for the green circle…';

  const delay = randInt(1500, 4000);
  reactionTimeout = setTimeout(() => {
    if (!reactionWaiting) return;
    reactionWaiting = false;
    reactionActive  = true;
    reactionStart   = Date.now();
    target.classList.remove('hidden');
    target.classList.add('go');
    document.getElementById('reaction-instruction').textContent = 'TAP NOW!';
  }, delay);
}

document.getElementById('reaction-target').addEventListener('click', () => {
  const target = document.getElementById('reaction-target');

  if (!reactionActive) {
    // Clicked too early
    if (reactionWaiting) {
      clearTimeout(reactionTimeout);
      reactionWaiting = false;
      document.getElementById('reaction-instruction').textContent = 'Too early! Waiting…';
      setTimeout(startReactionRound, 1200);
    }
    return;
  }

  const elapsed = Date.now() - reactionStart;
  reactionActive = false;
  reactionTimes.push(elapsed);
  reactionRound++;

  const avg = calcAvgReaction();
  // Only update the round counter while there are more rounds to play
  if (reactionRound < REACTION_ROUNDS) {
    document.getElementById('reaction-round').textContent = reactionRound + 1;
  }
  document.getElementById('reaction-avg').textContent   = avg + 'ms';
  document.getElementById('reaction-instruction').textContent = `Round ${reactionRound}: ${elapsed}ms`;

  target.classList.add('hidden');
  target.classList.remove('go');

  if (reactionRound < REACTION_ROUNDS) {
    setTimeout(startReactionRound, 800);
  } else {
    setTimeout(endReaction, 600);
  }
});

function endReaction() {
  const arena = document.getElementById('reaction-arena');
  const result = document.getElementById('reaction-result');

  arena.classList.add('hidden');
  result.classList.remove('hidden');

  const avg   = calcAvgReaction();
  const best  = Math.min(...reactionTimes);
  const worst = Math.max(...reactionTimes);
  // Lower avg = better; invert for a "score" (cap at 999)
  const score = Math.max(0, Math.min(999, Math.round(1000 - avg)));
  saveScore('reaction', score);

  document.getElementById('reaction-result-text').innerHTML =
    `Average: <strong>${avg}ms</strong> &nbsp;|&nbsp; Best: <strong>${best}ms</strong> &nbsp;|&nbsp; Worst: <strong>${worst}ms</strong><br>Score: <strong>${score} pts</strong>`;
}

document.getElementById('reaction-play-again').addEventListener('click', () => {
  document.getElementById('reaction-arena').classList.remove('hidden');
  initReaction();
});

/* ═══════════════════════════════════════════════════
   UTILITIES
   ═══════════════════════════════════════════════════ */
function calcAvgReaction() {
  if (reactionTimes.length === 0) return 0;
  return Math.round(reactionTimes.reduce((a, b) => a + b, 0) / reactionTimes.length);
}

function shuffle(arr) {
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

function randInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function generateChoices(correct) {
  // Distractors are offset by up to ±15 from the correct answer so they
  // are plausible but clearly distinct from one another.
  const MAX_CHOICE_OFFSET = 15;
  const set = new Set([correct]);
  while (set.size < 4) {
    const offset = randInt(-MAX_CHOICE_OFFSET, MAX_CHOICE_OFFSET);
    const candidate = correct + offset;
    if (candidate !== correct && candidate >= 0) set.add(candidate);
  }
  return shuffle([...set]);
}
