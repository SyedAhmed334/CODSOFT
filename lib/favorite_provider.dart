import 'dart:convert';
import 'package:codsoft_quote_app/qoutes_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProvider extends ChangeNotifier {
  List<String> _favoriteQuotes = [];

  List<String> get favoriteQuotes => _favoriteQuotes;

  Future<void> _updateFavoriteQuotesInPrefs(List<String> quotes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteQuotes', quotes);
  }

  Future<void> _loadFavoriteQuotesFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _favoriteQuotes = prefs.getStringList('favoriteQuotes') ?? [];
    notifyListeners();
  }

  Future<void> addToFavorites(Quote quote) async {
    _favoriteQuotes.add(jsonEncode(quote.toJson()));
    await _updateFavoriteQuotesInPrefs(_favoriteQuotes);
    notifyListeners();
  }

  Future<List<Quote>> getFavoriteQuotes() async {
    await _loadFavoriteQuotesFromPrefs();
    List<Quote> quotes = _favoriteQuotes
        .map((quoteJson) => Quote.fromJson(jsonDecode(quoteJson)))
        .toList();
    return quotes;
  }

  Future<void> removeFromFavorites(Quote quote) async {
    String quoteJson = jsonEncode(quote.toJson());
    _favoriteQuotes.remove(quoteJson);
    await _updateFavoriteQuotesInPrefs(_favoriteQuotes);
    notifyListeners();
  }
}
