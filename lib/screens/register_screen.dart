import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
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

  String? selectedBloodGroup;
  String? selectedGender;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isFormValid = false;
  bool _isLoading = false;

  final List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> genders = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    // Add listeners to all controllers to validate form
    emailController.addListener(_validateForm);
    fullNameController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);
    dobController.addListener(_validateForm);
    birthTimeController.addListener(_validateForm);
    birthLocationController.addListener(_validateForm);
    heightController.addListener(_validateForm);
    ethnicityController.addListener(_validateForm);
    eyeColorController.addListener(_validateForm);
    mothersMaidenNameController.addListener(_validateForm);
    childhoodFriendController.addListener(_validateForm);
    childhoodPetController.addListener(_validateForm);
    securityQuestionController.addListener(_validateForm);
  }

  @override
  void dispose() {
    // Remove listeners and dispose controllers
    emailController.removeListener(_validateForm);
    fullNameController.removeListener(_validateForm);
    passwordController.removeListener(_validateForm);
    confirmPasswordController.removeListener(_validateForm);
    dobController.removeListener(_validateForm);
    birthTimeController.removeListener(_validateForm);
    birthLocationController.removeListener(_validateForm);
    heightController.removeListener(_validateForm);
    ethnicityController.removeListener(_validateForm);
    eyeColorController.removeListener(_validateForm);
    mothersMaidenNameController.removeListener(_validateForm);
    childhoodFriendController.removeListener(_validateForm);
    childhoodPetController.removeListener(_validateForm);
    securityQuestionController.removeListener(_validateForm);

    emailController.dispose();
    fullNameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    dobController.dispose();
    birthTimeController.dispose();
    birthLocationController.dispose();
    heightController.dispose();
    ethnicityController.dispose();
    eyeColorController.dispose();
    mothersMaidenNameController.dispose();
    childhoodFriendController.dispose();
    childhoodPetController.dispose();
    securityQuestionController.dispose();

    super.dispose();
  }

  void _validateForm() {
    setState(() {
      // Email validation
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      bool isEmailValid = emailRegex.hasMatch(emailController.text);

      _emailError = !isEmailValid && emailController.text.isNotEmpty
          ? 'Please enter a valid email address'
          : null;

      // Password validation
      final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');
      bool isPasswordValid = passwordRegex.hasMatch(passwordController.text);
      bool doPasswordsMatch = passwordController.text == confirmPasswordController.text;

      _passwordError = !isPasswordValid && passwordController.text.isNotEmpty
          ? 'Password must be at least 8 characters with 1 uppercase letter and 1 number'
          : null;

      _confirmPasswordError = !doPasswordsMatch && confirmPasswordController.text.isNotEmpty
          ? 'Passwords do not match'
          : null;

      // Check if all required fields are filled
      _isFormValid = isEmailValid &&
          isPasswordValid &&
          doPasswordsMatch &&
          fullNameController.text.isNotEmpty &&
          dobController.text.isNotEmpty &&
          birthTimeController.text.isNotEmpty &&
          birthLocationController.text.isNotEmpty &&
          selectedBloodGroup != null &&
          selectedGender != null &&
          heightController.text.isNotEmpty &&
          ethnicityController.text.isNotEmpty &&
          eyeColorController.text.isNotEmpty &&
          mothersMaidenNameController.text.isNotEmpty &&
          childhoodFriendController.text.isNotEmpty &&
          childhoodPetController.text.isNotEmpty &&
          securityQuestionController.text.isNotEmpty;
    });
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
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
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        dropdownColor: Colors.grey[50],
        isExpanded: false,
        items: items.map((String item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (String? newValue) {
          onChanged(newValue);
          _validateForm();
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    TextInputType? keyboardType,
    IconData? icon,
    String? errorText,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: errorText != null
            ? Border.all(color: Colors.red.shade300, width: 1)
            : null,
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
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon ?? Icons.person_outline,
            color: errorText != null ? Colors.red.shade300 : null,
          ),
          labelStyle: TextStyle(
            color: errorText != null ? Colors.red.shade300 : null,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          errorText: errorText,
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 01, 01),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.grey[800]!,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        _validateForm();
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.grey[800]!,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        birthTimeController.text = picked.format(context);
        _validateForm();
      });
    }
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Container(
                        height: 200,
                        width: 200,
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
                        errorText: _emailError,
                      ),
                      _buildTextField(
                        controller: passwordController,
                        label: 'Password',
                        isPassword: true,
                        icon: Icons.lock_outline,
                        errorText: _passwordError,
                      ),
                      _buildTextField(
                        controller: confirmPasswordController,
                        label: 'Confirm Password',
                        isPassword: true,
                        icon: Icons.lock_outline,
                        errorText: _confirmPasswordError,
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
                        readOnly: true,
                        onTap: () => _selectDate(context),
                      ),
                      _buildTextField(
                        controller: birthTimeController,
                        label: 'Time of Birth',
                        icon: Icons.access_time,
                        readOnly: true,
                        onTap: () => _selectTime(context),
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
                      _buildDropdown(
                        label: 'Blood Group',
                        value: selectedBloodGroup,
                        items: bloodGroups,
                        onChanged: (value) => setState(() => selectedBloodGroup = value),
                        icon: Icons.water_drop_outlined,
                      ),
                      _buildDropdown(
                        label: 'Gender',
                        value: selectedGender,
                        items: genders,
                        onChanged: (value) => setState(() => selectedGender = value),
                        icon: Icons.wc,
                      ),
                      _buildTextField(
                        controller: heightController,
                        label: 'Height (cm)',
                        icon: Icons.height,
                        keyboardType: TextInputType.number,
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
                    label: 'Favorite Movie Title',
                    icon: Icons.movie_outlined,
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
                          bloodGroup: selectedBloodGroup ?? '',
                          sex: selectedGender ?? '',
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
    )
    );
  }
}