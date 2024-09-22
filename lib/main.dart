import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(MyVocabApp());
}

class MyVocabApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'ComicSans', // กำหนดฟอนต์ที่เราเพิ่มไว้
        primarySwatch: Colors.blue,
      ),
      home: MainScaffold(),
    );
  }
}

// ---------------- Scaffold หลักสำหรับการนำทาง ----------------

class MainScaffold extends StatefulWidget {
  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    SettingPage(),
    AlbumsPage(),
    GamePage(),
    VocabularyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.black,
              child: Text(
                'MV',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 10),
            Text('My Vocab App'),
          ],
        ),
        backgroundColor: Colors.lightBlue,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album),
            label: 'Albums',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gamepad),
            label: 'Game',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Vocabulary',
          ),
        ],
      ),
    );
  }
}

// ---------------- หน้า Setting ----------------

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Settings Page',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

// ---------------- หน้าจัดการอัลบั้ม พร้อมระบบค้นหา ----------------

class AlbumsPage extends StatefulWidget {
  @override
  _AlbumsPageState createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  List<String> _albums = [
    'Travel Album',
    'Family Album',
    'Friends Album',
    'Work Album',
    'Nature Album',
  ];
  List<String> _filteredAlbums = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredAlbums = _albums; // เริ่มต้นแสดงทั้งหมด
  }

  void _filterAlbums(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAlbums = _albums;
      } else {
        _filteredAlbums = _albums
            .where((album) => album.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Albums'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Albums',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterAlbums,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredAlbums.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_filteredAlbums[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- หน้าจัดการเกม ----------------

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final List<Map<String, String>> _words = [
    {'word': 'apple', 'translation': 'แอปเปิ้ล'},
    {'word': 'dog', 'translation': 'หมา'},
    {'word': 'cat', 'translation': 'แมว'},
    {'word': 'car', 'translation': 'รถยนต์'},
    {'word': 'sun', 'translation': 'ดวงอาทิตย์'},
    {'word': 'moon', 'translation': 'พระจันทร์'},
    {'word': 'bird', 'translation': 'นก'},
    {'word': 'fish', 'translation': 'ปลา'},
  ];

  List<String> _tiles = [];
  List<bool> _revealed = [];
  int? _firstTileIndex;
  bool _canTap = true;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    List<String> wordList = [];
    for (var word in _words) {
      wordList.add(word['word']!);
      wordList.add(word['translation']!);
    }
    wordList.shuffle(Random());
    setState(() {
      _tiles = wordList;
      _revealed = List.filled(_tiles.length, false);
      _firstTileIndex = null;
      _canTap = true;
    });
  }

  void _onTileTap(int index) {
    if (!_canTap || _revealed[index]) return;

    setState(() {
      _revealed[index] = true;
    });

    if (_firstTileIndex == null) {
      _firstTileIndex = index;
    } else {
      _canTap = false;
      int firstIndex = _firstTileIndex!;
      String firstValue = _tiles[firstIndex];
      String secondValue = _tiles[index];

      bool isMatch = _checkMatch(firstValue, secondValue);

      if (isMatch) {
        _canTap = true;
        _firstTileIndex = null;
      } else {
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _revealed[firstIndex] = false;
            _revealed[index] = false;
          });
          _canTap = true;
          _firstTileIndex = null;
        });
      }
    }
  }

  bool _checkMatch(String first, String second) {
    for (var word in _words) {
      if ((first == word['word'] && second == word['translation']) ||
          (second == word['word'] && first == word['translation'])) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Matching Game'),
      ),
      body: Center(
        child: Text(
          'Game Page',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // Change to 4 columns for 4x4 grid
      ),
      itemCount: _tiles.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _onTileTap(index),
          child: Card(
            color: _revealed[index] ? Colors.white : Colors.blue,
            child: Center(
              child: Text(
                _revealed[index] ? _tiles[index] : '',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------- หน้าจัดการคำศัพท์ ----------------

class VocabularyPage extends StatefulWidget {
  @override
  _VocabularyPageState createState() => _VocabularyPageState();
}

class _VocabularyPageState extends State<VocabularyPage> {
  List<Map<String, String>> _words = [];
  TextEditingController _wordController = TextEditingController();
  TextEditingController _translationController = TextEditingController();

  List<String> _wordTypes = [
    'Nouns',
    'Verbs',
    'Adjectives',
    'Adverbs',
    'Prepositions',
    'Determiners',
    'Pronouns',
    'Conjunctions'
  ];
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  void _loadWords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedWords = prefs.getString('words');

    if (storedWords != null) {
      setState(() {
        _words = List<Map<String, String>>.from(json.decode(storedWords));
      });
    }
  }

  void _saveWords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('words', json.encode(_words));
  }

  void _addWord() {
    String newWord = _wordController.text;
    String translation = _translationController.text;

    if (newWord.isNotEmpty && _selectedType != null && translation.isNotEmpty) {
      setState(() {
        _words.add({
          'word': newWord,
          'type': _selectedType!,
          'translation': translation
        });
      });

      _wordController.clear();
      _translationController.clear();
      _selectedType = null;

      _saveWords();
    }
  }

  void _removeWord(int index) {
    setState(() {
      _words.removeAt(index);
    });

    _saveWords();
  }

  void _editWord(int index) {
    _wordController.text = _words[index]['word']!;
    _translationController.text = _words[index]['translation']!;
    _selectedType = _words[index]['type'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Word'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _wordController,
                decoration: InputDecoration(
                  labelText: 'Edit word',
                ),
              ),
              TextField(
                controller: _translationController,
                decoration: InputDecoration(
                  labelText: 'Edit translation',
                ),
              ),
              DropdownButton<String>(
                value: _selectedType,
                hint: Text('Select type of word'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue;
                  });
                },
                items: _wordTypes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
              },
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  _words[index] = {
                    'word': _wordController.text,
                    'type': _selectedType!,
                    'translation': _translationController.text
                  };
                });
                _wordController.clear();
                _translationController.clear();
                _selectedType = null;
                _saveWords();
                Navigator.of(context).pop(); // ปิด dialog หลังจากบันทึกข้อมูล
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _wordController,
              decoration: InputDecoration(
                labelText: 'Enter new word',
              ),
            ),
            TextField(
              controller: _translationController,
              decoration: InputDecoration(
                labelText: 'Enter translation',
              ),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedType,
              hint: Text('Select type of word'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedType = newValue;
                });
              },
              items: _wordTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addWord,
              child: Text('Save Word'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _words.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onLongPress: () => _editWord(index),
                    child: ListTile(
                      title: Text(
                          '${_words[index]['word']} (${_words[index]['type']})'),
                      subtitle:
                          Text('Translation: ${_words[index]['translation']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _removeWord(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
