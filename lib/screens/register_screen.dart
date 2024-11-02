import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController birthTimeController = TextEditingController();
  final TextEditingController birthLocationController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController ethnicityController = TextEditingController();
  final TextEditingController eyeColorController = TextEditingController();
  final TextEditingController mothersMaidenNameController = TextEditingController();
  final TextEditingController childhoodFriendController = TextEditingController();
  final TextEditingController childhoodPetController = TextEditingController();
  final TextEditingController securityQuestionController = TextEditingController();

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    TextInputType? keyboardType,
    IconData? icon,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon ?? Icons.person_outline),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

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
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    height: 200, // Adjust this value based on your logo size
                    width: 200,  // Adjust this value based on your logo size
                    child: Image.asset(
                      'lib/images/1.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),

                  // Personal Information
                  Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: fullNameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                  ),
                  _buildTextField(
                    controller: emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    icon: Icons.email_outlined,
                  ),
                  _buildTextField(
                    controller: passwordController,
                    label: 'Password',
                    isPassword: true,
                    icon: Icons.lock_outline,
                  ),

                  // Birth Information
                  SizedBox(height: 24),
                  Text(
                    'Birth Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: dobController,
                    label: 'Date of Birth',
                    icon: Icons.calendar_today,
                  ),
                  _buildTextField(
                    controller: birthTimeController,
                    label: 'Time of Birth',
                    icon: Icons.access_time,
                  ),
                  _buildTextField(
                    controller: birthLocationController,
                    label: 'Location of Birth',
                    icon: Icons.location_on_outlined,
                  ),

                  // Physical Characteristics
                  SizedBox(height: 24),
                  Text(
                    'Physical Characteristics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: bloodGroupController,
                    label: 'Blood Group',
                    icon: Icons.water_drop_outlined,
                  ),
                  _buildTextField(
                    controller: sexController,
                    label: 'Sex',
                    icon: Icons.wc,
                  ),
                  _buildTextField(
                    controller: heightController,
                    label: 'Height',
                    icon: Icons.height,
                  ),
                  _buildTextField(
                    controller: ethnicityController,
                    label: 'Ethnicity',
                    icon: Icons.people_outline,
                  ),
                  _buildTextField(
                    controller: eyeColorController,
                    label: 'Eye Color',
                    icon: Icons.remove_red_eye_outlined,
                  ),

                  // Security Questions
                  SizedBox(height: 24),
                  Text(
                    'Security Questions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: mothersMaidenNameController,
                    label: "Mother's Maiden Name",
                    icon: Icons.family_restroom,
                  ),
                  _buildTextField(
                    controller: childhoodFriendController,
                    label: "Childhood Best Friend's Name",
                    icon: Icons.group_outlined,
                  ),
                  _buildTextField(
                    controller: childhoodPetController,
                    label: "Childhood Pet's Name",
                    icon: Icons.pets,
                  ),
                  _buildTextField(
                    controller: securityQuestionController,
                    label: 'Your Own Security Question',
                    icon: Icons.security,
                  ),

                  // Register Button
                  SizedBox(height: 32),
                  SizedBox(
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
                        'Create Account',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        final user = User(
                          fullName: fullNameController.text,
                          email: emailController.text,
                          dateOfBirth: dobController.text,
                          timeOfBirth: birthTimeController.text,
                          locationOfBirth: birthLocationController.text,
                          bloodGroup: bloodGroupController.text,
                          sex: sexController.text,
                          height: heightController.text,
                          ethnicity: ethnicityController.text,
                          eyeColor: eyeColorController.text,
                          mothersMaidenName: mothersMaidenNameController.text,
                          childhoodFriend: childhoodFriendController.text,
                          childhoodPet: childhoodPetController.text,
                          securityQuestion: securityQuestionController.text,
                        );

                        final success = await authService.register(user, passwordController.text);
                        if (success) {
                          Navigator.pushReplacementNamed(context, '/profile');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Registration failed'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}