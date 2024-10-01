import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ManageWordsPage extends StatefulWidget {
  const ManageWordsPage({super.key});

  @override
  _ManageWordsPageState createState() => _ManageWordsPageState();
}

class _ManageWordsPageState extends State<ManageWordsPage> {
  List<Map<String, String>> _words = [];
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _translationController = TextEditingController();

  final List<String> _wordTypes = [
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
          title: const Text('Edit Word'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _wordController,
                decoration: const InputDecoration(labelText: 'Word'),
              ),
              TextField(
                controller: _translationController,
                decoration: const InputDecoration(labelText: 'Translation'),
              ),
              DropdownButton<String>(
                value: _selectedType,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue;
                  });
                },
                items: _wordTypes.map<DropdownMenuItem<String>>((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  _words[index]['word'] = _wordController.text;
                  _words[index]['translation'] = _translationController.text;
                  _words[index]['type'] = _selectedType!;
                });
                _saveWords();
                Navigator.of(context).pop();
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
      appBar: AppBar(
        title: const Text('Manage Words'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextField(
                  controller: _wordController,
                  decoration: const InputDecoration(labelText: 'Word'),
                ),
                TextField(
                  controller: _translationController,
                  decoration: const InputDecoration(labelText: 'Translation'),
                ),
                DropdownButton<String>(
                  value: _selectedType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedType = newValue;
                    });
                  },
                  items:
                      _wordTypes.map<DropdownMenuItem<String>>((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                ),
                ElevatedButton(
                  onPressed: _addWord,
                  child: const Text('Add Word'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _words.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_words[index]['word']!),
                  subtitle: Text(
                      '${_words[index]['translation']} - ${_words[index]['type']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeWord(index),
                  ),
                  onTap: () => _editWord(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
