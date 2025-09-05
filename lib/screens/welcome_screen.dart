import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(200, 240, 244, 246),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/iconINSURESO.webp',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(200, 136, 136, 136),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.security,
                        size: 60,
                        color: Color.fromARGB(200, 34, 34, 34),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 30),

            // App Name and Logo
            Column(
              children: [
                // Just the tagline, no logo text anymore
                SizedBox(height: 8),
                Text(
                  'Never Lose a Warranty Again',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(200, 102, 102, 102),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Tagline
            Text(
              'Never Lose a Warranty Again',
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(200, 136, 136, 136),
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 60),

            // Features List
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  FeatureRow(
                    icon: Icons.camera_alt,
                    text: 'Scan & Store Warranty Cards',
                    iconColor: Color.fromARGB(200, 68, 68, 68),
                    textColor: Color.fromARGB(200, 68, 68, 68),
                  ),
                  FeatureRow(
                    icon: Icons.notifications,
                    text: 'Get Expiry Reminders',
                    iconColor: Color.fromARGB(200, 68, 68, 68),
                    textColor: Color.fromARGB(200, 68, 68, 68),
                  ),
                  FeatureRow(
                    icon: Icons.email,
                    text: 'Direct Warranty Claims',
                    iconColor: Color.fromARGB(200, 68, 68, 68),
                    textColor: Color.fromARGB(200, 68, 68, 68),
                  ),
                ],
              ),
            ),
            SizedBox(height: 60),

            // Get Started Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/registration');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(200, 68, 68, 68),
                  foregroundColor: Color.fromARGB(200, 34, 34, 34),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: Container(
                  width: double.infinity,
                  child: Text(
                    'Get Started',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color textColor;
  final Color iconColor;
  FeatureRow({
    required this.icon,
    required this.text,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          SizedBox(width: 16),
          Text(text, style: TextStyle(color: textColor, fontSize: 16)),
        ],
      ),
    );
  }
}
