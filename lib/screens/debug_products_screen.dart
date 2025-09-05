import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DebugProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Debug Products'),
        backgroundColor: Color(0xFF1E88E5),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Authentication Status:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('User: ${user?.email ?? "Not logged in"}'),
                    Text('UID: ${user?.uid ?? "N/A"}'),
                    Text('Is Anonymous: ${user?.isAnonymous ?? "N/A"}'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Query Test 1: All warranties (no filter)
            Text(
              'All Warranties (No Filter):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Expanded(
              flex: 1,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('warranties')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    );
                  }
                  return Text(
                    'Total warranties in DB: ${snapshot.data?.docs.length ?? 0}',
                  );
                },
              ),
            ),

            // Query Test 2: User-specific warranties
            Text(
              'User-Specific Warranties:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Expanded(
              flex: 1,
              child: user != null
                  ? StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('warranties')
                          .where('userId', isEqualTo: user.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(color: Colors.red),
                          );
                        }
                        return Text(
                          'User warranties: ${snapshot.data?.docs.length ?? 0}',
                        );
                      },
                    )
                  : Text('User not logged in'),
            ),

            // Query Test 3: With orderBy
            Text(
              'User Warranties with OrderBy:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Expanded(
              flex: 2,
              child: user != null
                  ? StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('warranties')
                          .where('userId', isEqualTo: user.uid)
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Container(
                            padding: EdgeInsets.all(8),
                            color: Colors.red.shade100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Error with orderBy query:',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${snapshot.error}',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Text('No user warranties found with orderBy');
                        }

                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var doc = snapshot.data!.docs[index];
                            var data = doc.data() as Map<String, dynamic>;
                            return Card(
                              margin: EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Product: ${data['productName'] ?? 'N/A'}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text('Brand: ${data['brand'] ?? 'N/A'}'),
                                    Text(
                                      'Created: ${data['createdAt']?.toString() ?? 'N/A'}',
                                    ),
                                    Text('UserId: ${data['userId'] ?? 'N/A'}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    )
                  : Text('User not logged in'),
            ),
          ],
        ),
      ),
    );
  }
}
