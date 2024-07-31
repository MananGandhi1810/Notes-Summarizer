import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'edit_page.dart';
import 'note_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> _notes = [];
  late SharedPreferences _prefs;
  final months = const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final colors = [
    Colors.red[400],
    Colors.blue[400],
    Colors.green[400],
    Colors.yellow[400],
  ];

  void _loadNotes() async {
    _prefs = await SharedPreferences.getInstance();
    final notes = _prefs.getStringList('notes');
    if (notes != null) {
      setState(() {
        _notes = notes.map((note) => Note.fromJson(jsonDecode(note))).toList();
      });
      debugPrint('Notes loaded: $_notes');
    }
  }

  void _newNote() async {
    final newNote = Note(
      id: DateTime.now().toString(),
      title: '',
      content: '',
      summary: '',
      lastEdited: DateTime.now(),
    );
    _notes.add(newNote);
    await _prefs.setStringList(
      'notes',
      _notes.map((note) => jsonEncode(note.toJson())).toList(),
    );
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => EditPage(
              id: newNote.id,
            ),
          ),
        )
        .then(
          (value) => _loadNotes(),
        );
  }

  @override
  void initState() {
    _loadNotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
              stretch: true,
              backgroundColor: Colors.black,
              elevation: 0,
              expandedHeight: MediaQuery.of(context).size.height * 0.15,
              flexibleSpace: const FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  'Notes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              )),
          _notes.isEmpty
              ? const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No notes found',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                )
              : SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final lastEdited = _notes[index].lastEdited;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: colors[index % colors.length],
                        margin: const EdgeInsets.all(0),
                        child: InkWell(
                          onTap: () => {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (context) => EditPage(
                                      id: _notes[index].id,
                                    ),
                                  ),
                                )
                                .then((value) => _loadNotes())
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  _notes[index].title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(child: Container()),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  "${months[lastEdited.month - 1]} ${lastEdited.day}, ${lastEdited.year}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _newNote,
        backgroundColor: colors[_notes.length % colors.length],
        child: const Icon(Icons.add),
      ),
    );
  }
}
