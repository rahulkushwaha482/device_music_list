class UrlParser {
  static bool validUrl(String path) {
    try {
      return (Uri.parse(path)).isAbsolute;
    } catch (e) {
      return false;
    }
  }
}
