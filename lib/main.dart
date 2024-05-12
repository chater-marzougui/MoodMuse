import 'package:flutter/material.dart';
import 'package:moodmuse/playlist.dart';
import 'dart:async';
import 'login.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'favoris.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
String mood="" ;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white), // Set back arrow color here
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginPage(), // Login page route
        '/home': (_) => const Home(),
        '/notes': (_) => const NotesPage(),
        '/favoris': (_) => const Favoris(),

        //'/Song': (_) => const SongScreen(),
        //'/playlist': (_) => const PlaylistScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds:3), () {
      // After 1 second, navigate to the login page
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100,
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 200.0),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png', // Replace with your image path
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 40.0),
                child: Text(
                  'Welcome to',
                  style: TextStyle(fontSize: 24,
                      color: Color(0xFF8F3D7E),
                      fontWeight: FontWeight.bold),
                ),
              ),
              const Text(
                'MoodMuse',
                style: TextStyle(fontSize: 43,
                    color: Color(0xFF8F3D7E),
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

            ],
          ),
          Positioned(
            bottom: -50,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                "assets/images/supcom.png", // Replace with your image path
                width: 300,
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class Home extends StatefulWidget {

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  CameraController? _camcontroller;
  List<CameraDescription>? _cameras;
  int _selectedCameraIdx = 0;


  Future<String> _takePicture() async {
    if (!_camcontroller!.value.isInitialized) {
      // print( "Error: Camera is not initialized.") ;
      return "Error: Camera is not initialized." ;
    }

    // Get the temporary directory
    final directory = await getTemporaryDirectory();
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String filePath = '${directory.path}/$fileName';

    if (_camcontroller!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      // print( "Error: Capture is pending.") ;
      return "Error: Capture is pending." ;
    }

      final XFile picture = await _camcontroller!.takePicture();
      // mood=_sendImageToBackend(File(picture.path)).toString();
      mood = await _sendImageToBackend(File(picture.path));
      print(mood);
      // Save the picture to the desired path
      await picture.saveTo(filePath);
      return mood ;
  }
  void _showEmotionText(String emotion) async {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      // Prevents closing the dialog by tapping outside
      builder: (BuildContext context) {
        return TypewriterDialog(text: emotion);
      },
    );
  }

    Future <String> _sendImageToBackend(File imageFile) async {
    try {
      final response = await http.post(
        Uri.parse('https://99f2-102-159-241-168.ngrok-free.app/receive_image/'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'image': base64Encode(await imageFile.readAsBytes()),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        mood= responseData['message'] ;
        // showDialog(
        //   context: context,
        //   builder: (context) {
        //     return AlertDialog(
        //       title: const Text('Response from Server'),
        //       content: Text(responseData['message']),
        //       actions: <Widget>[
        //         TextButton(
        //           child: const Text('OK'),
        //           onPressed: () {
        //             Navigator.of(context).pop();
        //           },
        //         ),
        //       ],
        //     );
        //   },
        // );
        return mood ;
      } else {
        // print('Failed to send image. Status code: ${response.statusCode}');
        return 'Failed to send image. Status code: ${response.statusCode}' ;
      }
    } catch (error) {
      // print('Error during HTTP request: $error');
      return 'Error during HTTP request: $error' ;
    }
  }



  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _camcontroller = CameraController(
        _cameras![_selectedCameraIdx],
        ResolutionPreset.ultraHigh,
      );
      _camcontroller!.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      }).catchError((e) {
        print('Error initializing camera: $e');
      });
    } else {
      print('No camera found');
    }
  }

  @override
  void dispose() {
    _camcontroller?.dispose();
    super.dispose();
  }

int moodTonum(String mood){
  int i = 3;
  mood = mood.toUpperCase();
  if (mood == 'ANGRY'){i = 4;}
  else if (mood == "HAPPY"){i =1;}
  else if (mood == "NEUTRAL"){i = 2;}
  else if (mood == "SAD"){i =2 ;}
  else if (mood == "SURPRISED"){i =3 ;}

  return i;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 10,
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        //fit: StackFit.,
        children: [
          Container(
            //height: 300,
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            alignment: Alignment.topCenter,
            //width: 100,
            //height:  MediaQuery.of(context).size.height ,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.deepPurple.shade100,
                  const Color(0xF5CC8ED7),
                  const Color(0xFF8F3D7E),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top:50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _camcontroller == null || !_camcontroller!.value.isInitialized
                      ? Center(child: CircularProgressIndicator())
                      : AspectRatio(
                            //aspectRatio: _camcontroller!.value.aspectRatio,
                            aspectRatio: 0.55,
                        child: CameraPreview(_camcontroller!), // Replace TextField with CameraPreview
                  ),
                ),
                Column(
                  children:[
                    SizedBox(height: MediaQuery.of(context).size.width*1.5,),
                    Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width*0.345),
                        FloatingActionButton(
                          onPressed: () async {
                            mood = await _takePicture();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlaylistScreen(playlistindex: moodTonum(mood)),
                                ),
                              );
                            } ,
                            child: Icon(Icons.camera),
                      ),
                        SizedBox(width: 5,),
                        FloatingActionButton(
                          child: Icon(Icons.switch_camera),
                          onPressed: () {
                            _selectedCameraIdx = _selectedCameraIdx == 0 ? 1 : 0;
                            _camcontroller = CameraController(
                              _cameras![_selectedCameraIdx],
                              ResolutionPreset.max,
                            );
                            _camcontroller!.initialize().then((_) {
                              if (!mounted) return;
                              setState(() {});
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            )
          ),
        ],
      ),
      bottomNavigationBar: const _CustomNavBar(),
    );
  }
}




class _CustomNavBar extends StatefulWidget {
  const _CustomNavBar();

  @override
  State<_CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<_CustomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.of(context).pushNamed('/notes'); // Navigate to NotesPage
        break;
      case 1:
        Navigator.of(context).pushNamed('/home'); // Navigate to NotesPage
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PlaylistScreen(playlistindex: 5),
          ),
        );
        break;
    // Add more cases if needed for additional items
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF8F3D7E),
      unselectedItemColor: Colors.white,
      selectedItemColor: Colors.white,
      showUnselectedLabels: false,
      showSelectedLabels: false,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.note_alt_outlined, size: 30),
          label: 'Notes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt_outlined, size: 30),
          label: 'Camera',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border_outlined, size: 30),
          label: 'favorite',
        ),
      ],
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<String> notes = ['Welcome to MoodMuse Created by IEEE SUPCOM SB', 'We are excited to have you with us Please give us your feed back'];
  void addNote(String newNote) {
    setState(() {
      notes.add(newNote);
    });
  }
  void editNote(String newNote, int index) {
    setState(() {
      notes[index] = newNote;
    });
  }
  void _showEditNoteDialog(int index, String currentNote) {
    TextEditingController textEditingController = TextEditingController(text: currentNote);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Colors.deepPurple.shade100,
          child: Container(
            padding: const EdgeInsets.all(20.0),
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Edit your note',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Color(0xFF8F3D7E), // Purple color
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: TextField(
                      controller: textEditingController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Edit your note here...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(10.0),
                        fillColor: Colors.deepPurple.shade50,
                        filled: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: 60.0,
                  height: 40.0,
                  child: ElevatedButton(
                    onPressed: () {
                      editNote(textEditingController.text, index); // Update the existing note
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8F3D7E),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 5,
          ),
        ),
        backgroundColor:const Color(0xFF8F3D7E),
      ),
      backgroundColor: Colors.deepPurple.shade100,
      bottomNavigationBar: const _CustomNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10), // Some space at the top
            for (int i = 0; i < notes.length; i++)
              GestureDetector(
                onTap: () {
                  _showEditNoteDialog(i, notes[i]);
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.25, // 30% of the screen height
                  padding: const EdgeInsets.all(15.0),
                  child: Card(
                    color: const Color(0xFAFFFFFF).withOpacity(0.8),
                    child: ListTile(
                      title: Text(
                        notes[i],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10), // Space between the cards
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String newNote = ''; // Track the input text
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: Colors.deepPurple.shade100,
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          ' Express your feelings',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: Color(0xFF8F3D7E), // Purple color
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              newNote = value; // Update the new note text
                            },
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'Express your feelings here...',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(10.0),
                              fillColor: Colors.deepPurple.shade50,
                              filled: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      SizedBox(
                        width: 60.0,
                        height: 40.0,
                        child: ElevatedButton(
                          onPressed: () {
                            addNote(newNote); // Add the new note to the list
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8F3D7E),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },

        backgroundColor:const Color(0xFF8F3D7E),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFF8F3D7E), width: 3.0),
          borderRadius: BorderRadius.circular(30.0),
        ),
        elevation: 2.0,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
class TypewriterDialog extends StatefulWidget {
  final String text;

  const TypewriterDialog({super.key, required this.text});

  @override
  _TypewriterDialogState createState() => _TypewriterDialogState();
}

class _TypewriterDialogState extends State<TypewriterDialog> {
  String _displayedText = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      String displayed ='' ;
      switch(widget.text.toUpperCase()) {
        case "HAPPY" : displayed = "Happiness is a state of mind.";
        case "SAD" : displayed = "You are allowed to feel messed "
            "up and inside out. It doesnâ€™t mean youâ€™re defectiveâ€”it just means youâ€™re human.";
        case "ANGRY" : displayed = " If you are patient in one moment of anger, you will escape a hundred days of sorrow.";
        case "SURPRISED" : displayed =  "Surprise is the greatest gift which life can grant us.";
        case "NEUTRAL" : displayed =  "the starting point of all emotions , neutral.";
      }
      setState(() {
        _displayedText += displayed ;}
      );
      _timer?.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black.withOpacity(0.4), // Semi-transparent background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      content: Text(
        _displayedText,
        style: const TextStyle(
          color: Colors.white, // White text color
          fontWeight: FontWeight.bold, // Bold text
        ),
      ),
    );
  }

}