import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/screens/home/views/components/rank_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RankCard(title: "Singles Rank", rank: "A2", score: 100),  // Example rank and score
                        RankCard(title: "Doubles Rank", rank: "B1", score: 85),  // Example rank and score
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _GameModeButton(
                          title: "1 vs 1",
                          onPressed: () {
                            // Navigator.pushNamed(context, createGameRoom1vs1ScreenRoute);  // Navigate to Game 1v1
                          },
                        ),
                        _GameModeButton(
                          title: "2 vs 2",
                          onPressed: () {
                            // Navigator.pushNamed(context, createGameRoom2vs2ScreenRoute);  // Navigate to Game 2v2
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: defaultPadding),
                    _GameModeButton(
                      title: "Join Room",
                      onPressed: () {
                        // Navigator.pushNamed(context, joinRoomScreenRoute);  // Navigate to Join Room
                      },
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
