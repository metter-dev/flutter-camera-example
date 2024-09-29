import 'package:flutter/material.dart';
import 'package:flutter_camera_example/screens/add-project/final_result_screen.dart';

class SelectFormatScreen extends StatefulWidget {
  const SelectFormatScreen({Key? key}) : super(key: key);

  @override
  _SelectFormatScreenState createState() => _SelectFormatScreenState();
}

class _SelectFormatScreenState extends State<SelectFormatScreen> {
  String _selectedFormat = '16:9';
  String _selectedPlatform = 'טיקטוק';
  final bool _isLoading = false;

  Future<void> _handleFinish(BuildContext context) async {
    // Navigate to the next screen
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const FinalResultScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
              leading: TextButton(
                  child:
                      const Text('חזור', style: TextStyle(color: Colors.black)),
                  onPressed: () => Navigator.of(context).pop()),
              actions: [
                TextButton(
                  child:
                      const Text('סיום', style: TextStyle(color: Colors.green)),
                  onPressed: () => _handleFinish(context),
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
                        'בחר פורמט',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'בחר רשת חברתית',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildFormatOption('לאורך', '16:9'),
                            const SizedBox(width: 16),
                            _buildFormatOption('מרובע', '1:1'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildPreviewCard('סטורי/ווצאפ'),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildPreviewCard('טיקטוק'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Template is positioned higher to avoid being hidden by social media text.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'טוען סרטון...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFormatOption(String label, String aspect) {
    bool isSelected = _selectedFormat == aspect;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFormat = aspect;
        });
      },
      child: Container(
          width: 125,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(color: isSelected ? Colors.green : Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(label,
                    style: TextStyle(
                        color: isSelected ? Colors.green : Colors.black)),
                AspectRatio(
                  aspectRatio: aspect == '16:9' ? 16 / 9 : 1,
                  child: Container(
                    color: Colors.grey[200],
                    child: Center(child: Text(aspect)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          )),
    );
  }

  Widget _buildPreviewCard(String label) {
    bool isSelected = _selectedPlatform == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlatform = label;
        });
      },
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: isSelected ? Colors.green : Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.grey[200],
                  child: const Center(child: Text('דמו')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(label,
                    style: TextStyle(
                        color: isSelected ? Colors.green : Colors.black)),
              ),
            ],
          ),
        ),
      ),
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
                  color: index <= 4
                      ? Colors.green
                      : (index <= 4 ? Colors.green : Colors.grey[300]),
                  border: Border.all(
                      color: index <= 3 ? Colors.green : Colors.grey[300]!),
                ),
                child: Center(
                  child: index <= 3
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: index <= 4 ? Colors.white : Colors.grey,
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
