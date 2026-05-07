# LemonsPay Design System: "Midnight Kinetic"

## Overview
The **Midnight Kinetic** design system embodies a premium, high-tech financial aesthetic. It combines the deep, trustworthy tones of midnight blue with energetic neon accents, all brought together through modern glassmorphic UI elements and fluid micro-animations.

## 1. Color Palette

### Base & Surface Colors
- **Background Dark (`bgDark`)**: `#0E131D`
  - The foundation of the app. A very deep, professional midnight blue that reduces eye strain and provides a premium canvas.
- **Surface Dark (`surfaceDark`)**: `#161B26`
  - Used for elevated but non-glass elements. Slightly lighter than the background.
- **Glass Fill (`glassFill`)**: `rgba(255, 255, 255, 0.03)`
  - Used as the background for cards, inputs, and floating elements to give a frosted glass effect.
- **Glass Border (`glassBorder`)**: `rgba(255, 255, 255, 0.08)`
  - A subtle 1px stroke used to define the edges of glassmorphic elements.

### Brand Accents
- **Primary / Cyan (`primary`)**: `#00F5FF`
  - The energetic core color. Used for the logo, text accents, and interactive highlights. Represents digital fluidity and modern wealth.
- **Accent / Electric Indigo (`accent`)**: `#6366F1`
  - Used for primary call-to-action (CTA) buttons and active states. Provides a strong, trustworthy contrast to the vibrant cyan.

### Semantic Colors
- **Success (`success`)**: `#10B981` (Emerald Green)
- **Error (`error`)**: `#EF4444` (Red)

## 2. Typography
- **Headings**: Clean, bold, and modern (e.g., standard Flutter TextThemes with `FontWeight.bold`).
- **Body**: Highly legible, prioritizing readability for financial data.

## 3. UI Components & Shapes

### Glassmorphism
The signature look of Midnight Kinetic.
- **Backdrop Blur**: `sigmaX: 16`, `sigmaY: 16`
- **Border Radius**: 
  - Cards / Containers: `32px`
  - Inputs / Buttons (Pill Shape): `50px` or `9999px`

### Buttons
- **Primary Buttons**: 
  - Shape: Pill (Fully rounded).
  - Background: Electric Indigo (`#6366F1`).
  - Text: White, bold.
  - Elevation: Soft colored shadow matching the button color to give a subtle glow.

### Text Fields
- **Shape**: Pill (Fully rounded).
- **Background**: Translucent glass fill.
- **Border**: Subtle glass border. On focus, changes to the Primary Cyan color.

## 4. Animation & Motion ("Kinetic")
Animations are crucial to the premium feel. They should be snappy yet smooth.
- **Logo Animation**: A continuous gentle shimmer, with a staggered fade/scale upon entry.
- **Page Transitions**: Elements should slide upwards (slideY) and fade in smoothly (duration ~600-800ms) with an `easeOut` curve.
- **Micro-interactions**: Use `flutter_animate` to add tactile feedback (e.g., scaling down slightly on button press).

## 5. Assets
- **Logo**: `assets/images/logo_cyan.png` - A high-fidelity, glossy Cyan Lemon slice with subtle yellow highlights, designed to stand out against the midnight background.
