import "dart:convert";
import "dart:async";

import "package:path/path.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/services.dart" show rootBundle;

class StorageManager {
  static const String _jsonPath = 'resources/json/';
  static const String _cardsPath = 'resources/cards/';

  static final StorageManager _instance = StorageManager._internal();

  Map<String, Image> cards = {};
  Map<String, dynamic> versions = {};

  late Future<void> loading;

  factory StorageManager() {
    return _instance;
  }

  StorageManager._internal() {
    loading = Future(() async {
      final loadingCards = _loadCards();
      final loadingVersions = _loadVersions();
      await loadingVersions;
      await loadingCards;
    });
  }

  Future<void> _loadVersions() async {
    versions = json.decode(await rootBundle.loadString('${_jsonPath}versions.json'));
  }

  Future<void> _loadCards() async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final imagePaths = json.decode(manifestJson).keys.where((String key) => key.startsWith(_cardsPath)).toList();
    for (final imagePath in imagePaths) {
      cards[basename(imagePath)] = Image(image: AssetImage(imagePath));
    }
  }
}
