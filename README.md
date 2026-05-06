# 🧠 BrainUp

BrainUp is a browser-based brain training application featuring three mini-games designed to challenge your memory, arithmetic speed, and reaction time.

## Games

| Game | Description |
|------|-------------|
| **Memory Match** | Flip cards to find matching emoji pairs as fast as possible. Score is based on moves taken and time elapsed. |
| **Math Sprint** | Answer addition, subtraction, and multiplication questions before a 30-second timer expires. |
| **Reaction Time** | Tap a target circle the moment it turns green across 5 rounds. Your average reaction time determines your score. |

## Getting Started

No build step required. Open `index.html` directly in any modern browser:

```bash
open index.html        # macOS
xdg-open index.html    # Linux
start index.html       # Windows
```

Or serve it with any static file server:

```bash
npx serve .
# then visit http://localhost:3000
```

## Project Structure

```
BrainUp/
├── index.html   # Application markup (all screens)
├── style.css    # Dark-theme styles
├── app.js       # Game logic and navigation
└── README.md
```

## Scoring

- **Memory Match** – `max(0, 1000 − moves×10 − seconds×2)`. Fewer moves and faster completion give higher scores.
- **Math Sprint** – Number of correct answers in 30 seconds.
- **Reaction Time** – `max(0, min(999, 1000 − avgMs))`. Lower average reaction time gives a higher score.

Personal best scores are stored in `localStorage` and displayed on the home screen.
