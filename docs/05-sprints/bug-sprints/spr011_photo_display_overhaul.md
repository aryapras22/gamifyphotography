# SPR-011 — Full-Fidelity Photo Display Overhaul
## No Crop · No Rounded Corners · True Aspect Ratio Everywhere

**Repo:** https://github.com/aryapras22/gamifyphotography
**Base branch:** `main`
**Working branch:** `feat/full-fidelity-photo-display`

```bash
git checkout main && git pull origin main
git checkout -b feat/full-fidelity-photo-display
```

Run `flutter analyze` after every task. Zero new warnings before committing.

**Scope:** 3 files only.
| # | File | What changes |
|---|---|---|
| A | `lib/views/mission/module_detail_view.dart` | Example photo gallery |
| B | `lib/views/mission/challenge_view.dart` | User-submitted photo preview |
| C | `lib/views/mission/submission_status_view.dart` | Submission result photo |

**Do NOT modify:** `main.dart`, any model, any `ViewModel`, any `.freezed.dart` / `.g.dart`, `app_colors.dart`, `_SamplePhotoPainter` class definition.

---

## Design Mandate — Read This Before Writing Any Code

This application teaches photography composition. The two primary image categories are:

| Category | Source | Natural aspect ratio | Display context |
|---|---|---|---|
| **Reference examples** | Local asset (`assets/images/examples/`) | Landscape **16:9** | Theory page — "Contoh Foto" gallery |
| **User submissions** | Network URL / local file path | Portrait **9:16** | Challenge preview + Submission status page |

### Absolute rules (non-negotiable)

1. **Zero cropping.** `BoxFit.cover` is BANNED for all photo images in this sprint. Every pixel the photographer intended to capture must be visible.
2. **Zero rounded corners on photos.** Remove every `ClipRRect`, `borderRadius`, and `clipBehavior` wrapping a photo. Cards and containers may keep their own border radius — only the photo `Image` widget itself must be edge-to-edge sharp.
3. **Aspect ratio is enforced by the image, not by a hardcoded height.** Use `AspectRatio` widget or `BoxFit.contain` inside a constrained container — never `height: 220` or `height: 300` with `fit: BoxFit.cover`.
4. **No whitespace padding around photos.** Photos must reach the full width of the content column (minus the parent scroll padding — typically 24px each side).

### UX/UX Research Findings — Rationale Embedded as Code Comments

The agent MUST add the following comment block above every image rendering section it modifies:

```dart
// ── DISPLAY DESIGN NOTE (SPR-011) ────────────────────────────────────────
// Photography training requires users to evaluate the full, unaltered frame.
// Cropping destroys composition evidence (rule of thirds intersections,
// leading lines reaching the edge, negative space balance, DOF gradient).
// We use BoxFit.contain so the image fills the constrained width while
// preserving its native aspect ratio — zero pixels hidden, zero distortion.
// Rounded corners are removed because they visually suggest the frame edge
// is a design element rather than the actual photographic boundary.
// Reference: Nielsen Norman Group — "Images in UX" (2024)
//            "Never crop an instructional image to fit a UI container."
// ─────────────────────────────────────────────────────────────────────────
```

---

## TASK A — `module_detail_view.dart` · Example Photo Gallery

### A1. Aspect ratio rule for reference examples

Reference photos in `assets/images/examples/` are landscape shots, natural ratio **16:9**.

Each photo in `_ExamplePhotoGallery` MUST render at a **fixed width = full column width** with height derived from `16:9` via `AspectRatio`. No hardcoded height. No `ClipRRect`.

### A2. Replace `_ExamplePhotoGallery` widget entirely

Find the `_ExamplePhotoGallery` StatefulWidget (added in SPR-010) and **replace its full implementation** with the following:

```dart
/// Swipeable gallery of real reference example photos for a module level.
/// Renders every photo at its native 16:9 landscape ratio — zero crop, zero clipping.
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contoh Foto:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 10),

        // ── DISPLAY DESIGN NOTE (SPR-011) ─────────────────────────────────
        // Photography training requires users to evaluate the full, unaltered
        // frame. Cropping destroys composition evidence. We use AspectRatio(16:9)
        // so the image fills the column width while revealing every pixel.
        // Rounded corners removed — the frame edge IS the photographic boundary.
        // Reference: Nielsen Norman Group — "Images in UX" (2024)
        // ─────────────────────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: PageView.builder(
              controller: _controller,
              itemCount: total,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (context, index) {
                return Image.asset(
                  widget.photoPaths[index],
                  fit: BoxFit.contain,  // NEVER use cover — see note above
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.backgroundGray,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_rounded,
                        size: 48,
                        color: AppColors.disabled,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

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
          Center(
            child: Text(
              '${_current + 1} / $total',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
```

---

## TASK B — `challenge_view.dart` · User Submission Preview

### B1. Identify the target block

In `_ChallengeViewState.build()`, find the block that begins with:

```dart
if (hasPhoto)
  ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: _isNetworkUrl(challenge.uploadedPhotoUrl)
        ? Image.network(
            challenge.uploadedPhotoUrl!,
            height: 300,
            width: double.infinity,
            fit: BoxFit.cover,
```

### B2. Replace the entire `if (hasPhoto)` rendering block

User photos are taken with a phone camera in **portrait orientation — natural ratio 9:16**.

Replace the block entirely with:

```dart
if (hasPhoto)
  // ── DISPLAY DESIGN NOTE (SPR-011) ─────────────────────────────────────
  // User submissions are portrait photos (9:16). We display them at their
  // native ratio so the student and admin can assess the full composition:
  // horizon placement, subject framing, depth gradient to the edges.
  // BoxFit.cover and fixed heights are banned — they silently hide evidence.
  // ClipRRect removed — rounded corners misrepresent the photographic frame.
  // ─────────────────────────────────────────────────────────────────────
  SizedBox(
    width: double.infinity,
    child: AspectRatio(
      aspectRatio: 9 / 16,
      child: _isNetworkUrl(challenge.uploadedPhotoUrl)
          ? Image.network(
              challenge.uploadedPhotoUrl!,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: AppColors.backgroundGray,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                      color: AppColors.brandBlue,
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) =>
                  const _PhotoErrorPlaceholder(),
            )
          : Image.file(
              File(challenge.uploadedPhotoUrl!),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const _PhotoErrorPlaceholder(),
            ),
    ),
  )
```

### B3. Update `_PhotoErrorPlaceholder`

Remove `borderRadius` from its container and remove the hardcoded `height` parameter. Replace the entire class:

```dart
class _PhotoErrorPlaceholder extends StatelessWidget {
  const _PhotoErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.backgroundGray,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_rounded,
              size: 64, color: AppColors.disabled),
          SizedBox(height: 12),
          Text(
            'Gagal memuat foto',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## TASK C — `submission_status_view.dart` · Result Photo

### C1. Identify the target block in `_buildStatusCard`

Find:

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(20),
  child: Image.network(
    submission.photoUrl,
    height: 220,
    fit: BoxFit.cover,
    errorBuilder: ...
  ),
),
```

### C2. Replace with full-fidelity portrait display

```dart
// ── DISPLAY DESIGN NOTE (SPR-011) ───────────────────────────────────────
// The submission result page is the primary moment where both the student
// and admin evaluate the submitted photograph against the mission criteria.
// Displaying a cropped thumbnail destroys the learning feedback loop.
// Full 9:16 portrait ratio is enforced — zero crop, zero rounded clipping.
// ─────────────────────────────────────────────────────────────────────────
SizedBox(
  width: double.infinity,
  child: AspectRatio(
    aspectRatio: 9 / 16,
    child: Image.network(
      submission.photoUrl,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.backgroundGray,
          child: Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
              color: AppColors.brandBlue,
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => AspectRatio(
        aspectRatio: 9 / 16,
        child: Container(
          color: AppColors.backgroundGray,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image_rounded,
                  size: 56, color: AppColors.disabled),
              SizedBox(height: 12),
              Text(
                'Gagal memuat foto',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
),
```

---

## Verification Checklist (Agent must pass all before opening PR)

Run `flutter analyze` — zero new issues.

Manual visual verification (run on device or emulator):

- [ ] **Theory page (any level):** Example photo is full-width, no clipping at top/bottom/sides, ratio is clearly landscape, no rounded corners visible at image edges
- [ ] **Challenge page (after taking photo):** Submitted photo is portrait, fills full column width, entire image visible including sky/floor edges, no rounded corners
- [ ] **Submission status page (pending/approved/rejected):** Photo renders portrait at full column width, complete image visible, no rounded corners
- [ ] **Error state:** Broken image placeholder respects the same AspectRatio container (no layout collapse)
- [ ] **Single example photo (Level 4 — 2 photos):** No dots rendered below, image still full-fidelity
- [ ] No `fit: BoxFit.cover` anywhere in the 3 modified files (search and confirm)
- [ ] No `ClipRRect` wrapping any `Image` widget in the 3 modified files

---

## Files Changed

| File | Key removals | Key additions |
|---|---|---|
| `module_detail_view.dart` | `ClipRRect(r=20)`, `height: 220`, `BoxFit.cover` on gallery | `AspectRatio(16/9)`, `BoxFit.contain`, design note comment |
| `challenge_view.dart` | `ClipRRect(r=24)`, `height: 300`, `BoxFit.cover` on user photo | `AspectRatio(9/16)`, `BoxFit.contain`, design note comment |
| `submission_status_view.dart` | `ClipRRect(r=20)`, `height: 220`, `BoxFit.cover` | `AspectRatio(9/16)`, `BoxFit.contain`, design note comment |

---

## PR

**Title:** `feat(SPR-011): full-fidelity photo display — no crop, no rounded borders, true aspect ratio`

**Body:**
```
## Summary
Overhauled photo rendering across all 3 mission views to eliminate cropping
and enforce true native aspect ratios for both reference examples (16:9)
and user submissions (9:16).

## Changes
- module_detail_view.dart: AspectRatio(16/9) + BoxFit.contain in ExamplePhotoGallery
- challenge_view.dart: AspectRatio(9/16) + BoxFit.contain for user photo preview; PhotoErrorPlaceholder cleaned up
- submission_status_view.dart: AspectRatio(9/16) + BoxFit.contain for submission result photo

## Rationale
Photography training depends on full, unaltered image presentation.
BoxFit.cover silently hides composition evidence (edges, negative space, horizon).
Rounded corners misrepresent the photographic frame boundary.
See design note comments in each modified section for full research citation.

Closes SPR-011
```
