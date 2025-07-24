import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataService {
  // Method to update user rank and score based on the game outcome
  Future<void> updateRankAndScore(
      List<String> winningTeam,
      List<String> losingTeam,
      int winningScore,
      int losingScore,
      int mode) async {
    try {
      // Reference to the Firestore 'users' collection
      FirebaseFirestore.instance.collection('users');

      // Get the bonus multiplier for a strong win
      int winBonus = 0;
      if ((winningScore - losingScore) > 5) {
        winBonus = 1;
      }

      // Loop through the players in the winning team
      for (String playerEmail in winningTeam) {
        await _updatePlayerScore(playerEmail, (5 + winBonus), true, mode);
      }

      // Loop through the players in the losing team
      for (String playerEmail in losingTeam) {
        await _updatePlayerScore(playerEmail, -5, false, mode);
      }

      print("User rank and score updated successfully.");
    } catch (e) {
      print("Error updating user data: $e");
    }
  }

  // Helper method to update player score and rank
  Future<void> _updatePlayerScore(
      String playerEmail, int scoreChange, bool isWinning, int mode) async {
    try {
      // Reference to the Firestore 'users' collection
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      // Get the user document by email (assuming email is unique)
      QuerySnapshot snapshot =
          await users.where('email', isEqualTo: playerEmail).get();
      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = snapshot.docs.first;

        // Get the current score and rank for the user based on mode
        int currentScore = 0;
        double currentRank = 0.0;

        if (mode == 1) {
          // 1v1 Mode
          currentScore = userDoc['score_single'] ?? 0;
          currentRank = userDoc['rank_single'] ?? 0.0;
        } else {
          // 2v2 Mode
          currentScore = userDoc['score_dual'] ?? 0;
          currentRank = userDoc['rank_dual'] ?? 0.0;
        }

        // Update the score
        int newScore = currentScore + scoreChange;

        // If score exceeds 100, reset and increase rank
        if (newScore > 100) {
          newScore = newScore - 100; // Reset the score to below 100
          currentRank += 0.1; // Increase rank by 0.1
        }
        // If score is negative, add 100 and decrease rank
        else if (newScore < 0) {
          newScore = newScore + 100; // Add 100 to the score if it's negative
          currentRank -= 0.1; // Decrease rank by 0.1
        }


        // Update the user data in Firestore
        if (mode == 1) {
          // Update rank and score for single mode
          await users.doc(userDoc.id).update({
            'score_single': newScore,
            'rank_single': currentRank,
          });
        } else {
          // Update rank and score for dual mode
          await users.doc(userDoc.id).update({
            'score_dual': newScore,
            'rank_dual': currentRank,
          });
        }

      }
    } catch (e) {
    }
  }
}
