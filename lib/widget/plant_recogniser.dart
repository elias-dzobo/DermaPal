// Copyright (c) 2022 Kodeco LLC

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical
// or instructional purposes related to programming, coding,
// application development, or information technology.  Permission for such use,
// copying, modification, merger, publication, distribution, sublicensing,
// creation of derivative works, or sale is expressly withheld.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// ignore_for_file: lines_longer_than_80_chars, prefer_final_locals, omit_local_variable_types

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../classifier/classifier.dart';
import '../styles.dart';
import 'plant_photo_view.dart';

const _labelsFileName = 'assets/labels.txt';
const _modelFileName = 'model_unquant.tflite';


class PlantRecogniser extends StatefulWidget {
  const PlantRecogniser({super.key});

  @override
  State<PlantRecogniser> createState() => _PlantRecogniserState();
}

enum _ResultStatus {
  notStarted,
  notFound,
  found,
}

class _PlantRecogniserState extends State<PlantRecogniser> {
  bool _isAnalyzing = false;
  final picker = ImagePicker();
  File? _selectedImageFile;

  // Result
  _ResultStatus _resultStatus = _ResultStatus.notStarted;
  String _plantLabel = ''; // Name of Error Message
  double _accuracy = 0.0;

  late Classifier? _classifier;

  @override
  void initState() {
    super.initState();
    _loadClassifier();
  }

  Future<void> _loadClassifier() async {
    debugPrint(
      'Start loading of Classifier with '
      'labels at $_labelsFileName, '
      'model at $_modelFileName',
    );

    final classifier = await Classifier.loadWith(
      labelsFileName: _labelsFileName,
      modelFileName: _modelFileName,
    );
    _classifier = classifier;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const Spacer(),
          const SizedBox(height: 25.0),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: _buildTitle(context),
          ),
          const SizedBox(height: 20),
          _buildPhotolView(),
          const SizedBox(height: 10),
          _buildResultView(),
          const Spacer(flex: 5),
          _buildPickPhotoButton(
            title: 'Take a photo',
            source: ImageSource.camera,
          ),
          const SizedBox(height: 8.0),
          _buildPickPhotoButton(
            title: 'Pick from gallery',
            source: ImageSource.gallery,
          ),
          //const Spacer(),
          const SizedBox(height: 20.0)
        ],
      ),
    );
  }

  Widget _buildPhotolView() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
      alignment: AlignmentDirectional.center,
      children: [
        PlantPhotoView(file: _selectedImageFile),
        _buildAnalyzingText(),
      ],
    ),
    ); 
  }

  Widget _buildAnalyzingText() {
    if (!_isAnalyzing) {
      return const SizedBox.shrink();
    }
    return const Text('Analyzing...', style: kAnalyzingTextStyle);
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'Skin Disease',
      style: Theme.of(context).textTheme.headlineLarge,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPickPhotoButton({
    required ImageSource source,
    required String title,
  }) {
    return Container(
      decoration: BoxDecoration( 
        borderRadius: BorderRadius.circular(10),
        color: kColorLightYellow
      ),
      child: TextButton(
      onPressed: () => _onPickPhoto(source),
      child: Container(
        width: 300,
        height: 50,
        child: Center(
            child: Text(title,
                style: Theme.of(context).textTheme.bodyMedium)),
      ),
    )
    ); 
  }

  void _setAnalyzing(bool flag) {
    setState(() {
      _isAnalyzing = flag;
    });
  }

  void _onPickPhoto(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) {
      return;
    }

    final imageFile = File(pickedFile.path);
    setState(() {
      _selectedImageFile = imageFile; 
    });

    _analyzeImage(imageFile);
  }

  void _analyzeImage(File image) {
    _setAnalyzing(true);

    final imageInput = img.decodeImage(image.readAsBytesSync())!;

    final resultCategory = _classifier!.predict(imageInput);

    final result = resultCategory.score >= 0.8
        ? _ResultStatus.found
        : _ResultStatus.notFound;
    final plantLabel = resultCategory.label;
    final accuracy = resultCategory.score;

    _setAnalyzing(false);

    setState(() {
      _resultStatus = result;
      _plantLabel = plantLabel;
      _accuracy = accuracy;
    });
  }

  Widget _buildResultView() {
    var title = '';
    var result = '';

    Map<String, String> remedy = {
  'sarcoidosis': 'Corticosteroids, immunosuppressive drugs, and TNF-alpha inhibitors',
  'melanoma': 'Surgical removal of the cancerous tissue, along with additional therapies such as radiation therapy, immunotherapy, or targeted therapy',
  'neutrophilic_dermatoses': 'Systemic corticosteroids, dapsone, or other immunosuppressive medications. Topical treatments such as emollients and steroid creams may also be used to alleviate symptoms',
  'acne vulgaris': 'Topical treatments such as benzoyl peroxide, retinoids, or topical antibiotics, or systemic treatments such as oral antibiotics or hormonal therapy',
  'nematode infection': 'Albendazole, mebendazole, or ivermectin. Surgery may be necessary in some cases',
  'photodermatoses': 'Avoiding exposure to sunlight, wearing protective clothing and sunscreen, or taking medications such as antihistamines or corticosteroids',
  'allergic contact dermatitis': 'Treatment for allergic contact dermatitis typically involves identifying and avoiding the allergen that triggered the reaction, along with using topical corticosteroids or calcineurin inhibitors to reduce inflammation and relieve symptoms',
  'Fail to recognise': 'Fail to recognise',
  };

    if (_resultStatus == _ResultStatus.notFound) {
      title = 'Fail to recognise';
    } else if (_resultStatus == _ResultStatus.found) {
      title = _plantLabel;
      result = remedy[title]!;
    } else {
      title = '';
    }

    //
    var accuracyLabel = '';
    if (_resultStatus == _ResultStatus.found) {
      accuracyLabel = 'Accuracy: ${(_accuracy * 100).toStringAsFixed(2)}%';
    }

    return Column(
      children: [
        Text('Diagnosis: '+ title, style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.normal,
          decoration: TextDecoration.none,
          fontSize: 20,
        )),
        const SizedBox(height: 10),
        Text(accuracyLabel, style: kResultRatingTextStyle),

        Container(
          width: 300,
          height: 300,
          child: Column(children: [
            Text('Possible Treatment', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.left),
            const SizedBox(height: 5.0,),
            Text(result, softWrap: true, style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.left,
          ),
          ],) 
        )
        /* Padding(padding: EdgeInsets.only(top: 20),
        child: Text(result, softWrap: true, style: const TextStyle(
          fontSize: 10,
          
        ),
        textAlign: TextAlign.center,
        ),
        ) */
      ],
    );
  }
}
