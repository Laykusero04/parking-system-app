import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CameraScreen extends StatefulWidget {
  final bool isAdmin;
  final String vehicleType;
  final bool isParkIn;

  const CameraScreen({
    Key? key,
    required this.vehicleType,
    required this.isParkIn,
    required this.isAdmin,
  }) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  final TextEditingController _plateNumberController = TextEditingController();
  final TextRecognizer _textRecognizer = TextRecognizer();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras![0], ResolutionPreset.high);
    await _controller!.initialize();
    setState(() {});
  }

  Future<void> _captureAndProcessImage() async {
    if (!_controller!.value.isInitialized) {
      return;
    }
    final image = await _controller!.takePicture();

    final recognizedText = await _processImageWithMLKit(image.path);
    setState(() {
      _plateNumberController.text = recognizedText ?? '';
    });
  }

  Future<String?> _processImageWithMLKit(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText =
        await _textRecognizer.processImage(inputImage);

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        if (line.text.length >= 5 &&
            line.text.length <= 8 &&
            RegExp(r'^[A-Z0-9]+$').hasMatch(line.text)) {
          return line.text;
        }
      }
    }
    return null;
  }

  Future<void> _savePlateNumber() async {
    final plateNumber = _plateNumberController.text.trim();
    if (plateNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please scan a plate number first')),
      );
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      if (widget.isParkIn) {
        // Check if there's already a parked vehicle with this plate number
        final existingRecord = await firestore
            .collection('plate_numbers')
            .where('plate_number', isEqualTo: plateNumber)
            .where('time_out', isNull: true)
            .get();

        if (existingRecord.docs.isNotEmpty) {
          throw Exception('This vehicle is already parked');
        }

        await firestore.collection('plate_numbers').add({
          'plate_number': plateNumber,
          'vehicle_type': widget.vehicleType,
          'time_in': FieldValue.serverTimestamp(),
          'time_out': null,
          'date': FieldValue.serverTimestamp(),
        });
      } else {
        // Find the document with matching plate number and update it
        QuerySnapshot querySnapshot = await firestore
            .collection('plate_numbers')
            .where('plate_number', isEqualTo: plateNumber)
            .where('time_out', isNull: true)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          await querySnapshot.docs.first.reference.update({
            'time_out': FieldValue.serverTimestamp(),
          });
        } else {
          throw Exception('No matching park-in record found');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                widget.isParkIn ? 'Park-in recorded' : 'Park-out recorded')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    _plateNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isParkIn ? 'Park In' : 'Park Out'),
        backgroundColor: widget.isParkIn ? Colors.green : Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            Positioned.fill(
              child: CameraPreview(_controller!),
            )
          else
            const Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 1.7,
            child: Container(
              color: Colors.white,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _plateNumberController,
                    decoration: InputDecoration(
                      labelText: 'Plate Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Vehicle Type: ${widget.vehicleType}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _savePlateNumber,
                    child: Text(widget.isParkIn ? 'Park In' : 'Park Out'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _captureAndProcessImage,
        child: const Icon(Icons.camera),
      ),
    );
  }
}
