import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  XFile? imageFile;
  TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras!.isNotEmpty) {
      _controller = CameraController(cameras![0], ResolutionPreset.high);
      await _controller?.initialize();
      if (!mounted) return;
      setState(() {});
    }
  }

  void _captureImage() async {
    if (_controller != null && _controller!.value.isInitialized) {
      imageFile = await _controller?.takePicture();
      setState(() {});
    }
  }

  void _sendData() async {
    if (imageFile != null) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://flutter-sandbox.free.beeceptor.com/upload_photo/'),
      );
      request.fields['comment'] = _commentController.text;
      request.files
          .add(await http.MultipartFile.fromPath('photo', imageFile!.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        print('Photo uploaded successfully');
      } else {
        print('Failed to upload photo');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Photo Capture App')),
      body: Column(
        children: [
          Expanded(
            child: _controller == null || !_controller!.value.isInitialized
                ? Center(child: CircularProgressIndicator())
                : CameraPreview(_controller!),
          ),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(hintText: 'Enter your comment'),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: _captureImage,
                child: Text('Capture Image'),
              ),
              ElevatedButton(
                onPressed: _sendData,
                child: Text('Send Data'),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
