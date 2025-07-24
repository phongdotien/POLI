import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/screens/home/views/components/rank_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String rankSingle = "Loading...";
  int scoreSingle = 0;
  String rankDual = "Loading...";
  int scoreDual = 0;
  final TextEditingController _roomIdController =
      TextEditingController(); // Controller for room ID input

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            rankSingle = userDoc['rank_single'].toString();
            scoreSingle = userDoc['score_single'];
            rankDual = userDoc['rank_dual'].toString();
            scoreDual = userDoc['score_dual'];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          rankSingle = "Error";
          scoreSingle = 0;
          rankDual = "Error";
          scoreDual = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error fetching user data")),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data when the screen is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Mục 1: Hiển thị Rank Pickleball hiện tại của bạn (rank đơn và rank đôi)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Current Pickleball Rank",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    // Display the rank cards with the fetched data
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RankCard(
                          title: "Singles Rank",
                          rank: rankSingle, // Display fetched rank
                          score: scoreSingle, // Display fetched score
                        ),
                        RankCard(
                          title: "Doubles Rank",
                          rank: rankDual, // Display fetched rank
                          score: scoreDual, // Display fetched score
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: defaultPadding)),

            // Mục 2: Game play với 2 cách chơi (1v1 và 2v2)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Choose Your Game Mode",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: defaultPadding),
                    // Game mode selection buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _GameModeButton(
                            title: "1 vs 1",
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, createGameRoom1vs1ScreenRoute);
                            },
                          ),
                        ),
                        const SizedBox(width: defaultPadding),
                        Expanded(
                          child: _GameModeButton(
                            title: "2 vs 2",
                            onPressed: () {
                              // Navigate to Game 2v2
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: defaultPadding),

                    // Room ID input and Join Room button row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _roomIdController,
                              decoration: const InputDecoration(
                                labelText: 'Enter Room ID',
                                hintText: 'Room ID',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: defaultPadding),
                        Expanded(
                          child: _GameModeButton(
                            title: "Join Room",
                            onPressed: () {
                              String roomId = _roomIdController.text.trim();
                              if (roomId.isNotEmpty) {
                                Navigator.pushNamed(
                                  context,
                                  joinGameRoom1vs1ScreenRoute,
                                  arguments: roomId, // Passing roomId as argument
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please enter a valid room ID"),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Component hiển thị nút chơi game
class _GameModeButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const _GameModeButton({required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(120, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
