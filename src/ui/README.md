# UI / Front-End

The front-end shell of Space Rangers.

- `theme/`   — design system (tokens + Theme resource). Single source of truth for look.
- `screens/` — each screen is a vertical slice (own folder: scene + script + README).
- `framework/` — [added at screen #2] reusable UI engine: screen manager, transitions, components.
- `shell/`     — [added at screen #2] persistent front-end root hosting the screen manager + animated background.
