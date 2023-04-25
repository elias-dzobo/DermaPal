// ignore_for_file: lines_longer_than_80_chars, unused_element

import 'package:flutter/material.dart';
import 'widget/plant_recogniser.dart';

class Info extends StatelessWidget {
  const Info({super.key});

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Derma', textAlign: TextAlign.left),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            Text(
              'Save your Skin!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Use DermaPal',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            //const SizedBox(height: 32.0),
            const SizedBox(height: 32.0),
            Text(
              'How it works!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            Container(
              height: 100.0,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[400]!,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButtonColumn(color, Icons.add_a_photo_outlined, 'Take a Picture'),
                    _buildButtonColumn(color, Icons.cloud_upload_outlined, 'Upload the photo'),
                    _buildButtonColumn(color, Icons.health_and_safety_outlined, 'Get Results'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            Text(
              'About DermaPal',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'DermaPal is your go-to AI Dermatologist with over 3 weeks of experience. '
                  'DermaPal is trained with over 16,000 images of several skin diseases ranging from Acne to Psoriasis and even Melanoma. '
                  'DermaPal is not meant to be a replacement for professional dermatological diagnosis but rather a supplement to actual medical diagnosis and first aid relief. '
                  'DermaPal wishes that patients skin conditions do not worsen and therefore provides first aid remedies.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            //const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (context) => const PlantRecogniser()),
                );
              },
              child: const Text('Take Picture'),
            ),
            const SizedBox(height: 250.0),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonSection(BuildContext context, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButtonColumn(color, Icons.add_a_photo_outlined, 'Take a Picture'),
        _buildButtonColumn(color, Icons.cloud_upload_outlined, 'Upload the photo'),
        _buildButtonColumn(color, Icons.health_and_safety_outlined, 'Get Results'),
      ],
    );
  } 
 
  Column _buildButtonColumn(Color color, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

}
