import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static Stream<int> getExpiringProductsCount() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value(0);
    }

    return FirebaseFirestore.instance
        .collection('warranties')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return 0;

          // Count products expiring in 30 days or less
          var expiringCount = snapshot.docs.where((doc) {
            var data = doc.data();
            try {
              final expiryTimestamp = data['expiryDate'];
              if (expiryTimestamp == null) return false;
              var expiryDate = (expiryTimestamp as Timestamp).toDate();
              var daysLeft = expiryDate.difference(DateTime.now()).inDays;
              return daysLeft <= 30; // 30 days or less
            } catch (e) {
              print('❌ Error parsing expiryDate in notification service: $e');
              return false;
            }
          }).length;

          return expiringCount;
        });
  }

  static Stream<List<Map<String, dynamic>>> getExpiringProducts() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('warranties')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return [];

          // Filter and sort products expiring in 30 days or less
          var expiringProducts = snapshot.docs
              .where((doc) {
                var data = doc.data();
                try {
                  final expiryTimestamp = data['expiryDate'];
                  if (expiryTimestamp == null) return false;
                  var expiryDate = (expiryTimestamp as Timestamp).toDate();
                  var daysLeft = expiryDate.difference(DateTime.now()).inDays;
                  return daysLeft <= 30; // 30 days or less
                } catch (e) {
                  print(
                    '❌ Error parsing expiryDate in getExpiringProducts: $e',
                  );
                  return false;
                }
              })
              .map((doc) {
                var data = doc.data();
                data['documentId'] = doc.id;
                return data;
              })
              .toList();

          // Sort by days remaining (most urgent first)
          expiringProducts.sort((a, b) {
            try {
              var aExpiry = (a['expiryDate'] as Timestamp).toDate();
              var bExpiry = (b['expiryDate'] as Timestamp).toDate();
              var aDays = aExpiry.difference(DateTime.now()).inDays;
              var bDays = bExpiry.difference(DateTime.now()).inDays;
              return aDays.compareTo(bDays);
            } catch (e) {
              print('❌ Error sorting expiring products: $e');
              return 0;
            }
          });

          return expiringProducts;
        });
  }

  static int getDaysRemaining(DateTime expiryDate) {
    return expiryDate.difference(DateTime.now()).inDays;
  }

  static String getUrgencyLevel(int daysLeft) {
    if (daysLeft < 0) return 'EXPIRED';
    if (daysLeft <= 7) return 'URGENT';
    if (daysLeft <= 30) return 'EXPIRING SOON';
    return 'GOOD';
  }

  static bool isExpiringSoon(DateTime expiryDate) {
    return getDaysRemaining(expiryDate) <= 30;
  }

  static bool isExpired(DateTime expiryDate) {
    return getDaysRemaining(expiryDate) < 0;
  }
}
