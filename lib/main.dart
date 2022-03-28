import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tus_client/tus_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

//https://master.tus.io/files/

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String str = 'initial value';
  String link = 'link is not available';
  late TusClient _tusClient;

  void _launchURL(String _url) async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

  Future<void> uploadVideo() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery, maxDuration: const Duration(minutes: 3));
    if (video != null) {
      var accountName = 'amsstoragestage';
      var containerName = 'upload-5597a46a-7dd9-4d76-a42a-1427f00d03ee';
      var blobName = video.name;
      var sasTokenContainerLevel =
          "sv=2020-08-04&se=2022-03-28T20%3A03%3A38Z&sr=c&sp=rw&sig=M3ZFTaC6Sysws6r2bp0KUmZ3DXA5gQbWdQDZ6pMYi28%3D";
      var url =
          'https://$accountName.blob.core.windows.net/$containerName/$blobName?$sasTokenContainerLevel';
      var data = await File(blobName).readAsBytes();
      var dio = Dio();
      try {
        final response = await dio.put(url, data: data,
            onSendProgress: (int sent, int total) {
          if (total != -1) {
            print((sent / total * 100).toStringAsFixed(0) + "%");
          }
        },
            options: Options(headers: {
              'x-ms-blob-type': 'BlockBlob',
              'Content-Type': 'video/mp4',
            }));
        print(response.data);
      } catch (e) {
        print(e);
      }
      Response response = await dio.get(url);
      print(response.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              GestureDetector(
                onTap: () {
                  if (link.compareTo('Link is available') == 0) {
                    _launchURL(_tusClient.uploadUrl.toString());
                  }
                },
                child: Text(
                  link,
                ),
              ),
              Text(str, style: Theme.of(context).textTheme.headline4)
            ])),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await uploadVideo();
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add)) //
        );
  }
}

//try {
//   String fileName = Path.basename(video!.path);

//   Uint8List content = await video.readAsBytes();
//   var storage = AzureStorage.parse(
//       "https://amsstoragestage.blob.core.windows.net/upload-5597a46a-7dd9-4d76-a42a-1427f00d03ee?sv=2020-08-04&se=2022-03-28T20%3A03%3A38Z&sr=c&sp=rw&sig=M3ZFTaC6Sysws6r2bp0KUmZ3DXA5gQbWdQDZ6pMYi28%3D");
//   String container = "video";

//   String? contentType = lookupMimeType(fileName);
//   await storage.putBlob('/$container/$fileName',
//       bodyBytes: content,
//       contentType: contentType,
//       type: BlobType.BlockBlob);

//   print("done");
// } on AzureStorageException catch (ex) {
//   print(ex.message);
// } catch (err) {
//   print(err);
// }

// // if (video != null) {
// //   final file = XFile(video.path);

// //   _tusClient = TusClient(
// //       Uri.parse(
// //           "https://amsstoragestage.blob.core.windows.net/upload-5597a46a-7dd9-4d76-a42a-1427f00d03ee/video.mp4?sv=2020-08-04&se=2022-03-28T20%3A03%3A38Z&sr=c&sp=rw&sig=M3ZFTaC6Sysws6r2bp0KUmZ3DXA5gQbWdQDZ6pMYi28%3D"),
// //       file,
// //       headers: {
// //         "x-ms-blob-type": "BlockBlob",
// //       });

// //   print('URL111: ${_tusClient.url}');
// //   await _tusClient.upload(onComplete: () {
// //     setState(() {
// //       str = "uploaded";
// //     });
// //   }, onProgress: (progress) {
// //     setState(() {
// //       str = 'progress: $progress';
// //     });
// //     if (progress == 100) {
// //       link = "Link is available";
// //     }
// //   });
// // }
