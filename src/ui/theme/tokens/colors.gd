class_name UIColors
## Design-system color tokens — the single source of truth for UI color.
## The Theme resource (space_rangers_theme.tres) mirrors these values for the
## editor; code that styles UI at runtime should read them from here.
extends Object

const BACKGROUND := Color(0.03, 0.05, 0.1, 1.0)   # deep space
const SURFACE := Color(0.08, 0.15, 0.25, 0.95)    # panels / buttons
const SURFACE_HOVER := Color(0.12, 0.22, 0.35, 0.98)
const SURFACE_PRESSED := Color(0.05, 0.1, 0.18, 1.0)
const BORDER := Color(0.3, 0.7, 1.0, 0.75)        # accent border
const ACCENT := Color(0.25, 0.75, 1.0, 1.0)       # rangers blue
const TEXT := Color(0.92, 0.97, 1.0, 1.0)
const TEXT_MUTED := Color(0.6, 0.7, 0.8, 1.0)
