import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinGameScreen extends StatefulWidget {
  final String gameId; // Room ID passed from HomeScreen

  const JoinGameScreen({super.key, required this.gameId});

  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  List<String> teamAPlayers = []; // List of players in Team A
  List<String> teamBPlayers = []; // List of players in Team B
  bool gameStarted = false; // To track if the game has started
  late DocumentReference gameRef; // Reference to the current game document
  StreamSubscription<DocumentSnapshot>?
      gameListener; // Make the listener nullable
  int? mode; // Game mode (1 or 2)
  String? host; // Host user email

  @override
  void dispose() {
    gameListener
        ?.cancel(); // Stop listening for changes when the widget is disposed
    super.dispose();
  }

  // Query the Firestore collection based on gameId field instead of document ID
  Future<void> _joinGame() async {
    var gameQuery = FirebaseFirestore.instance
        .collection('games')
        .where('gameId', isEqualTo: widget.gameId) // Querying by gameId
        .limit(1); // Limit to one document

    try {
      // Get the first document that matches the gameId
      var gameSnapshot = await gameQuery.get();

      if (gameSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Game room does not exist!")),
        );
        Navigator.pop(context); // Navigate back if game doesn't exist
        return;
      }

      // Get the reference to the game document (first document in the query result)
      gameRef = gameSnapshot.docs.first.reference;

      // Listen for real-time changes in the game data
      gameListener = gameRef.snapshots().listen((gameSnapshot) {
        if (gameSnapshot.exists) {
          var gameData = gameSnapshot.data() as Map<String,
              dynamic>; // Explicitly cast to Map<String, dynamic>

          setState(() {
            // Fetch players from teamA and teamB
            teamAPlayers = List<String>.from(gameData['teams']['teamA'] ?? []);
            teamBPlayers = List<String>.from(gameData['teams']['teamB'] ?? []);
            gameStarted = gameData['gameStatus'] == 'started';
          });
        }
      });

      // Get the mode (1 or 2)
      var gameData = (await gameRef.get()).data() as Map<String, dynamic>;
      mode = gameData['mode'] ?? 1; // Default to 1 if mode is not set
      host = gameData['hostEmail'] ?? 'Host'; // Get the host email

      // Add the player to the correct team based on the mode
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (mode == 1) {
          // For mode 1 (1v1), Team A can only have 1 player
          if (teamAPlayers.isEmpty) {
            // Add to Team A if Team A is not full
            await gameRef.update({
              'teams.teamA': FieldValue.arrayUnion([user.email ?? 'Guest']),
            });
          } else {
            // If Team A is full, add to Team B
            await gameRef.update({
              'teams.teamB': FieldValue.arrayUnion([user.email ?? 'Guest']),
            });
          }
        } else if (mode == 2) {
          // For mode 2 (2v2), Team A can have up to 2 players
          if (teamAPlayers.length < 2) {
            // Add to Team A if Team A is not full
            await gameRef.update({
              'teams.teamA': FieldValue.arrayUnion([user.email ?? 'Guest']),
            });
          } else {
            // If Team A is full, add to Team B
            await gameRef.update({
              'teams.teamB': FieldValue.arrayUnion([user.email ?? 'Guest']),
            });
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error joining the game")),
      );
    }
  }

  // Show a confirmation dialog before navigating back
  Future<bool> _onBackPressed() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirm"),
            content: const Text("Are you sure you want to leave this game?"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Do nothing if cancel
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await _removePlayerFromTeam(); // Remove player from team
                  Navigator.of(context).pop(true); // Proceed with navigation
                },
                child: const Text("Leave Game"),
              ),
            ],
          ),
        ) ??
        false;
  }

  // Remove the player's email from the corresponding team (Team A or Team B)
  Future<void> _removePlayerFromTeam() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    String email = user.email ?? 'Guest';

    try {
      // Check if the game document exists before performing any updates
      var gameSnapshot = await gameRef.get();
      if (gameSnapshot.exists) {
        // Remove player from teamA or teamB
        await gameRef.update({
          'teams.teamA': FieldValue.arrayRemove([email]),
          'teams.teamB': FieldValue.arrayRemove([email]),
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Game room does not exist!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error removing player: $e")),
      );
    }
  }
}


  @override
  void initState() {
    super.initState();
    _joinGame(); // Automatically join the game when the screen is initialized
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed, // Intercept back button press
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Join Game Room"),
        ),
        body: Column(
          children: [
            // Display room ID and host user email
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Room ID: ${widget.gameId}\nHost: ${host ?? 'Host'}'),
            ),
            // Game mode info
            Text(mode == 1 ? "1 vs 1" : "2 vs 2"),

            // Show Team A and Team B with players
            Expanded(child: _buildTeamsList()),
          ],
        ),
      ),
    );
  }

  // Build the list of players from both Team A and Team B
  Widget _buildTeamsList() {
    return ListView(
      children: [
        if (teamAPlayers.isNotEmpty)
          ListTile(
            title: const Text('Team A'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: teamAPlayers.map((player) {
                return ListTile(
                  title: Text(player),
                );
              }).toList(),
            ),
          ),
        if (teamBPlayers.isNotEmpty)
          ListTile(
            title: const Text('Team B'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: teamBPlayers.map((player) {
                return ListTile(
                  title: Text(player),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  // Widget to display player list
  Widget _buildPlayerList(List<String> teamPlayers) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: teamPlayers.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(teamPlayers[index]),
          trailing: gameStarted ? const Text('In Game') : const Text('Waiting'),
        );
      },
    );
  }
}
