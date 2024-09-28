import 'package:flutter/material.dart';
import 'package:flutter_camera_example/screens/add-project/select_format_screen.dart';
import 'package:flutter_camera_example/utils/global_state.dart';

class SelectMusicScreen extends StatefulWidget {
  const SelectMusicScreen({Key? key}) : super(key: key);

  @override
  _SelectMusicScreenState createState() => _SelectMusicScreenState();
}

class _SelectMusicScreenState extends State<SelectMusicScreen> {
  String _selectedGenre = 'הכל';
  String _selectedMusic = 'בלי מוזיקה'; // Default selection
  final List<String> _genres = ['הכל', 'אקוסטי', "צ'יל", 'קלאסי', 'אלקטרוני'];
  final List<Map<String, String>> _musicList = [
    {
      'title': 'בלי מוזיקה',
      'genre': 'אחר',
      'assetPath': 'assets/audio/silence.mp3'
    },
    {
      'title': '1 שיר רקע',
      'genre': 'פופ',
      'assetPath': 'assets/audio/background1.mp3'
    },
    {
      'title': 'שיר רקע 2',
      'genre': "צ'יל",
      'assetPath': 'assets/audio/background2.mp3'
    },
    {
      'title': 'שיר רקע ראפ',
      'genre': 'ראפ',
      'assetPath': 'assets/audio/rapbackground.mp3'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          child: const Text('חזור', style: TextStyle(color: Colors.black)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            child: const Text('הבא', style: TextStyle(color: Colors.green)),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const SelectFormatScreen()),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'בחר מוזיקה',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'יש להאזין ולבחור את קטע השמע עבור הסרטון',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _genres
                        .map((genre) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ChoiceChip(
                                label: Text(genre),
                                selected: genre == _selectedGenre,
                                onSelected: (bool selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedGenre = genre;
                                    });
                                  }
                                },
                                selectedColor: Colors.green,
                                avatar: genre == _selectedGenre
                                    ? const Icon(Icons.check,
                                        color: Colors.white)
                                    : null,
                                labelStyle: TextStyle(
                                  color: genre == _selectedGenre
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: _musicList
                        .map((music) => _buildMusicItem(
                              music['title']!,
                              music['genre']!,
                              music['assetPath']!,
                              isSelected: music['title'] == _selectedMusic,
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicItem(String title, String genre, String assetPath,
      {bool isSelected = false}) {
    return ListTile(
      leading: const Icon(Icons.play_arrow),
      title: Text(title),
      subtitle: Text(genre),
      tileColor: isSelected ? Colors.green.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: isSelected ? Colors.green : Colors.transparent),
        borderRadius: BorderRadius.circular(8),
      ),
      onTap: () {
        GlobalState.addProfileAttribute("music", assetPath);
        setState(() {
          _selectedMusic = title;
        });
      },
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          return Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index <= 3
                      ? Colors.green
                      : (index <= 3 ? Colors.green : Colors.grey[300]),
                  border: Border.all(
                      color: index <= 3 ? Colors.green : Colors.grey[300]!),
                ),
                child: Center(
                  child: index <= 2
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: index <= 3 ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              if (index < 4)
                Container(
                  width: 20,
                  height: 2,
                  color: index < 1 ? Colors.green : Colors.grey[300],
                ),
            ],
          );
        }),
      ),
    );
  }
}
