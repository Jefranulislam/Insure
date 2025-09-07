import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataMigrationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fix warranty entries with null or invalid timestamps
  static Future<void> fixNullTimestamps() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return;
      }

      print('🔧 Starting timestamp migration for user: ${user.uid}');

      final QuerySnapshot warranties = await _firestore
          .collection('warranties')
          .where('userId', isEqualTo: user.uid)
          .get();

      int fixedCount = 0;
      int totalCount = warranties.docs.length;

      for (var doc in warranties.docs) {
        final data = doc.data() as Map<String, dynamic>;
        bool needsUpdate = false;
        Map<String, dynamic> updates = {};

        // Check expiryDate
        if (data['expiryDate'] == null) {
          // Set a default expiry date (1 year from now)
          updates['expiryDate'] = Timestamp.fromDate(
            DateTime.now().add(Duration(days: 365)),
          );
          needsUpdate = true;
          print('⚠️ Fixed null expiryDate for warranty: ${doc.id}');
        }

        // Check purchaseDate
        if (data['purchaseDate'] == null) {
          // Set default purchase date (today)
          updates['purchaseDate'] = Timestamp.now();
          needsUpdate = true;
          print('⚠️ Fixed null purchaseDate for warranty: ${doc.id}');
        }

        // Check createdAt
        if (data['createdAt'] == null) {
          updates['createdAt'] = Timestamp.now();
          needsUpdate = true;
          print('⚠️ Fixed null createdAt for warranty: ${doc.id}');
        }

        if (needsUpdate) {
          await doc.reference.update(updates);
          fixedCount++;
        }
      }

      print(
        '✅ Migration complete! Fixed $fixedCount out of $totalCount warranties',
      );
    } catch (e) {
      print('❌ Error during timestamp migration: $e');
    }
  }

  /// Remove warranty entries that are completely corrupted
  static Future<void> removeCorruptedEntries() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return;
      }

      print('🗑️ Checking for corrupted warranty entries...');

      final QuerySnapshot warranties = await _firestore
          .collection('warranties')
          .where('userId', isEqualTo: user.uid)
          .get();

      int removedCount = 0;

      for (var doc in warranties.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Check if essential fields are missing
        if (data['productName'] == null ||
            data['productName'].toString().trim().isEmpty) {
          print('🗑️ Removing corrupted warranty (no product name): ${doc.id}');
          await doc.reference.delete();
          removedCount++;
        }
      }

      print('✅ Removed $removedCount corrupted entries');
    } catch (e) {
      print('❌ Error during cleanup: $e');
    }
  }

  /// Run full data migration and cleanup
  static Future<void> runFullMigration() async {
    print('🚀 Starting full data migration...');
    await fixNullTimestamps();
    await removeCorruptedEntries();
    print('🎉 Data migration completed!');
  }
}
