import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

pickImage(ImageSource source) async {
  requestPermissions();
  final ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: source);
  if (file != null) {
    return file.readAsBytes();
  } else {
    print('No image selected');
  }
}

Future<void> requestPermissions() async {
  if (await Permission.camera.request().isGranted &&
      await Permission.storage.request().isGranted) {
    // Permissions granted
  } else {
    // Permissions denied
  }
}
