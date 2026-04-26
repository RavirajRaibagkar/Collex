class AppConstants {
  // Supabase
  static const String supabaseUrl = 'https://avuhxjfrezteebydlljk.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF2dWh4amZyZXp0ZWVieWRsbGprIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY4NTY4MTAsImV4cCI6MjA5MjQzMjgxMH0.YoRqxEHwuSfJ5RtY5coFs0qEE0XeBZlAD0ChwhnKm8I';

  // College domain restriction
  static const String collegeDomain = '@vit.edu'; // Change to your college domain

  // Categories
  static const List<String> categories = [
    'All',
    'Books',
    'Electronics',
    'Hostel Items',
    'Clothing',
    'Sports',
    'Stationery',
    'Others',
  ];

  // Conditions
  static const List<String> conditions = ['New', 'Good', 'Used'];

  // Table names
  static const String usersTable = 'users';
  static const String itemsTable = 'items';
  static const String requestsTable = 'requests';
  static const String messagesTable = 'messages';
  static const String favoritesTable = 'favorites';

  // Storage bucket
  static const String itemImagesBucket = 'item-images';
}
