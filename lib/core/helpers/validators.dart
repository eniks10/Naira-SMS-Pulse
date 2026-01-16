class Validators {
  static String? validateEmail(String? value) {
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (value == null || value.isEmpty) {
      return 'Enter your Email!';
    }
    if (emailRegex.hasMatch(value)) {
      return null;
    } else {
      return 'Enter a valid Email';
    }
  }

  static String? validateFullName(String? value) {
    final RegExp fullNameRegex = RegExp(r"^[a-zA-Z]+([ '-][a-zA-Z]+)*$");
    if (value == null || value.isEmpty) {
      return 'Enter your Full name!';
    }
    if (fullNameRegex.hasMatch(value)) {
      return null;
    } else {
      return 'Enter a valid name!';
    }
  }

  static String? validatePassword(String? value) {
    final RegExp strongPasswordRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
    );
    if (value == null || value.isEmpty) return 'Enter your Password';

    if (strongPasswordRegex.hasMatch(value)) {
      return null;
    } else {
      return '8 characters,upper & lowercase letters,a number and a special character';
    }
  }

  static String? validateCategoryCreation(String? value) {
    final RegExp fullNameRegex = RegExp(r"^[a-zA-Z]+([ '-][a-zA-Z]+)*$");
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    // 2. Check length (trim() removes whitespace)
    if (value.trim().length < 3) {
      return 'Must be at least 3 letters';
    }

    return null; // Valid
  }
}
