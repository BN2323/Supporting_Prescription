import 'dart:io';

// Helper to reset test data before each test
void resetTestData() {
  final dataDir = Directory('data');
  if (dataDir.existsSync()) {
    dataDir.deleteSync(recursive: true);
  }
  
  // Recreate empty data directory
  dataDir.createSync(recursive: true);
}

// Helper to create test files with sample data
void initializeTestData() {
  final dataDir = Directory('data');
  dataDir.createSync(recursive: true);
  
  // Create sequences file
  File('data/sequences.json').writeAsStringSync('''
{
  "doctor": 1,
  "patient": 1,
  "pharmacist": 1,
  "prescription": 1,
  "medication": 1,
  "renewal": 1,
  "dose": 1
}
''');
}