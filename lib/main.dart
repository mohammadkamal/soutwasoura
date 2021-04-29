import 'dart:io';

import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sout Wa Soura',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.grey[900],
        buttonColor: Colors.grey[900],
        floatingActionButtonTheme:
            FloatingActionButtonThemeData(backgroundColor: Colors.grey[900]),
      ),
      home: MyHomePage(title: 'Sout Wa Soura'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _videoUrlController = TextEditingController();

  void initState()
  {
    super.initState();
    _handlePermission(Permission.storage);
  }

  Future<void> _downloadVideo(String url) async {
    if (_formKey.currentState.validate()) {}

    var yt = YoutubeExplode();
    var id = VideoId(url.trim());
    var video = await yt.videos.get(id);
    var manifest = await yt.videos.streamsClient.getManifest(url);
    //var audio = manifest.audioOnly.last;
    var muxed = manifest.muxed.last;
    var directory = await DownloadsPathProvider.downloadsDirectory;
    var filePath = path.join(
        directory.uri.toFilePath(), '${video.id}.${muxed.container.name}');
    var file = File(filePath);
    var fileStream = file.openWrite();

    await yt.videos.streamsClient.get(muxed).pipe(fileStream);
    await fileStream.flush();
    await fileStream.close();

    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text('Download saved to: $filePath'),
            ));
  }

  Future<void> _handlePermission(Permission permission) async {
    final status = await permission.request();
    print(status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: EdgeInsets.only(left: 10, right: 10, top: 25),
            children: [
              TextFormField(
                autofocus: true,
                controller: _videoUrlController,
                decoration: InputDecoration(
                    labelText: 'Video url',
                    hintText: 'Enter download url',
                    helperText: 'https://www.youtube.com/watch?v=xxxxx',
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[900]))),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                  onPressed: () {
                    _downloadVideo(_videoUrlController.text);
                  },
                  child: Text('Download'))
            ],
          ),
        ));
  }
}
