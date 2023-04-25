// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../lib/widget/plant_recogniser.dart';
import '../lib/classifier/classifier.dart';

class MockImagePicker extends Mock implements ImagePicker {}

class MockClassifier extends Mock implements Classifier {}

void main() {
  late PlantRecogniser plantRecogniser;
  late MockImagePicker mockImagePicker;
  late MockClassifier mockClassifier;

  setUp(() {
    plantRecogniser = PlantRecogniser();
    mockImagePicker = MockImagePicker();
    mockClassifier = MockClassifier();
  });

  testWidgets('tap on "Take a photo" button should call ImagePicker.pickImage with camera source', (WidgetTester tester) async {
    // Arrange
    final source = ImageSource.camera;
    when(mockImagePicker.pickImage(source: source)).thenAnswer((_) async => null);

    // Act
    await tester.pumpWidget(plantRecogniser);
    await tester.tap(find.widgetWithText(TextButton, 'Take a photo'));
    await tester.pumpAndSettle();

    // Assert
    verify(mockImagePicker.pickImage(source: source)).called(1);
  });

  testWidgets('tap on "Pick from gallery" button should call ImagePicker.pickImage with gallery source', (WidgetTester tester) async {
    // Arrange
    final source = ImageSource.gallery;
    when(mockImagePicker.pickImage(source: source)).thenAnswer((_) async => null);

    // Act
    await tester.pumpWidget(plantRecogniser);
    await tester.tap(find.widgetWithText(TextButton, 'Pick from gallery'));
    await tester.pumpAndSettle();

    // Assert
    verify(mockImagePicker.pickImage(source: source)).called(1);
  });

  testWidgets('loadClassifier() should load classifier with correct file names', (WidgetTester tester) async {
    // Arrange
    final labelsFileName = 'assets/labels.txt';
    final modelFileName = 'model_unquant.tflite';
    final classifier = Classifier();
    when(mockClassifier.loadWith(labelsFileName: labelsFileName, modelFileName: modelFileName)).thenAnswer((_) async => classifier);

    // Act
    await tester.pumpWidget(plantRecogniser);
    await plantRecogniser._loadClassifier();

    // Assert
    expect(plantRecogniser._classifier, equals(classifier));
    verify(mockClassifier.loadWith(labelsFileName: labelsFileName, modelFileName: modelFileName)).called(1);
  });

  testWidgets('on _classifyImage(), set analyzing flag to true and call classifier.predict', (WidgetTester tester) async {
    // Arrange
    final imageFilePath = path.join((await getTemporaryDirectory()).path, 'test.png');
    final imageFile = File(imageFilePath)..createSync();
    final classifierResult = ClassifierResult(label: 'label', accuracy: 0.8);
    when(mockClassifier.predict(imageFile)).thenAnswer((_) async => classifierResult);

    // Act
    await tester.pumpWidget(plantRecogniser);
    await plantRecogniser._classifyImage(imageFile);

    // Assert
    expect(plantRecogniser._isAnalyzing, isTrue);
    expect(plantRecogniser._resultStatus, equals(_ResultStatus.notStarted));
    expect(plantRecogniser._plantLabel, equals(''));
    expect(plantRecogniser._accuracy, equals(0.0));

    await Future.delayed(Duration(milliseconds: 500));

    expect(plantRecogniser._
