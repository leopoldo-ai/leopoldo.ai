# Brand Kit Presets

Two ready-to-use presets. Copy the YAML below, save as `brand-kit.yaml`, replace `{{COMPANY_NAME}}`.

---

## Preset 1: Corporate Finance

Conservative, institutional style. Navy + teal palette. Inter for both heading and body (clean, professional). Major third scale (1.25).

Best for: financial services, law firms, consulting, insurance, private banking, family offices.

```yaml
version: "1.0"

brand:
  name: "{{COMPANY_NAME}}"
  tagline: ""
  logo:
    primary: "./assets/logo.svg"

colors:
  primary: "#1B3A5C"
  secondary: "#2E86AB"
  accent: "#F18F01"
  neutral:
    50: "#FAFAFA"
    100: "#F5F5F5"
    200: "#E5E5E5"
    300: "#D4D4D4"
    400: "#A3A3A3"
    500: "#737373"
    600: "#525252"
    700: "#404040"
    800: "#262626"
    900: "#171717"
  semantic:
    success: "#16A34A"
    warning: "#EAB308"
    error: "#DC2626"
    info: "#2563EB"

typography:
  heading:
    family: "Inter"
    weights: [600, 700]
  body:
    family: "Inter"
    weights: [400, 500]
  mono:
    family: "JetBrains Mono"
    weights: [400, 500]
  scale:
    base: 16
    ratio: 1.25

spacing:
  unit: 4
  scale: [0, 1, 2, 3, 4, 5, 6, 8, 10, 12, 16, 20, 24]

document:
  margins:
    top: "2.5cm"
    bottom: "2.5cm"
    left: "2.5cm"
    right: "2.5cm"
  header:
    logo_position: "left"
    show_tagline: false
  footer:
    show_page_numbers: true
    show_company_name: true
```

---

## Preset 2: Tech Startup

Modern, energetic style. Indigo + cyan palette. Plus Jakarta Sans for headings (distinctive), Inter for body (readable). Perfect fourth scale (1.333).

Best for: SaaS, fintech, healthtech, AI/ML companies, digital agencies, startups.

```yaml
version: "1.0"

brand:
  name: "{{COMPANY_NAME}}"
  tagline: ""
  logo:
    primary: "./assets/logo.svg"

colors:
  primary: "#6366F1"
  secondary: "#06B6D4"
  accent: "#F59E0B"
  neutral:
    50: "#F8FAFC"
    100: "#F1F5F9"
    200: "#E2E8F0"
    300: "#CBD5E1"
    400: "#94A3B8"
    500: "#64748B"
    600: "#475569"
    700: "#334155"
    800: "#1E293B"
    900: "#0F172A"
  semantic:
    success: "#22C55E"
    warning: "#F59E0B"
    error: "#EF4444"
    info: "#3B82F6"

typography:
  heading:
    family: "Plus Jakarta Sans"
    weights: [600, 700, 800]
  body:
    family: "Inter"
    weights: [400, 500]
  mono:
    family: "JetBrains Mono"
    weights: [400, 500]
  scale:
    base: 16
    ratio: 1.333

spacing:
  unit: 4
  scale: [0, 1, 2, 3, 4, 5, 6, 8, 10, 12, 16, 20, 24]

document:
  margins:
    top: "2.5cm"
    bottom: "2.5cm"
    left: "2.5cm"
    right: "2.5cm"
  header:
    logo_position: "left"
    show_tagline: false
  footer:
    show_page_numbers: true
    show_company_name: true
```
