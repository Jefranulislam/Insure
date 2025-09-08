import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DataMigrationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fix missing expiry dates by calculating them from purchase date and warranty period
  static Future<void> fixMissingExpiryDates() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return;
      }

      print('📅 Starting expiry date migration for user: ${user.uid}');

      final QuerySnapshot warranties = await _firestore
          .collection('warranties')
          .where('userId', isEqualTo: user.uid)
          .get();

      int fixedCount = 0;
      int totalCount = warranties.docs.length;

      for (var doc in warranties.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Check if expiryDate is missing
        if (data['expiryDate'] == null) {
          bool needsUpdate = false;
          DateTime? calculatedExpiryDate;

          // Try to calculate expiry date from purchase date and warranty period
          try {
            String? purchaseDateStr = data['purchaseDate']?.toString();
            String? warrantyPeriodStr = data['warrantyPeriod']?.toString();

            if (purchaseDateStr != null && warrantyPeriodStr != null) {
              // Parse purchase date
              DateTime purchaseDate;

              // Handle different date formats
              if (purchaseDateStr.contains('/')) {
                // Format: "7/8/2025" or "07/08/2025"
                try {
                  purchaseDate = DateFormat('d/M/yyyy').parse(purchaseDateStr);
                } catch (e) {
                  try {
                    purchaseDate = DateFormat(
                      'dd/MM/yyyy',
                    ).parse(purchaseDateStr);
                  } catch (e) {
                    purchaseDate = DateTime.now().subtract(
                      Duration(days: 30),
                    ); // Default to 30 days ago
                  }
                }
              } else {
                // Assume it's already a proper date string or timestamp
                purchaseDate = DateTime.now().subtract(
                  Duration(days: 30),
                ); // Default fallback
              }

              // Parse warranty period (e.g., "12 months", "2 years", "24 months")
              int warrantyMonths = 12; // Default 1 year

              if (warrantyPeriodStr.toLowerCase().contains('month')) {
                final monthMatch = RegExp(
                  r'(\d+)',
                ).firstMatch(warrantyPeriodStr);
                if (monthMatch != null) {
                  warrantyMonths = int.parse(monthMatch.group(1)!);
                }
              } else if (warrantyPeriodStr.toLowerCase().contains('year')) {
                final yearMatch = RegExp(
                  r'(\d+)',
                ).firstMatch(warrantyPeriodStr);
                if (yearMatch != null) {
                  warrantyMonths = int.parse(yearMatch.group(1)!) * 12;
                }
              }

              // Calculate expiry date
              calculatedExpiryDate = DateTime(
                purchaseDate.year,
                purchaseDate.month + warrantyMonths,
                purchaseDate.day,
              );

              needsUpdate = true;
              print(
                '✅ Calculated expiry for ${data['productName']}: $calculatedExpiryDate (${warrantyMonths} months from $purchaseDate)',
              );
            }
          } catch (e) {
            print('⚠️ Error calculating expiry date for ${doc.id}: $e');
          }

          // If we couldn't calculate, use default (1 year from now)
          if (calculatedExpiryDate == null) {
            calculatedExpiryDate = DateTime.now().add(Duration(days: 365));
            needsUpdate = true;
            print(
              '⚠️ Using default expiry date for ${data['productName']}: $calculatedExpiryDate',
            );
          }

          if (needsUpdate) {
            await doc.reference.update({
              'expiryDate': Timestamp.fromDate(calculatedExpiryDate),
            });
            fixedCount++;
          }
        }
      }

      print(
        '✅ Expiry date migration complete! Fixed $fixedCount out of $totalCount warranties',
      );
    } catch (e) {
      print('❌ Error during expiry date migration: $e');
    }
  }

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
    await fixMissingExpiryDates();
    await fixNullTimestamps();
    await removeCorruptedEntries();
    print('🎉 Data migration completed!');
  }
}
