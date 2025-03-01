import 'package:flutter_riverpod/flutter_riverpod.dart';

// Example: A simple provider to manage user authentication state
final authProvider = StateProvider<bool>((ref) => false);
