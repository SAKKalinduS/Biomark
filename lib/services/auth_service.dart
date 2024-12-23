import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import './mongodb_helper.dart';
import './sqlite_helper.dart';
import './encryption_helper.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<void> init() async {
    // Initialize MongoDB and SQLite
    await MongoDBHelper.instance.initialize();
    await SQLiteHelper.instance.database;
  }

  String _hashPassword(String password, String salt) {
    var bytes = utf8.encode(password + salt);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _generateSalt() {
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));  // Generates a list of 16 random integers
    return base64Url.encode(salt);  // Encodes the list of bytes into a base64 string
  }

  String generateUniqueId() {
    final now = DateTime.now();
    return '${now.millisecondsSinceEpoch}'; // Unique ID based on the current timestamp
  }

  Future<bool> register(User user, String password) async {
    try {
      // Generate a unique salt for the user
      final uniqueId = generateUniqueId();
      final salt = _generateSalt();
      final passwordHash = _hashPassword(password, salt);
      print('1');
      // Encrypt sensitive security data for SQLite storage
      final encryptedSecurityData = {
        'fullName': EncryptionHelper.encryptData(user.fullName),
        'dateOfBirth': EncryptionHelper.encryptData(user.dateOfBirth),
        'mothersMaidenName': EncryptionHelper.encryptData(user.mothersMaidenName),
        'childhoodFriend': EncryptionHelper.encryptData(user.childhoodFriend),
        'childhoodPet': EncryptionHelper.encryptData(user.childhoodPet),
        'securityQuestion': EncryptionHelper.encryptData(user.securityQuestion),
        'email': EncryptionHelper.encryptData(user.email),
      };
      print('2');
      // Insert personal data into MongoDB
      final mongoResult = await MongoDBHelper.instance.insertOne('users', {
        'dataSampleId': uniqueId,
        'dateOfBirth': user.dateOfBirth,
        'timeOfBirth': user.timeOfBirth,
        'locationOfBirth': user.locationOfBirth,
        'bloodGroup': user.bloodGroup,
        'sex': user.sex,
        'height': user.height,
        'ethnicity': user.ethnicity,
        'eyeColor': user.eyeColor,
      });
      print('3');
      print(mongoResult != null);
      print(mongoResult?.isSuccess);
      print(mongoResult?.id.toString());

      // Store encrypted data in SQLite
      if (mongoResult != null && mongoResult.isSuccess) {
        await SQLiteHelper.instance.insert('Users', {
          'id': EncryptionHelper.encryptData(uniqueId),
          'fullName': encryptedSecurityData['fullName'],
          'dateOfBirth': encryptedSecurityData['dateOfBirth'],
          'mothersMaidenName': encryptedSecurityData['mothersMaidenName'],
          'childhoodFriend': encryptedSecurityData['childhoodFriend'],
          'childhoodPet': encryptedSecurityData['childhoodPet'],
          'securityQuestion': encryptedSecurityData['securityQuestion'],
          'email': encryptedSecurityData['email'],
          'passwordHash': passwordHash,
          'salt': salt,
        });
        print('4');
        user.id = uniqueId;
        _currentUser = user;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      // Fetch user from SQLite (encrypted email)
      final localUser = await SQLiteHelper.instance.query(
          'Users',
          where: 'email = ?',
          whereArgs: [EncryptionHelper.encryptData(email)]
      );

      if (localUser.isNotEmpty) {
        final user = localUser.first;

        // Check if passwordHash and salt are non-null
        final passwordHash = user['passwordHash'] as String?;
        final salt = user['salt'] as String?;
        final encryptedId = user['id'] as String?;

        if (passwordHash != null && salt != null && encryptedId != null) {
          // Hash the entered password with the stored salt
          final hashedInputPassword = _hashPassword(password, salt);


          // Validate the password
          if (passwordHash == hashedInputPassword) {
            final uniqueId = EncryptionHelper.decryptData(encryptedId);
            print(uniqueId);
            // Fetch the user data from MongoDB
            final mongoUser = await MongoDBHelper.instance.findOne(
                'users',
                where.eq('dataSampleId', uniqueId)
            );

            print(mongoUser);

            if (mongoUser != null) {
              _currentUser = User.fromJson({
                ...mongoUser,
                ...{
                  'id': user['id'] != null
                      ? EncryptionHelper.decryptData(user['id'])
                      : 'Unknown',
                  'fullName': user['fullName'] != null
                      ? EncryptionHelper.decryptData(user['fullName'])
                      : 'Unknown',
                  'email': user['email'] != null
                      ? EncryptionHelper.decryptData(user['email'])
                      : 'Unknown',
                  'mothersMaidenName': user['mothersMaidenName'] != null
                      ? EncryptionHelper.decryptData(user['mothersMaidenName'])
                      : 'Unknown',
                  'childhoodFriend': user['childhoodFriend'] != null
                      ? EncryptionHelper.decryptData(user['childhoodFriend'])
                      : 'Unknown',
                  'childhoodPet': user['childhoodPet'] != null
                      ? EncryptionHelper.decryptData(user['childhoodPet'])
                      : 'Unknown',
                  'securityQuestion': user['ownQuestionAnswer'] != null
                      ? EncryptionHelper.decryptData(user['ownQuestionAnswer'])
                      : 'Unknown',
                }
              });
              print(currentUser);
              notifyListeners();
              return true;
            }
          }
        } else {
          print('Login error: missing passwordHash or salt');
        }
      }

      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> unsubscribe() async {
    if (_currentUser == null) return false;

    try {
      final userId = _currentUser?.id;
      print(userId);
      if (userId == null) {
        print('Unsubscribe error: User ID is null');
        return false;
      }

      // Delete from MongoDB
      final mongoResult = await MongoDBHelper.instance.deleteOne(
          'users',
          where.eq('dataSampleId', userId)
      );
      print(mongoResult != null && mongoResult.isSuccess);
      if (mongoResult != null && mongoResult.isSuccess) {
        // Delete from SQLite
        await SQLiteHelper.instance.delete(
            'Users',
            'id = ?',
            [EncryptionHelper.encryptData(userId)]
        );

        _currentUser = null;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      print('Unsubscribe error: $e');
      return false;
    }
  }

  Future<bool> recoverAccount(String fullName, String dateOfBirth, List<String> securityAnswers) async {
    try {
      final user = await MongoDBHelper.instance.findOne('users',
          where.eq('fullName', fullName).eq('dateOfBirth', dateOfBirth));

      if (user != null) {
        final localUser = await SQLiteHelper.instance.query('Users', where: 'id = ?', whereArgs: [user['_id'].toString()]);

        if (localUser.isNotEmpty) {
          final securityData = jsonDecode(localUser.first['securityData'] as String);

          int correctAnswers = 0;
          if (securityAnswers[0] == EncryptionHelper.decryptData(securityData['mothersMaidenName'])) correctAnswers++;
          if (securityAnswers[1] == EncryptionHelper.decryptData(securityData['childhoodFriend'])) correctAnswers++;
          if (securityAnswers[2] == EncryptionHelper.decryptData(securityData['childhoodPet'])) correctAnswers++;
          if (securityAnswers[3] == EncryptionHelper.decryptData(securityData['securityQuestion'])) correctAnswers++;

          if (correctAnswers >= 2) {
            _currentUser = User.fromJson(user);
            notifyListeners();
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      print('Account recovery error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> changeEmail(String newEmail, String currentPassword) async {
    try {
      if (_currentUser == null) {
        return {
          'success': false,
          'error': 'No user is currently logged in'
        };
      }

      // Fetch current user data from SQLite to verify password
      final localUser = await SQLiteHelper.instance.query(
          'Users',
          where: 'id = ?',
          whereArgs: [_currentUser!.id != null ? EncryptionHelper.encryptData(_currentUser!.id!) : '']  // Check for null and use empty string if null
      );

      if (localUser.isEmpty) {
        return {
          'success': false,
          'error': 'User data not found'
        };
      }

      final userData = localUser.first;
      final storedPasswordHash = userData['passwordHash'] as String;
      final salt = userData['salt'] as String;

      if (storedPasswordHash.isEmpty || salt.isEmpty) {
        return {
          'success': false,
          'error': 'Password verification failed'
        };
      }

      // Verify current password
      final hashedInputPassword = _hashPassword(currentPassword, salt);
      if (hashedInputPassword != storedPasswordHash) {
        return {
          'success': false,
          'error': 'Current password is incorrect'
        };
      }

      // Encrypt new email
      final encryptedNewEmail = EncryptionHelper.encryptData(newEmail);

      // Update email in SQLite
      await SQLiteHelper.instance.update(
          'Users',
          {'email': encryptedNewEmail},
          'id = ?',
          [_currentUser!.id != null ? EncryptionHelper.encryptData(_currentUser!.id!) : '']  // Check for null and use empty string if null
      );

      // Update current user object
      _currentUser!.email = newEmail;
      notifyListeners();

      return {
        'success': true,
        'error': null
      };
    } catch (e) {
      print('Change email error: $e');
      return {
        'success': false,
        'error': 'Failed to change email: ${e.toString()}'
      };
    }
  }

  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    try {
      // Ensure the user is logged in
      if (_currentUser == null) {
        return {
          'success': false,
          'error': 'No user is currently logged in'
        };
      }

      // Fetch the current user data
      final localUser = await SQLiteHelper.instance.query(
          'Users',
          where: 'id = ?',
          whereArgs: [_currentUser!.id != null ? EncryptionHelper.encryptData(_currentUser!.id!) : '']  // Use encrypted user ID
      );

      if (localUser.isEmpty) {
        return {
          'success': false,
          'error': 'User data not found'
        };
      }

      final userData = localUser.first;
      final storedPasswordHash = userData['passwordHash'] as String;
      final salt = userData['salt'] as String;

      // Verify the current password
      final hashedCurrentPassword = _hashPassword(currentPassword, salt);
      if (hashedCurrentPassword != storedPasswordHash) {
        return {
          'success': false,
          'error': 'Current password is incorrect'
        };
      }

      // Generate a new salt and hash for the new password
      final newSalt = _generateSalt();
      final newHashedPassword = _hashPassword(newPassword, newSalt);

      // Update the password and salt
      await SQLiteHelper.instance.update(
          'Users',
          {
            'passwordHash': newHashedPassword,
            'salt': newSalt
          },
          'id = ?',
          [_currentUser!.id != null ? EncryptionHelper.encryptData(_currentUser!.id!) : '']  // Use encrypted user ID
      );

      return {
        'success': true,
        'error': null
      };
    } catch (e) {
      print('Change password error: $e');
      return {
        'success': false,
        'error': 'Failed to change password: ${e.toString()}'
      };
    }
  }

  Future<Map<String, dynamic>> verifySecurityQuestions({required String email, required String mothersMaidenName, required String childhoodFriend, required String childhoodPet, required String securityQuestion,}) async {
    try {
      //find the user by email
      final encryptedEmail = EncryptionHelper.encryptData(email);
      final localUser = await SQLiteHelper.instance.query(
        'Users',
        where: 'email = ?',
        whereArgs: [encryptedEmail],
      );

      if (localUser.isEmpty) {
        return {
          'success': false,
          'errors': {
            'email': 'No account found with this email address'
          }
        };
      }

      final userData = localUser.first;

      // Decrypt stored security answers
      final storedMothersMaidenName = EncryptionHelper.decryptData(userData['mothersMaidenName'] as String);
      final storedChildhoodFriend = EncryptionHelper.decryptData(userData['childhoodFriend'] as String);
      final storedChildhoodPet = EncryptionHelper.decryptData(userData['childhoodPet'] as String);
      final storedSecurityQuestion = EncryptionHelper.decryptData(userData['securityQuestion'] as String);

      // Convert all answers to lowercase
      final normalizedInput = {
        'mothersMaidenName': mothersMaidenName.trim().toLowerCase(),
        'childhoodFriend': childhoodFriend.trim().toLowerCase(),
        'childhoodPet': childhoodPet.trim().toLowerCase(),
        'securityQuestion': securityQuestion.trim().toLowerCase(),
      };

      final normalizedStored = {
        'mothersMaidenName': storedMothersMaidenName.trim().toLowerCase(),
        'childhoodFriend': storedChildhoodFriend.trim().toLowerCase(),
        'childhoodPet': storedChildhoodPet.trim().toLowerCase(),
        'securityQuestion': storedSecurityQuestion.trim().toLowerCase(),
      };

      // Track individual field errors
      Map<String, String> fieldErrors = {};
      int correctAnswers = 0;

      // Check each field
      if (normalizedInput['mothersMaidenName'] == normalizedStored['mothersMaidenName']) {
        correctAnswers++;
      } else {
        fieldErrors['mothersMaidenName'] = 'Incorrect answer';
      }

      if (normalizedInput['childhoodFriend'] == normalizedStored['childhoodFriend']) {
        correctAnswers++;
      } else {
        fieldErrors['childhoodFriend'] = 'Incorrect answer';
      }

      if (normalizedInput['childhoodPet'] == normalizedStored['childhoodPet']) {
        correctAnswers++;
      } else {
        fieldErrors['childhoodPet'] = 'Incorrect answer';
      }

      if (normalizedInput['securityQuestion'] == normalizedStored['securityQuestion']) {
        correctAnswers++;
      } else {
        fieldErrors['securityQuestion'] = 'Incorrect answer';
      }


      if (correctAnswers == 4) {
        // Set the current user for the session
        final decryptedId = EncryptionHelper.decryptData(userData['id'] as String);

        // Fetch additional user data from MongoDB
        final mongoUser = await MongoDBHelper.instance.findOne(
            'users',
            where.eq('dataSampleId', decryptedId)
        );

        if (mongoUser != null) {
          _currentUser = User.fromJson({
            ...mongoUser,
            'id': decryptedId,
            'email': email,
            'fullName': EncryptionHelper.decryptData(userData['fullName'] as String),
            'mothersMaidenName': storedMothersMaidenName,
            'childhoodFriend': storedChildhoodFriend,
            'childhoodPet': storedChildhoodPet,
            'securityQuestion': storedSecurityQuestion,
          });

          notifyListeners();
          return {
            'success': true,
            'errors': null
          };
        }
      }

      // Return specific field errors
      return {
        'success': false,
        'errors': fieldErrors.isEmpty ? {
          'general': 'The provided answers do not match our records. Please try again.'
        } : fieldErrors
      };

    } catch (e) {
      print('Security questions verification error: $e');
      return {
        'success': false,
        'errors': {
          'general': 'An error occurred while verifying security questions. Please try again later.'
        }
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword(String newPassword) async {
    try {
      if (_currentUser == null) {
        return {
          'success': false,
          'error': 'No current user exist.'
        };
      }

      // Generate a new salt and hash the new password
      final newSalt = _generateSalt();
      final newHashedPassword = _hashPassword(newPassword, newSalt);

      // Update password
      await SQLiteHelper.instance.update(
          'Users',
          {
            'passwordHash': newHashedPassword,
            'salt': newSalt
          },
          'id = ?',
          [_currentUser!.id != null ? EncryptionHelper.encryptData(_currentUser!.id!) : '']
      );

      // final islogin=login(_currentUser!.email, newPassword);

      // if (islogin == true) {
      //   print("login successful!");
      // }

      return {
        'success': true,
        'error': null
      };
    } catch (e) {
      print('Reset password error: $e');
      return {
        'success': false,
        'error': 'Failed to reset password: ${e.toString()}'
      };
    }
  }

}
