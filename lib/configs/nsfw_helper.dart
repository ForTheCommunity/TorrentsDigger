class NsfwHelper {
  /// Known sources that are purely NSFW
  static const Set<String> nsfwSources = {
    'Nyaa Sukebei',
  };

  /// Returns true if the source is an adult/NSFW source
  static bool isNsfwSource(String sourceName) {
    return nsfwSources.contains(sourceName.trim());
  }

  /// Returns true if the category is an adult/NSFW category
  static bool isNsfwCategory(String categoryName) {
    final lower = categoryName.toLowerCase().trim();
    return lower.contains('xxx') ||
        lower.contains('porn') ||
        lower.contains('hentai') ||
        lower.contains('adult');
  }
}
