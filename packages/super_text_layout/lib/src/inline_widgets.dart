/// A placeholder to be given to an `AttributedText`, and later replaced
/// within an inline network image.
class InlineNetworkImagePlaceholder {
  const InlineNetworkImagePlaceholder(this.url);

  final String url;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InlineNetworkImagePlaceholder &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;
}

/// A placeholder to be given to an `AttributedText`, and later replaced
/// within an inline asset image.
class InlineAssetImagePlaceholder {
  const InlineAssetImagePlaceholder(this.assetPath);

  final String assetPath;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InlineAssetImagePlaceholder &&
          runtimeType == other.runtimeType &&
          assetPath == other.assetPath;

  @override
  int get hashCode => assetPath.hashCode;
}

class InlineMentionPlaceholder {
  const InlineMentionPlaceholder({
    required this.uid,
    required this.mentionTag,
    this.rawString = '',
  });

  final String uid;
  final String mentionTag;
  final String rawString;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InlineMentionPlaceholder &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          mentionTag == other.mentionTag &&
          rawString == other.rawString;

  @override
  int get hashCode => Object.hash(uid, mentionTag, rawString);
}
