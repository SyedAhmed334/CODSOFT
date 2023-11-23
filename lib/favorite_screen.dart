// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../favorite_provider.dart';
import '../qoutes_model.dart';
import 'home_screen.dart'; // Ensure the import path is correct for the Quote model

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final myFavoriteItems =
        Provider.of<FavoriteProvider>(context).favoriteQuotes;
    final favoriteProvider = Provider.of<FavoriteProvider>(context,
        listen: false); // Added to access remove method

    return Scaffold(
      drawer: Drawer(
        width: 220,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
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
              title: Text(
                'Home Screen',
                style: TextStyle(fontSize: 18),
              ),
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
              title: Text(
                'Favorite Screen',
                style: TextStyle(fontSize: 18),
              ),
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
        title: const Text('My Favorite Quotes'),
      ),
      body: myFavoriteItems.isEmpty
          ? Center(
              child: Text('No favorite quotes yet!'),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                itemCount: myFavoriteItems.length,
                itemBuilder: (context, index) {
                  Quote quote = Quote.fromJson(
                      jsonDecode(myFavoriteItems[index])); // Decode quote
                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ListTile(
                      title: Text(
                        quote.content,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Text(
                          '~${quote.author}',
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.favorite, color: Colors.red),
                        onPressed: () {
                          favoriteProvider.removeFromFavorites(
                              quote); // Remove from favorites on tap
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
