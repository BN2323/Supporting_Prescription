import 'dart:io';


void resetTestData() {
  final dataDir = Directory('data');
  if (dataDir.existsSync()) {
    dataDir.deleteSync(recursive: true);
  }
  

  dataDir.createSync(recursive: true);
}


void initializeTestData() {
  final dataDir = Directory('data');
  dataDir.createSync(recursive: true);
  

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