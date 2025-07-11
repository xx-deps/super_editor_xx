## [0.3.2] - June, 2024
 * Fix crash when adding attributions that overlap others - you can now control whether a new attribution overwrites conflicting spans when you add it.

## [0.3.1] - June, 2024
 * Added query `getAllAttributionsThroughout()` to `AttributedText`.
 * Added `copy()` to `AttributedText()`.
 * Added ability to insert an attribution that splits an existing attribution.

## [0.3.0] - Feb, 2024
 * [BREAKING] - `AttributedText` and `SpanRange` constructors now use positional parameters istead of named parameters.
 * [FIX] - `AttributedText` now supports differents links for different URLs in the same text blob - previously all links were sent to the same URL withing a single `AttributedText`.
 * [FIX] - `collapseSpans` now reports the correct ending index, which was previously off by one.
 * `AttributedText` now has a substring method and length property to avoid needing to access the inner `text` string.
 * `AttributionSpan` now has a `range` property to get a non-directional span of text.
 * `AttributedText` can visit and report attribution spans instead of just visiting individual attribution markers.
 * Added query methods:
   * `getAttributionSpans()`
   * `getAttributionSpansByFilter()`
 * `AttributedText` now allows you to `addAttribution()` without auto-merging with preceding and following attributions (#1198)

## [0.2.2] - May, 2023
Upgrade Dart constraints to explicitly include Dart 3. Make `markers` public on `AttributedSpans`.

## [0.2.1] - January, 2023
Add `getAttributedRange()`, which returns a range that includes a given set of attributions.

## [0.2.0] - July, 2022

BREAKING - Attributions in an `AttributedText` are now visited by a `AttributionVisitor` instead of a callback, and the visitor receives span markers in a more useful way.

## [0.1.3] - June 3, 2022

Changed the `meta` dependency to a version that's compatible with Flutter

## [0.1.2] - June 2, 2022 (DEPRECATED)

Fixed a couple bugs related to merging attribution spans when adding new spans.

## [0.1.1] - April 4, 2022

Downgraded `collection` from `1.16.0` to `1.15.0` because `flutter_test` is pinned to `1.15.0`

## [0.1.0] - April 2, 2022

The first release of attributed_text, which was extracted from super_editor.