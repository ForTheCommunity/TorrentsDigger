import 'package:torrents_digger/src/rust/api/app.dart';

getSourcesAndCategories() {
  var sourcesAndCategoriesMap = getAllAvailableSourcesCategories();
  return sourcesAndCategoriesMap;
}
