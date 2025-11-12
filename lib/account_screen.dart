import 'package:flutter/material.dart';
import 'login_page.dart';
import 'services/auth_service.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool notificationsOn = true;
  String userName = 'Loading...';
  String userEmail = 'Loading...';
  String userId = '2303715'; // Keep hardcoded as not in AuthService

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await AuthService.getCurrentUser();
    if (userData != null) {
      setState(() {
        userName = userData['name'] ?? 'Unknown';
        userEmail = userData['email'] ?? 'Unknown';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0E7FF), // light blue background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue[900]),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Account',
          style: TextStyle(
            color: Colors.blue[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Center(
              child: Column(
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    userId,
                    style: TextStyle(fontSize: 16, color: Colors.blue[700]),
                  ),
                  SizedBox(height: 5),
                  Text(
                    userEmail,
                    style: TextStyle(fontSize: 14, color: Colors.blue[500]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            // Buttons: Edit Profile & Log Out
            Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[700],
                    child: Icon(Icons.edit, color: Colors.white),
                  ),
                  title: Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.blue[700],
                    size: 16,
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[700],
                    child: Icon(Icons.logout, color: Colors.white),
                  ),
                  title: Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.blue[700],
                    size: 16,
                  ),
                  onTap: () async {
                    await AuthService.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            // Settings header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ),
            // Settings options
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[700],
                child: Icon(Icons.notifications, color: Colors.white),
              ),
              title: Text(
                'Notifications',
                style: TextStyle(
                  color: Colors.blue[900],
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                '(Recommended to be on)',
                style: TextStyle(fontSize: 12, color: Colors.blue[500]),
              ),
              trailing: Switch(
                value: notificationsOn,
                onChanged: (val) {
                  setState(() {
                    notificationsOn = val;
                  });
                },
                activeColor: Colors.blue[700],
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[700],
                child: Icon(Icons.info_outline, color: Colors.white),
              ),
              title: Text(
                'About',
                style: TextStyle(
                  color: Colors.blue[900],
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Vote BYTE App 0.1.0',
                style: TextStyle(fontSize: 12, color: Colors.blue[500]),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
