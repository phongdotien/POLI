import 'package:flutter/material.dart';

import '../../../../constants.dart';

// Component hiển thị Rank Pickleball
class RankCard extends StatelessWidget {
  final String title;
  final String rank;
  final int score; // Thêm tham số score để hiển thị điểm hiện tại

  const RankCard({
    super.key,
    required this.title,
    required this.rank,
    required this.score, // Khởi tạo tham số score
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(rank, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            // Hiển thị số điểm hiện tại
            Text(
              "Score: $score", 
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
