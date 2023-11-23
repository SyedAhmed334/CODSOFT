// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:codsoft_quote_app/qoutes_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import 'favorite_provider.dart';
import 'favorite_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Quote> _quotesFuture;

  Future<Quote> getQuotes() async {
    var response =
        await http.get(Uri.parse('https://api.quotable.io/quotes/random'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body.toString());
      return Quote.fromJson(
          data[0]); // Convert the fetched data to Quote object
    } else {
      throw Exception('Error');
    }
  }

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _quotesFuture = getQuotes();
  }

  @override
  Widget build(BuildContext context) {
    final favorite = Provider.of<FavoriteProvider>(context, listen: false);
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Daily Quotes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Home Screen'),
              onTap: () {
                // Perform action when Item 1 is tapped
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HomeScreen())); // Close the drawer
              },
            ),
            ListTile(
              title: Text('Favorite Screen'),
              onTap: () {
                // Perform action when Item 2 is tapped
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            FavoriteScreen())); // Close the drawer
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("Quotes App"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _quotesFuture = getQuotes(); // Refresh quotes
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh,
                    ),
                    Text(
                      'Change Quote',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            FutureBuilder(
              future: _quotesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child:
                        CircularProgressIndicator(), // Show a loading indicator
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  Quote quote = snapshot.data as Quote;
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [Colors.red, Colors.pink, Colors.purple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        height: MediaQuery.of(context).size.height * 0.55,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              quote.content,
                              style: TextStyle(
                                fontSize: 22,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16), // Add some spacing
                            Text(
                              quote.author,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      Share.share(
                                          '${quote.content} \n- ${quote.author}');
                                    });
                                  },
                                  icon: Icon(Icons.share),
                                ),
                                Text(
                                  'Share',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Consumer<FavoriteProvider>(
                                  builder: (BuildContext context,
                                      FavoriteProvider value, Widget? child) {
                                    return IconButton(
                                      onPressed: () async {
                                        bool isQuoteInFavorites =
                                            favorite.favoriteQuotes.contains(
                                                jsonEncode(quote.toJson()));
                                        if (isQuoteInFavorites) {
                                          favorite.removeFromFavorites(quote);
                                        } else {
                                          await favorite.addToFavorites(quote);
                                        }
                                      },
                                      icon: favorite.favoriteQuotes.contains(
                                              jsonEncode(quote.toJson()))
                                          ? Icon(Icons.favorite,
                                              color: Colors.red)
                                          : Icon(
                                              Icons.favorite_border_outlined),
                                    );
                                  },
                                ),
                                Text(
                                  'Favorite',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return Text('No data available');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
