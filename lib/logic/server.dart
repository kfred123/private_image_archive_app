import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:private_image_archive_app/logging.dart';

class ServerAccess {
  final String ENDPOINT_ADD_IMAGE = "/rest/images";
  final String ENDPOINT_GET_IMAGES = "/rest/images";
  String _baseUrl;

  ServerAccess(String baseUrl) {
    _baseUrl = baseUrl;
  }

  Future<bool> uploadImage(List<int> imageData) async {
    bool result = false;
    var request = http.MultipartRequest("POST", Uri.http(_baseUrl, ENDPOINT_ADD_IMAGE));
    request.fields["fileName"] = "test";
    request.files.add(http.MultipartFile.fromBytes("image", imageData));
    try {
      var response = await request.send();
      if(response.statusCode == HttpStatus.ok) {
        result = true;
      } else {
        Logging.logError(response.statusCode.toString());
      }
    } catch(exc) {
        Logging.logError(exc.toString());
    }
    return result;
  }
}