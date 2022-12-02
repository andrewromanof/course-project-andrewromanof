import 'package:flutter/material.dart';
import '../../../models/Account.dart';

class SearchPage extends SearchDelegate {
  // Filler account list
  List<Account> Accounts = [
    Account(userName: "User1", password: "abc123", email: "User1@email.com"),
    Account(userName: "Name2", password: "123abc", email: "User1@email.com"),
    Account(userName: "Person3", password: "qwerty45", email: "User1@email.com"),
  ];

  List<String> searchTerms = [];

  @override
  void getsearchTerms() {
    searchTerms.clear();
    for (var account in Accounts) {
      searchTerms.add(account.userName.toString());
    }
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var users in searchTerms) {
      if (users.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(users);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    getsearchTerms();
    List<String> matchQuery = [];
    for (var users in searchTerms) {
      if (users.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(users);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }

}