import 'dart:async';
import 'dart:math'; // For generating random number
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop/screens/auth/views/components/user_service.dart';

class MakeGameScreen extends StatefulWidget {
  final int mode; // 1 for 1v1, 2 for 2v2
  const MakeGameScreen({super.key, this.mode = 1});

  @override
  State<MakeGameScreen> createState() => _MakeGameScreenState();
}

class _MakeGameScreenState extends State<MakeGameScreen> {
  List<String> teamA = []; // List of players in Team A
  List<String> teamB = []; // List of players in Team B
  bool gameStarted = false; // To track if the game has started
  bool showFinishButtons =
      false; // To track if the "Finish" and "Cancel" buttons should be displayed
  late DocumentReference gameRef; // Reference to the current game document
  StreamSubscription<DocumentSnapshot>? gameListener;
  String? gameId; // Store generated game ID

  @override
  void initState() {
    super.initState();
    _createNewGame(); // Create a new game when the screen is initialized
  }

  @override
  void dispose() {
    gameListener
        ?.cancel(); // Stop listening for changes when the widget is disposed
    super.dispose();
  }

  // Generate a random 6-digit Game ID
  String _generateGameId() {
    Random random = Random();
    return (100000 + random.nextInt(900000))
        .toString(); // Generates a 6-digit number
  }

  // Create a new game and get the gameId
  Future<void> _createNewGame() async {
    try {
      String gameId = _generateGameId(); // Generate a random 6-digit game ID
      DocumentReference newGameRef =
          await FirebaseFirestore.instance.collection('games').add({
        'gameId': gameId, // Save the generated gameId in the document
        'mode': widget.mode, // Save the game mode
        'hostUid': FirebaseAuth.instance.currentUser?.uid,
        'players': [],
        'teams': {
          'teamA': [], // Initialize Team A
          'teamB': [], // Initialize Team B
        },
        'gameStatus': 'waiting', // Initially, the game is in waiting state
        'hostEmail': FirebaseAuth.instance.currentUser?.email ?? 'Host',
      });

      setState(() {
        this.gameId = gameId;
        gameRef = newGameRef;
      });

      _addHostToTeamA(); // Add the host to Team A
      _fetchGameData(); // Start fetching game data
    } catch (e) {
      print("Error creating new game: $e");
    }
  }

  // Fetch the game data
  void _fetchGameData() {
    gameListener = gameRef.snapshots().listen((gameSnapshot) {
      if (gameSnapshot.exists) {
        var gameData = gameSnapshot.data() as Map<String, dynamic>;
        setState(() {
          teamA = List<String>.from(gameData['teams']['teamA'] ?? []);
          teamB = List<String>.from(gameData['teams']['teamB'] ?? []);
          gameStarted = gameData['gameStatus'] == 'started';
        });
      }
    });
  }

  // Add the Host to Team A automatically
  Future<void> _addHostToTeamA() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await gameRef.update({
          'teams.teamA': FieldValue.arrayUnion([user.email ?? 'Host']),
        });
      } catch (e) {
        print("Error adding host to Team A: $e");
      }
    }
  }

  // Shuffle players and update their teams
  Future<void> _shufflePlayers() async {
    List<String> shuffledPlayers = List.from(teamA + teamB);
    shuffledPlayers.shuffle();

    // Assign shuffled players to teams
    List<String> newTeamA =
        shuffledPlayers.sublist(0, shuffledPlayers.length ~/ 2);
    List<String> newTeamB =
        shuffledPlayers.sublist(shuffledPlayers.length ~/ 2);

    await gameRef.update({
      'teams': {
        'teamA': newTeamA,
        'teamB': newTeamB,
      }
    });
  }

  // Start the game
  Future<void> _startGame() async {
    await gameRef.update({'gameStatus': 'started'});
    setState(() {
      showFinishButtons =
          true; // Show the Finish and Cancel buttons after starting the game
    });
  }

  // Show a confirmation dialog before navigating back
  Future<bool> _onBackPressed() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirm"),
            content:
                const Text("Are you sure you want to delete this game room?"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Do nothing if cancel
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  _deleteGameRoom(); // Delete game room if confirmed
                  Navigator.of(context).pop(true); // Proceed with navigation
                },
                child: const Text("Delete"),
              ),
            ],
          ),
        ) ??
        false;
  }

  // Method to delete the game room from Firestore
  Future<void> _deleteGameRoom() async {
    try {
      await gameRef.delete(); // Delete the game document
      if (mounted) {
        Navigator.of(context).pop(); // Go back after deletion
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete the game room")),
        );
      }
    }
  }

  // Method to remove player from team
  Future<void> _removePlayerFromTeam() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email ?? 'Guest';
      await gameRef.update({
        'teams.teamA': FieldValue.arrayRemove([email]),
        'teams.teamB': FieldValue.arrayRemove([email]),
      });
    }
  }

  // Method to finish the game and show score input dialog
  Future<void> _finishGame() async {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController teamAScoreController = TextEditingController();
        TextEditingController teamBScoreController = TextEditingController();

        return AlertDialog(
          title: const Text("Enter Final Scores"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: teamAScoreController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Team A Score"),
              ),
              const SizedBox(height: 10),
              // Add a space between the two text fields
              TextField(
                controller: teamBScoreController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Team B Score"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                showFinishButtons =
                    false; // Hide Finish buttons after confirmation
                // Update game status and score
                await gameRef.update({
                  'gameStatus': 'finished',
                  'teamWin': (int.parse(teamAScoreController.text) >
                          int.parse(teamBScoreController.text))
                      ? 'A'
                      : 'B',
                  'score':
                      '${teamAScoreController.text}-${teamBScoreController.text}',
                });
                // Create game history
                // Save the game history with the correct structure
                await FirebaseFirestore.instance
                    .collection('game_history')
                    .add({
                  'gameId': gameId,
                  'teams': {
                    'teamA': teamA, // Store the list of players in team A
                    'teamB': teamB, // Store the list of players in team B
                  },
                  'teamWin': (int.parse(teamAScoreController.text) >
                          int.parse(teamBScoreController.text))
                      ? 'A'
                      : 'B',
                  'score':
                      '${teamAScoreController.text}-${teamBScoreController.text}',
                  'endTime': Timestamp.now(),
                  'mode': widget.mode,
                });
                // Determine the winning and losing teams
                List<String> winningTeam =
                    (int.parse(teamAScoreController.text) >
                            int.parse(teamBScoreController.text))
                        ? teamA
                        : teamB;
                List<String> losingTeam =
                    (int.parse(teamAScoreController.text) >
                            int.parse(teamBScoreController.text))
                        ? teamB
                        : teamA;

                // Update user rank and score for each user based on the result
                UserDataService userDataService = UserDataService();
                await userDataService.updateRankAndScore(
                    winningTeam,
                    losingTeam,
                    int.parse(teamAScoreController.text),
                    int.parse(teamBScoreController.text),
                    widget.mode);
                Navigator.of(context).pop();
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed, // Intercept back button press
      child: Scaffold(
        appBar: AppBar(title: const Text("Game Room")),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.h),
              child: Text(
                'Room ID: $gameId\nHost: ${FirebaseAuth.instance.currentUser?.email ?? 'Host'}',
                style: TextStyle(fontSize: 24.h),
              ),
            ),
            Text(widget.mode == 1 ? "1 vs 1" : "2 vs 2",
                style: TextStyle(fontSize: 24.h)),
            const SizedBox(height: 20),
            // Display the list of players in Team A and Team B
            // Use a ListView to show the teams
            // and their players

            Expanded(child: _buildTeamsList()),
            if (showFinishButtons)
              Padding(
                padding: EdgeInsets.all(16.h),
                child: Text(
                  "Game Started",
                  style: TextStyle(fontSize: 16.h),
                ),
              ),
            // Show Finish and Cancel buttons if game is started
            if (showFinishButtons)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.all(16.h), // Responsive padding for button
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            gameRef.update(
                                {'gameStatus': 'waiting'}); // Reset game status
                            showFinishButtons =
                                false; // Show Shuffle and Start buttons again
                          });
                        },
                        child: const Text("Cancel"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.all(16.h), // Responsive padding for button
                      child: ElevatedButton(
                        onPressed: _finishGame,
                        child: const Text("Finish"),
                      ),
                    ),
                  ),
                ],
              ),

            // Shuffle and Start buttons if enough players are in the game
            if (!gameStarted &&
                (teamA.length + teamB.length) == (widget.mode == 1 ? 2 : 4))
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.all(16.h), // Responsive padding for button
                      child: ElevatedButton(
                        onPressed: _shufflePlayers,
                        child: const Text("Shuffle Players"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.all(16.h), // Responsive padding for button
                      child: ElevatedButton(
                        onPressed: _startGame,
                        child: const Text("Start Game"),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Build list of players from Team A and Team B
  Widget _buildTeamsList() {
    return ListView(
      children: [
        if (teamA.isNotEmpty)
          ListTile(
            title: const Text('Team A'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: teamA.map((player) {
                return ListTile(
                  title: Text(player),
                  trailing: player == FirebaseAuth.instance.currentUser?.email
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _kickPlayer(player),
                        ),
                );
              }).toList(),
            ),
          ),
        if (teamB.isNotEmpty)
          ListTile(
            title: const Text('Team B'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: teamB.map((player) {
                return ListTile(
                  title: Text(player),
                  trailing: player == FirebaseAuth.instance.currentUser?.email
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _kickPlayer(player),
                        ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  // Kick a player from the game
  Future<void> _kickPlayer(String playerEmail) async {
    await gameRef.update({
      'teams.teamA': FieldValue.arrayRemove([playerEmail]),
      'teams.teamB': FieldValue.arrayRemove([playerEmail]),
    });
  }
}
