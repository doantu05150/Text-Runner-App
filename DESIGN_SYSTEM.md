# Text Runner - Design System

## Colors

Defined in `lib/theme/app_theme.dart` → `AppColors`

| Token          | Value                          | Usage                        |
| -------------- | ------------------------------ | ---------------------------- |
| `bgMain`       | `#0B0F14`                      | Scaffold / screen background |
| `bgCard`       | `#121821`                      | Cards, inputs, dialogs       |
| `textPrimary`  | `rgba(255, 255, 255, 0.9)`    | Headings, primary text       |
| `textSecondary`| `rgba(255, 255, 255, 0.6)`    | Labels, secondary text       |
| `textMuted`    | `rgba(255, 255, 255, 0.4)`    | Hints, disabled text         |
| `primary`      | `#DFFF4F` (neon yellow-green) | Buttons, active states, glow |
| `primarySoft`  | `rgba(223, 255, 79, 0.15)`   | Soft backgrounds, badges     |
| `border`       | `rgba(255, 255, 255, 0.1)`   | Card/input borders           |

## Typography

Uses default Flutter font (Roboto). Hierarchy is controlled via opacity, not different colors.

| Style            | Size | Weight | Color         |
| ---------------- | ---- | ------ | ------------- |
| `headlineLarge`  | 28   | w600   | textPrimary   |
| `headlineMedium` | 22   | w600   | textPrimary   |
| `titleLarge`     | 18   | w600   | textPrimary   |
| `titleMedium`    | 16   | w500   | textPrimary   |
| `bodyLarge`      | 16   | w400   | textPrimary   |
| `bodyMedium`     | 14   | w400   | textSecondary |
| `labelLarge`     | 16   | w600   | textPrimary   |

## Spacing

8px grid system throughout.

| Context     | Value   |
| ----------- | ------- |
| Screen edge | 16–20px |
| Sections    | 20–24px |
| Elements    | 8–16px  |

Use `SizedBox` for spacing between elements.

## Border Radius

| Component       | Radius |
| --------------- | ------ |
| Cards / Dialogs | 16–20  |
| Buttons / Chips | 10–12  |
| Inputs          | 12     |
| Color swatches  | 8–12   |

## Reusable Components

### AppCard (`lib/widgets/app_card.dart`)

Themed container for list items and content sections.

```dart
AppCard(
  child: Text('Content'),
  highlighted: false,  // adds primary border + glow when true
  onTap: () {},
  padding: EdgeInsets.all(16),
)
```

- Background: `bgCard`
- Border: `border` (default) or `primary` (highlighted)
- Radius: 16
- Glow when highlighted: `primary.withOpacity(0.15)`, blur 12

### AppButton (`lib/widgets/app_button.dart`)

Primary and outlined button variants.

```dart
// Primary (filled)
AppButton(
  onPressed: () {},
  icon: Icons.play_arrow_rounded,
  child: Text('Chạy chữ'),
)

// Outlined
AppButton(
  isPrimary: false,
  onPressed: () {},
  child: Text('Hủy'),
)
```

**Primary**: `primary` background, black text, 12 radius
**Outlined**: transparent background, `border` side, `textPrimary` text

### AppIconButton (`lib/widgets/app_button.dart`)

Small icon button with optional active state.

```dart
AppIconButton(
  icon: Icons.save_rounded,
  onPressed: () {},
  tooltip: 'Save',
  isActive: false,  // active = primarySoft bg + primary border
)
```

- Default: transparent bg, `border` side, `textSecondary` icon
- Active: `primarySoft` bg, `primary` border + icon color
- Radius: 10
- Padding: 10

## Interactive States

| State    | Style                                                    |
| -------- | -------------------------------------------------------- |
| Default  | Transparent bg, `border` side                            |
| Active   | `primarySoft` bg, `primary` border, subtle glow          |
| Selected | `primary` bg, black text/icon                            |
| Disabled | Reduced opacity                                          |
| Focused  | `primary` border (1.5px width) on inputs                 |

## Glow Effect

Only used on active/selected elements.

```dart
BoxShadow(
  color: AppColors.primary.withOpacity(0.15–0.35),
  blurRadius: 12,
)
```

## Dialog Pattern

```dart
AlertDialog(
  backgroundColor: AppColors.bgCard,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
    side: BorderSide(color: AppColors.border),
  ),
)
```

- Title row: icon in `primarySoft` container + label
- Form rows: icon + label (80px) + input widget
- Dropdowns: `bgMain` fill, `border` side, 12 radius
- Color swatches: 28x28 preview + hex code + colorize icon
- Actions: `AppButton` (outlined for cancel, primary for confirm)

## SnackBar Pattern

Floating style with `bgCard` background and `border` side. Success messages include a `primary`-colored check icon.

## File Structure

```
lib/
  theme/
    app_theme.dart      ← AppColors + AppTheme.darkTheme
  widgets/
    app_card.dart        ← AppCard
    app_button.dart      ← AppButton, AppIconButton
    text_input_widget.dart
    action_bar_widget.dart
  screens/
    home_screen.dart
    run_screen.dart
    saved_screen.dart
  models/
    saved_item.dart
  main.dart
```
