import 'package:flutter/material.dart';


class MakeGameScreen extends StatefulWidget {
  final int mode; // 1 for 1v1, 2 for 2v2
  const MakeGameScreen({super.key, this.mode = 1}); // Default is 1v1

  @override
  State<MakeGameScreen> createState() => _MakeGameScreenState();
}

class _MakeGameScreenState extends State<MakeGameScreen> {
  List<String> players = []; // List of players in the room
  bool gameStarted = false; // To track if game has started

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Game Room"),
      ),
      body: Column(
        children: [
          // Show the game mode
          Text(widget.mode == 1 ? "1 vs 1" : "2 vs 2"),
          
          // Show player slots for 2 vs 2
          if (widget.mode == 2) _build2v2Slots(),
          
          // Button for starting the game
          if (!gameStarted && players.length == 4)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  gameStarted = true;
                });
              },
              child: const Text("Start Game"),
            ),
          
          // Show player list and other actions
          _buildPlayerList(),
          
          // Show result input when the game is finished
          if (gameStarted)
            _buildGameResultInput(),
        ],
      ),
    );
  }

  // Widget to build 4 player slots for 2 vs 2
  Widget _build2v2Slots() {
    return Column(
      children: List.generate(4, (index) {
        return ListTile(
          title: Text('Slot ${index + 1}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                players.removeAt(index); // Remove player from the slot
              });
            },
          ),
        );
      }),
    );
  }

  // Show list of players in the room
  Widget _buildPlayerList() {
    return Column(
      children: players.map((player) {
        return ListTile(
          title: Text(player),
          trailing: widget.mode == 2
              ? IconButton(
                  icon: const Icon(Icons.shuffle),
                  onPressed: () {
                    setState(() {
                      players.shuffle(); // Shuffle players for random teams
                    });
                  },
                )
              : null,
        );
      }).toList(),
    );
  }

  // Widget for entering game result after the game is over
  Widget _buildGameResultInput() {
    return Column(
      children: [
        const Text("Enter match result:"),
        const TextField(
          decoration: InputDecoration(labelText: "Result"),
        ),
        ElevatedButton(
          onPressed: () {
            // Logic to save the result
          },
          child: const Text("Submit Result"),
        ),
      ],
    );
  }
}

