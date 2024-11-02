import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class ProfileScreen extends StatelessWidget {
  Widget _buildInfoCard(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[100]!,
              Colors.grey[200]!,
            ],
          ),
        ),
        child: SafeArea(
          child: user == null
              ? Center(child: CircularProgressIndicator())
              : CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.grey[100],
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    user.fullName,
                    style: TextStyle(color: Colors.black),
                  ),
                  titlePadding: EdgeInsets.only(left: 50, bottom: 10),
                  background: Container(
                    color: Colors.grey[100],
                    height: 200, // Adjust this value based on your logo size
                    width: 200,  // Adjust this value based on your logo size
                    child: Image.asset(
                      'lib/images/2.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () {
                      authService.logout();
                      Navigator.pushReplacementNamed(context, '/');
                    },
                  ),
                ],
              ),
              SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildInfoCard('Email', user.email),
                    _buildInfoCard('Date of Birth', user.dateOfBirth),
                    _buildInfoCard('Time of Birth', user.timeOfBirth),
                    _buildInfoCard('Location of Birth', user.locationOfBirth),
                    _buildInfoCard('Blood Group', user.bloodGroup),
                    _buildInfoCard('Sex', user.sex),
                    _buildInfoCard('Height', user.height),
                    _buildInfoCard('Ethnicity', user.ethnicity),
                    _buildInfoCard('Eye Color', user.eyeColor),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          'Update Profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          // Implement profile update functionality
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          'Unsubscribe',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Confirm Unsubscribe'),
                              content: Text(
                                'Are you sure you want to unsubscribe? This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(false),
                                ),
                                TextButton(
                                  child: Text(
                                    'Unsubscribe',
                                    style: TextStyle(color: Colors.red[400]),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(true),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            await authService.unsubscribe();
                            Navigator.pushReplacementNamed(context, '/');
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}