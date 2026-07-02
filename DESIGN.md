---
name: Technical Precision Light
colors:
  surface: '#fbf8fe'
  surface-dim: '#dbd9de'
  surface-bright: '#fbf8fe'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f2f8'
  surface-container: '#efedf2'
  surface-container-high: '#eae7ec'
  surface-container-highest: '#e4e1e7'
  on-surface: '#1b1b1f'
  on-surface-variant: '#45464f'
  inverse-surface: '#303034'
  inverse-on-surface: '#f2f0f5'
  outline: '#767680'
  outline-variant: '#c6c5d1'
  surface-tint: '#505b92'
  primary: '#000110'
  on-primary: '#ffffff'
  primary-container: '#0a174c'
  on-primary-container: '#7681bb'
  inverse-primary: '#b9c3ff'
  secondary: '#003ec6'
  on-secondary: '#ffffff'
  secondary-container: '#0052fe'
  on-secondary-container: '#dfe3ff'
  tertiary: '#060100'
  on-tertiary: '#ffffff'
  tertiary-container: '#390e00'
  on-tertiary-container: '#b97358'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dde1ff'
  primary-fixed-dim: '#b9c3ff'
  on-primary-fixed: '#09164b'
  on-primary-fixed-variant: '#384379'
  secondary-fixed: '#dde1ff'
  secondary-fixed-dim: '#b7c4ff'
  on-secondary-fixed: '#001452'
  on-secondary-fixed-variant: '#0038b6'
  tertiary-fixed: '#ffdbce'
  tertiary-fixed-dim: '#ffb59a'
  on-tertiary-fixed: '#380d00'
  on-tertiary-fixed-variant: '#6f3721'
  background: '#fbf8fe'
  on-background: '#1b1b1f'
  surface-variant: '#e4e1e7'
typography:
  headline-lg:
    fontFamily: Hanken Grotesk
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Hanken Grotesk
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Geist
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Geist
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Geist
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
  mono-data:
    fontFamily: Geist
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 18px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 4px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 32px
  sidebar-width: 260px
---

## Brand & Style
The brand personality is authoritative, technical, and precise. It targets engineers, analysts, and decision-makers in high-stakes deep-tech environments. The shift to a light mode maintains the professional "Mission Control" feel while increasing legibility and reducing cognitive load during long work sessions.

The design style is **Corporate Modern with a Technical Edge**. It utilizes high-contrast structural anchors (Navy) against a clinical white workspace. The aesthetic is defined by sharp information density, systematic hierarchy, and a utilitarian approach to data visualization.

## Colors
The palette is anchored by the **Primary Navy (#0A174C)**, used exclusively for high-level structural components like the Sidebar and Global Navigation to provide a strong sense of containment.

The **Primary Surface (#FFFFFF)** serves as the canvas for all data modules. Secondary accents in **Action Blue (#0052FF)** highlight interactive states and primary call-to-actions. Neutrals are tiered from deep Slate for text to light Greys for borders and secondary containers, ensuring a crisp, high-contrast interface that remains easy on the eyes.

## Typography
Typography is split into two functional roles. **Hanken Grotesk** is used for headlines to provide a sharp, contemporary professional feel. **Geist** is used for all body text, labels, and data points; its technical, slightly monospaced character ensures that alphanumeric strings (IDs, coordinates, timestamps) are perfectly legible.

For mobile viewports, `headline-lg` should scale down to 24px to ensure headers do not wrap excessively. Use `label-md` for metadata and category headers to maintain a disciplined information hierarchy.

## Layout & Spacing
The design system employs a **Fixed Grid** model for large screens, centered on a 12-column layout. The Sidebar is a fixed width of 260px, utilizing the Primary Navy background to separate navigation from the workspace.

Spacing follows a strict 4px base unit. Internal card padding is set to 24px (6 units) to allow complex data sets "room to breathe" against the white background. On mobile, the layout collapses to a single column with 16px side margins, while the top navigation bar persists.

## Elevation & Depth
In this light mode system, depth is achieved through **Tonal Layering** and **Low-Contrast Outlines** rather than heavy shadows. 

1.  **Level 0 (Base):** #FFFFFF (Pure White)
2.  **Level 1 (Cards/Containers):** #FFFFFF with a 1px border of #E2E8F0.
3.  **Level 2 (Dropdowns/Modals):** #FFFFFF with a subtle, highly diffused shadow (0px 8px 24px rgba(0,0,0,0.08)) and a 1px border.

The Sidebar and Top Nav use the high-contrast Navy (#0A174C) to sit "above" the white workspace visually without needing shadows.

## Shapes
A **Soft (0.25rem)** roundedness is applied to buttons, input fields, and small UI widgets to maintain a modern feel without appearing overly "bubbly." Larger containers and data cards use **rounded-lg (0.5rem)** to subtly soften the technical density of the dashboard. This balance between sharp geometry and slight corner radii reinforces the "professional tool" identity.

## Components
- **Buttons:** Primary buttons use #0052FF with white text. Secondary buttons use a white fill with a #E2E8F0 border and #0F172A text.
- **Sidebar Items:** Background is transparent; Active state uses a subtle navy tint (#16245C) with a left-aligned 4px "Action Blue" indicator.
- **Input Fields:** Use #FFFFFF background with #E2E8F0 borders. Focus state shifts border to #0052FF with a 2px outer glow.
- **Data Tables:** Header rows use a light tint (#F8FAFC) with uppercase `label-md` typography. Rows use a 1px bottom border of #F1F5F9.
- **Chips/Status:** Use low-saturation backgrounds (e.g., light green for "Active") with high-saturation text to ensure accessibility on the white background.
- **Cards:** White surface, 1px #E2E8F0 border, no shadow for standard dashboard modules.