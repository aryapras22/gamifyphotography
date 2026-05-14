# SPR-010 — Replace Static Placeholder with Real Example Photos (Swipeable Gallery)

**Repo:** https://github.com/aryapras22/gamifyphotography
**Base branch:** `main`
**Working branch:** `feat/example-photo-gallery`

```bash
git checkout main && git pull origin main
git checkout -b feat/example-photo-gallery
```

Run `flutter analyze` after every task. Zero new warnings before moving on.
Do NOT modify: `main.dart`, any model file, any `.freezed.dart` / `.g.dart`, `pubspec.yaml` assets section (already declared).

---

## Context & Analysis

### Current state (branch: main)
- `_buildTheoryPage()` in `module_detail_view.dart` renders a hardcoded `_SamplePhotoPainter` (a custom paint drawing a gold/brown grid pattern) as the example image.
- Page structure: **2 pages** — Page 0 = Theory, Page 1 = Visual Guide (SVG). Progress dots hardcoded to `List.generate(2, ...)`.
- `_SamplePhotoPainter` is defined at the bottom of the file and is intentional decorative art for the Rule of Thirds grid.
- There is **no connection** between the module's level (`module.order`) and any real example photo.

### Target state
- The `_SamplePhotoPainter` placeholder on Page 0 (Theory page) is **replaced** with a horizontally swipeable `PageView` of real asset images.
- Images come from `assets/images/examples/` using the naming convention `LEVEL {N}-({i}).jpg`.
- The outer PageView (2 pages: Theory + Visual Guide) is unchanged.
- `module.order` maps to the level number (e.g., `module.order == 1` → Level 1 images).

### Asset inventory (complete, verified from repo)
| Level | Count | Files |
|-------|-------|-------|
| 1 | 4 | LEVEL 1-(1).jpg … LEVEL 1-(4).jpg |
| 2 | 4 | LEVEL 2-(1).jpg … LEVEL 2-(4).jpg |
| 3 | 4 | LEVEL 3-(1).jpg … LEVEL 3-(4).jpg |
| 4 | 2 | LEVEL 4-(1).jpg, LEVEL 4-(2).jpg |
| 5 | 4 | LEVEL 5-(1).jpg … LEVEL 5-(4).jpg |
| 6 | 3 | LEVEL 6-(1).jpg … LEVEL 6-(3).jpg |
| 7 | 4 | LEVEL 7-(1).jpg … LEVEL 7-(4).jpg |
| 8 | 3 | LEVEL 8-(1).jpg … LEVEL 8-(3).jpg |
| 9 | 4 | LEVEL 9-(1).jpg … LEVEL 9-(4).jpg |
| 10 | 0 | ⚠️ No files — use fallback (Level 1 images) |
| 11 | 4 | LEVEL 11-(1).jpg … LEVEL 11-(4).jpg |
| 12 | 3 | LEVEL 12-(1).jpg … LEVEL 12-(3).jpg |
| 13 | 3 | LEVEL 13-(1).jpg … LEVEL 13-(3).jpg |

> ⚠️ Level 10 has NO example images in the repo. Use Level 1 images as fallback and leave a `// TODO: add LEVEL 10 example photos` comment.

---

## TASK 1 — Add `_ExamplePhotoGallery` widget to `module_detail_view.dart`

### 1a. Add a static helper method `_getExamplePhotoPaths` to `_ModuleDetailViewState`

This method takes `module.order` (int) and returns a `List<String>` of asset paths.

Add this method inside `_ModuleDetailViewState`, after `_getVisualGuideAsset`:

```dart
/// Returns the list of asset paths for example photos for the given module level.
/// File naming convention: assets/images/examples/LEVEL {N}-({i}).jpg
static List<String> _getExamplePhotoPaths(int level) {
  const counts = <int, int>{
    1: 4, 2: 4, 3: 4, 4: 2,
    5: 4, 6: 3, 7: 4, 8: 3,
    9: 4,
    // 10: missing — fallback below
    11: 4, 12: 3, 13: 3,
  };

  final count = counts[level];
  if (count == null || count == 0) {
    // TODO: add LEVEL 10 example photos to assets/images/examples/
    // Fallback to Level 1
    return List.generate(
      4,
      (i) => 'assets/images/examples/LEVEL 1-(${i + 1}).jpg',
    );
  }
  return List.generate(
    count,
    (i) => 'assets/images/examples/LEVEL $level-(${i + 1}).jpg',
  );
}
```

### 1b. Add `_ExamplePhotoGallery` as a private widget at the bottom of `module_detail_view.dart`

Place it just before `class _SamplePhotoPainter`. Do NOT delete `_SamplePhotoPainter` — it is still used in the visual guide page.

```dart
/// A horizontally swipeable gallery of real example photos for a module level.
/// Photos come from assets/images/examples/LEVEL {N}-({i}).jpg
class _ExamplePhotoGallery extends StatefulWidget {
  final List<String> photoPaths;

  const _ExamplePhotoGallery({required this.photoPaths});

  @override
  State<_ExamplePhotoGallery> createState() => _ExamplePhotoGalleryState();
}

class _ExamplePhotoGalleryState extends State<_ExamplePhotoGallery> {
  final PageController _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.photoPaths.length;
    return Column(
      children: [
        // Label
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Contoh Foto:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.secondaryText,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Photo carousel
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _controller,
            itemCount: total,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  widget.photoPaths[index],
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGray,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_rounded,
                        size: 48,
                        color: AppColors.disabled,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Dot indicators (only show if more than 1 photo)
        if (total > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              total,
              (i) => GestureDetector(
                onTap: () => _controller.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _current == i ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _current == i
                        ? AppColors.brandBlue
                        : AppColors.disabled,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_current + 1} / $total',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ],
    );
  }
}
```

---

## TASK 2 — Replace `_SamplePhotoPainter` usage in `_buildTheoryPage`

In `_buildTheoryPage(module)`, find this block:

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(20),
  child: SizedBox(
    width: double.infinity,
    height: 220,
    child: CustomPaint(painter: _SamplePhotoPainter()),
  ),
),
```

Replace it entirely with:

```dart
_ExamplePhotoGallery(
  photoPaths: _getExamplePhotoPaths(module.order as int),
),
```

> The `_SamplePhotoPainter` class itself is NOT deleted — it remains at the bottom of the file. It is no longer called in `_buildTheoryPage` but it should be kept for potential future use or the visual guide page.

---

## TASK 3 — Verify `pubspec.yaml` includes the examples directory

Open `pubspec.yaml` and confirm the assets section already includes:

```yaml
  - assets/images/examples/
```

If it is declared as a wildcard like `assets/images/` that covers subdirectories, that is also fine. If neither is present, add:

```yaml
    - assets/images/examples/
```

under the `flutter: > assets:` section. Do NOT add any other lines.

---

## Files Changed

| File | Action |
|---|---|
| `lib/views/mission/module_detail_view.dart` | MODIFY — add `_getExamplePhotoPaths`, add `_ExamplePhotoGallery` widget, replace `_SamplePhotoPainter` call in `_buildTheoryPage` |
| `pubspec.yaml` | VERIFY only — add `assets/images/examples/` if missing |

**Do NOT modify:** `main.dart`, any model, any `.freezed.dart` / `.g.dart`, `app_colors.dart`, `_SamplePhotoPainter` class definition.

---

## Expected Behavior After This Sprint

1. On the Theory page (Page 0) of any module, the static brown grid is replaced by real example photos.
2. User can swipe left/right between example photos — dots and counter show current position.
3. Level 10 modules fall back to Level 1 photos (with TODO comment in code).
4. The Visual Guide page (Page 1, with SVG + phone mockup) is completely unchanged.
5. The outer 2-page navigation (Theory → Visual Guide) and its progress dots are completely unchanged.

---

## PR

**Title:** `feat(SPR-010): replace static placeholder with real example photo gallery`
**Base:** `main`
**Body:**
- Replaced `_SamplePhotoPainter` golden grid with a swipeable `PageView` gallery in `_buildTheoryPage`.
- Added `_ExamplePhotoGallery` widget with dot indicators and photo counter.
- Added `_getExamplePhotoPaths(int level)` lookup covering Levels 1–13 (Level 10 falls back to Level 1 — no assets available).
- `pubspec.yaml` assets section verified/updated.
