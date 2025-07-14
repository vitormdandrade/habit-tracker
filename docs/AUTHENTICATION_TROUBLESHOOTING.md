# Authentication Troubleshooting Guide

## Common Issues and Solutions

### 1. Firebase Configuration Issues

**Problem**: Authentication not working due to incorrect Firebase setup.

**Solutions**:
- Verify Firebase project configuration in `lib/firebase_options.dart`
- Ensure all platform configurations are properly set (not placeholder values)
- Check that Firebase Authentication is enabled in your Firebase console
- Verify that Email/Password and Google Sign-In providers are enabled

### 2. Authentication State Not Updating

**Problem**: UI doesn't update when user signs in/out.

**Solution**: The app now properly listens to authentication state changes using `AuthService.authStateChanges`.

### 3. User Data Not Loading

**Problem**: User signs in but their data doesn't load.

**Debugging Steps**:
1. Check console logs for authentication success messages
2. Verify user document exists in Firestore
3. Check Firestore security rules allow read access
4. Ensure user ID is properly retrieved

### 4. Network Connectivity Issues

**Problem**: Authentication fails due to network issues.

**Solutions**:
- Check internet connection
- Verify Firebase project is accessible
- Check if Firebase services are down

### 5. Google Sign-In Issues

**Problem**: Google Sign-In not working.

**Solutions**:
- Verify Google Sign-In is enabled in Firebase console
- Check that SHA-1 fingerprint is added to Android app configuration
- Ensure Google Services configuration file is properly set up

## Debugging Steps

### 1. Enable Debug Logging

The app now includes comprehensive logging. Check the console output for:
- Authentication attempts
- Success/failure messages
- User ID retrieval
- Firestore operations

### 2. Test Authentication Flow

1. Try signing in with a known valid account
2. Check if user document exists in Firestore
3. Verify data loading process
4. Test sign out functionality

### 3. Check Firebase Console

1. Go to Firebase Console
2. Navigate to Authentication > Users
3. Verify user accounts exist
4. Check Firestore Database for user documents

### 4. Verify Firestore Rules

Ensure your Firestore security rules allow authenticated users to read/write their data:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Testing Authentication

### Manual Testing Steps

1. **Fresh Installation**:
   - Install app
   - Complete onboarding
   - Try to sign in with existing account

2. **Existing User**:
   - Open app
   - Click "Already a user? Click here to log in"
   - Enter credentials
   - Verify data loads

3. **Google Sign-In**:
   - Try Google Sign-In option
   - Verify account creation/login works

### Automated Testing

Run the authentication tests:
```bash
flutter test test/auth_test.dart
```

## Common Error Messages

- **"No user found with this email address"**: User doesn't exist in Firebase
- **"Wrong password provided"**: Incorrect password
- **"Network error"**: Connectivity issues
- **"Too many requests"**: Rate limiting, wait and try again
- **"Operation not allowed"**: Authentication provider not enabled

## Getting Help

If issues persist:

1. Check the console logs for detailed error messages
2. Verify Firebase project configuration
3. Test with a fresh Firebase project
4. Ensure all dependencies are up to date

## Recent Fixes Applied

1. **Added Authentication State Listening**: App now properly responds to auth state changes
2. **Enhanced Error Handling**: Better error messages and debugging
3. **Improved Logging**: Comprehensive logging for troubleshooting
4. **Fixed UI Updates**: UI now updates when user signs in/out
5. **Better User State Management**: Proper tracking of current user state 