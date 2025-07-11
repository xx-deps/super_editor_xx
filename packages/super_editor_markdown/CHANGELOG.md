## [0.1.5] - May, 2023
* Added explicit support for Dart 3
* Bumped `super_editor` dependency to `v0.2.5`

## [0.1.4+2] - May, 2023
* Added support for paragraph "justify" alignment in Markdown serialization.

## [0.1.4+1] - Nov, 2022
* Added support for custom Markdown block syntax.
* Fix: parsing empty markdown into a document.
* Fix: serialization of paragraph alignment, text strikethrough and underline.

## [0.1.4] - Nov, 2022
* De-listed because we forgot to upgrade the super_editor dependency

## [0.1.3] - July, 2022
* Updated `AttributedText` serialization to use new `AttributionVisitor` API.

## [0.1.2] - ~July, 2022~ (Removed from pub)
* Updated `AttributedText` serialization to use new `AttributionVisitor` API.

## [0.1.1] - June, 2022
* BREAKING: changed super_editor_markdown to NOT append newlines after every line it serializes to avoid extra newlines at the end of a serialized document.