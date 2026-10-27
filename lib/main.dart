import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cheetah_flutter/cheetah_error.dart';
import 'package:cheetah_flutter/cheetah.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_voice_processor/flutter_voice_processor.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'firebase_options.dart';
import 'chat_bubble.dart';
import 'app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final savedTheme = await AdaptiveTheme.getThemeMode();
  runApp(MyApp(savedThemeMode: savedTheme));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
  const MyApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    // Improved minimalistic color scheme with high contrast and subtle grays
    final lightScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.black,
      onPrimary: Colors.white,
      secondary: Color(0xFF888888),
      onSecondary: Colors.black,
      error: Colors.red,
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Color(0xFFF7F7F7), // subtle gray for cards/surfaces
      onSurface: Colors.black,
      outline: Color(0xFFDDDDDD), // for dividers/borders
    );
    final darkScheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: Colors.white,
      onPrimary: Colors.black,
      secondary: Color(0xFFBBBBBB),
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.black,
      background: Colors.black,
      onBackground: Colors.white,
      surface: Color(0xFF181818), // deep gray for cards/surfaces
      onSurface: Colors.white,
      outline: Color(0xFF333333), // for dividers/borders
    );
    return AdaptiveTheme(
      initial: savedThemeMode ?? AdaptiveThemeMode.system,
      light: _theme(lightScheme, Brightness.light),
      dark: _theme(darkScheme, Brightness.dark),
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nurse2',
        theme: theme,
        darkTheme: darkTheme,
        home: const RootScreen(),
      ),
    );
  }

  ThemeData _theme(ColorScheme scheme, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor: scheme.background,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData(brightness: brightness).textTheme.apply(
          bodyColor: scheme.onBackground,
          displayColor: scheme.onBackground,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 4,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        shadowColor: scheme.outline.withOpacity(0.10),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: scheme.onSurface,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shadowColor: scheme.outline.withOpacity(0.10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        tileColor: scheme.surface,
        selectedTileColor: scheme.secondary.withOpacity(0.10),
        iconColor: scheme.onSurface,
        textColor: scheme.onSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: scheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        hintStyle: TextStyle(color: scheme.onSurface.withOpacity(0.5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 8,
        textStyle: GoogleFonts.plusJakartaSans(color: scheme.onSurface),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 20, color: scheme.primary),
        contentTextStyle: GoogleFonts.plusJakartaSans(fontSize: 16, color: scheme.onSurface),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.surface,
        contentTextStyle: GoogleFonts.plusJakartaSans(color: scheme.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondary.withOpacity(0.10),
        labelTextStyle: MaterialStateProperty.all(GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: scheme.onSurface)),
        iconTheme: MaterialStateProperty.all(IconThemeData(color: scheme.onSurface)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.secondary.withOpacity(0.2),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline,
        thickness: 1.2,
        space: 24,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      splashFactory: InkRipple.splashFactory,
      highlightColor: scheme.secondary.withOpacity(0.08),
      hoverColor: scheme.secondary.withOpacity(0.04),
      focusColor: scheme.secondary.withOpacity(0.10),
      shadowColor: scheme.outline.withOpacity(0.10),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;
  final _screens = const [HomeScreen(), TasksScreen(), ChatScreen()];

  void _onTap(int idx) => setState(() => _currentIndex = idx);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.checklist_rounded), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.monitor_heart), label: 'Vitals'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Cheetah? _cheetah;
  VoiceProcessor? _voiceProcessor;
  bool _isListening = false;
  String _transcript = '';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initCheetah();
    _voiceProcessor = VoiceProcessor.instance;
  }

  Future<void> _initCheetah() async {
    try {
      const accessKey = AppConfig.cheetahAccessKey;
      final byteData = await rootBundle.load(AppConfig.cheetahModelAsset);
      final tempDir = await getTemporaryDirectory();
      final modelFile = File('${tempDir.path}/cheetah_model.pv');
      await modelFile.writeAsBytes(byteData.buffer.asUint8List());
      _cheetah = await Cheetah.create(accessKey, modelFile.path, enableAutomaticPunctuation: true);
    } on CheetahException catch (e) {
      if (kDebugMode) print("Cheetah init error: ${e.message}");
    }
  }

  Future<void> _toggleListening() async {
    if (_isProcessing) return;
    if (!_isListening) {
      _transcript = '';
      setState(() => _isListening = true);
      _voiceProcessor!
        ..addFrameListener(_onFrame)
        ..addErrorListener(_onError);
      final granted = await _voiceProcessor!.hasRecordAudioPermission();
      if (granted == true) {
        await _voiceProcessor!.start(_cheetah!.frameLength, _cheetah!.sampleRate);
      }
    } else {
      await _voiceProcessor!.stop();
      _voiceProcessor!
        ..removeFrameListener(_onFrame)
        ..removeErrorListener(_onError);
      setState(() => _isListening = false);
      _processTranscript();
    }
  }

  void _onFrame(List<int> frame) async {
    if (_cheetah == null) return;
    final r = await _cheetah!.process(frame);
    if (r.transcript.isNotEmpty) {
      setState(() => _transcript += r.transcript);
    }
    if (r.isEndpoint) {
      final f = await _cheetah!.flush();
      if (f.transcript.isNotEmpty) {
        setState(() => _transcript += f.transcript);
      }
    }
  }

  void _onError(VoiceProcessorException e) {
    if (kDebugMode) print('VoiceProcessor error: ${e.message}');
  }

  Future<void> _processTranscript() async {
    if (_transcript.trim().isEmpty) return;
    setState(() => _isProcessing = true);

    // 1. Polished task description
    // final payload = jsonEncode({
    //   'model': 'meta-llama/Llama-3.2-3B-Instruct',
    //   'messages': [
    //     {
    //       'role': 'system',
    //       'content': 'You are a nurse assistant. Whatever task she tells you to remind her or save, polish the task description into a concise, well‐written sentence and remind her. For example, if she says "remind me to check Johns blood pressure", you could reply something like "Check Johns blood pressure"'
    //     },
    //     {'role': 'user', 'content': _transcript.trim()},
    //   ]
    // });

    String polished;
    try {
      final taskPrompt = 'You are a nurse assistant. Whatever task she tells you to remind her or save, polish the task description into a concise, well‐written sentence and remind her. For example, if she says "remind me to check Johns blood pressure", you could reply something like "Check Johns blood pressure"';
      final resp = await http.post(
        Uri.parse(AppConfig.llmApiUrl),
        headers: {
          'Authorization': 'Bearer ${AppConfig.llmApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'template_key': 'default',
          'user_input': taskPrompt,
        }),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        polished = (data['response'] ?? data['output'] ?? data['text'] ?? _transcript.trim()).toString().trim();
      } else {
        polished = _transcript.trim();
      }
    } catch (_) {
      polished = _transcript.trim();
    }

    // 2. Extract date and time (robust)
    DateTime dueDateTime = DateTime.now();
    try {
      // final dateTimePayload = jsonEncode({
      //   'model': 'meta-llama/Llama-3.2-3B-Instruct',
      //   'messages': [
      //     {
      //       'role': 'system',
      //       'content': 'Extract the date and time from the following text. If no date is mentioned, return an empty string for date. If no time is mentioned, return an empty string for time. Respond strictly as JSON: {"date": "yyyy-MM-dd", "time": "HH:mm"}. Do not explain.'
      //     },
      //     {'role': 'user', 'content': _transcript.trim()},
      //   ]
      // });
      final dateTimePrompt = 'Extract the date and time from the following text. If no date is mentioned, return an empty string for date. If no time is mentioned, return an empty string for time. Respond strictly as JSON: {"date": "yyyy-MM-dd", "time": "HH:mm"}. Do not explain.';
      final dateResp = await http.post(
        Uri.parse(AppConfig.llmApiUrl),
        headers: {
          'Authorization': 'Bearer ${AppConfig.llmApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'template_key': 'default',
          'user_input': dateTimePrompt,
        }),
      );
      if (dateResp.statusCode == 200) {
        final data = jsonDecode(dateResp.body);
        String content = (data['response'] ?? data['output'] ?? data['text'] ?? '{}').toString();
        // Sanitize: sometimes Llama returns code block or extra text
        content = content.trim();
        if (content.startsWith('```')) {
          content = content.replaceAll(RegExp(r'```[a-zA-Z]*'), '').replaceAll('```', '').trim();
        }
        final jsonMap = jsonDecode(content);
        final dateStr = (jsonMap['date'] as String?)?.trim();
        final timeStr = (jsonMap['time'] as String?)?.trim();
        if ((dateStr == null || dateStr.isEmpty) && (timeStr != null && timeStr.isNotEmpty)) {
          // Only time is present, use today's date and extracted time
          final now = DateTime.now();
          dueDateTime = DateFormat('yyyy-MM-dd HH:mm').parse('${DateFormat('yyyy-MM-dd').format(now)} $timeStr');
        } else if (dateStr != null && dateStr.isNotEmpty) {
          try {
            if (timeStr != null && timeStr.isNotEmpty) {
              dueDateTime = DateFormat('yyyy-MM-dd HH:mm').parse('$dateStr $timeStr');
            } else {
              dueDateTime = DateFormat('yyyy-MM-dd').parse(dateStr);
            }
          } catch (_) {
            dueDateTime = DateTime.now();
          }
        } else {
          // If Llama did not extract a date, use real-time current date
          dueDateTime = DateTime.now();
        }
      }
    } catch (_) {
      dueDateTime = DateTime.now();
    }

    // 3. Extract room number (robust)
    String? roomNo;
    try {
      // final roomPayload = jsonEncode({
      //   'model': 'meta-llama/Llama-3.2-3B-Instruct',
      //   'messages': [
      //     {
      //       'role': 'system',
      //       'content': 'Extract the patient\'s room number from the following text. If no room number is mentioned, return an empty string. Respond strictly as JSON: {"roomNo": "..."}. Do not explain.'
      //     },
      //     {'role': 'user', 'content': _transcript.trim()},
      //   ]
      // });
      final roomPrompt = 'Extract patient room number from this text. Return JSON: {"roomNo": "..."}. If none mentioned, use empty string. Text: ${_transcript.trim()}';
      final roomResp = await http.post(
        Uri.parse(AppConfig.llmApiUrl),
        headers: {
          'Authorization': 'Bearer ${AppConfig.llmApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'template_key': 'default',
          'user_input': roomPrompt,
        }),
      );
      if (roomResp.statusCode == 200) {
        final data = jsonDecode(roomResp.body);
        String content = (data['response'] ?? data['output'] ?? data['text'] ?? '{}').toString();
        // Sanitize: sometimes Llama returns code block or extra text
        content = content.trim();
        if (content.startsWith('```')) {
          content = content.replaceAll(RegExp(r'```[a-zA-Z]*'), '').replaceAll('```', '').trim();
        }
        final jsonMap = jsonDecode(content);
        final extracted = (jsonMap['roomNo'] as String?)?.trim();
        if (extracted != null && extracted.isNotEmpty) {
          roomNo = extracted;
        }
      }
    } catch (_) {
      roomNo = null;
    }

    // Store in Firestore
    await FirebaseFirestore.instance.collection('tasks').add({
      'task': polished,
      'createdAt': FieldValue.serverTimestamp(),
      'dueTime': Timestamp.fromDate(dueDateTime),
      'roomNo': roomNo,
    });

    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task has been created')));
  }

  @override
  Widget build(BuildContext context) {
    final rootState = context.findAncestorStateOfType<_RootScreenState>()!;
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Stack(
        children: [
          // Animated gradient background
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.primary.withOpacity(0.12),
                    scheme.secondary.withOpacity(0.10),
                    scheme.surfaceVariant.withOpacity(0.18),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Glassmorphic card for prompt
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surface.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.primary.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: scheme.primary.withOpacity(0.10), width: 1.5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                    child: Column(
                      children: [
                        Text(
                          'How can I help you today?',
                          style: GoogleFonts.plusJakartaSans(
                            textStyle: Theme.of(context).textTheme.headlineMedium,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        // Animated glowing mic button
                        GestureDetector(
                          onTap: _toggleListening,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: _isListening
                                    ? [scheme.primary.withOpacity(0.35), scheme.primary.withOpacity(0.10)]
                                    : [scheme.primary.withOpacity(0.18), scheme.primary.withOpacity(0.05)],
                                radius: 0.8,
                              ),
                              boxShadow: _isListening
                                  ? [
                                BoxShadow(
                                  color: scheme.primary.withOpacity(0.35),
                                  blurRadius: 32,
                                  spreadRadius: 8,
                                ),
                              ]
                                  : [],
                            ),
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              size: 44,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                        if (_isProcessing)
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text('Your task is being created...'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Modern navigation buttons
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 24,
                    runSpacing: 16,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_task),
                        label: const Text('Add Task/Reminder'),
                        onPressed: () => rootState._onTap(1),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(160, 54),
                          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 18),
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.monitor_heart),
                        label: const Text('Patient Vitals'),
                        onPressed: () => rootState._onTap(2),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(160, 54),
                          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 18),
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isListening)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Lottie.asset(AppConfig.voiceWaveAnimation),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _transcript.isEmpty ? 'Speak now…' : _transcript,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleListening,
                        icon: const Icon(Icons.stop),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _tasksCollection = FirebaseFirestore.instance.collection('tasks');

  String _sortField = 'createdAt';
  bool _descending = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  Future<void> _markTaskCompleted(DocumentSnapshot<Map<String, dynamic>> doc, bool completed) async {
    await _tasksCollection.doc(doc.id).update({
      'completed': completed,
      'completedAt': completed ? FieldValue.serverTimestamp() : null,
    });
  }

  Future<void> _editTask(DocumentSnapshot<Map<String, dynamic>> doc) async {
    final currentText = doc.data()?['task'] as String? ?? '';
    final currentDueTime = doc.data()?['dueTime'];
    final currentRoomNo = doc.data()?['roomNo']?.toString() ?? '';
    final controller = TextEditingController(text: currentText);
    final dueTimeController = TextEditingController(text: currentDueTime != null ? (currentDueTime is Timestamp ? DateFormat.yMd().add_jm().format(currentDueTime.toDate()) : currentDueTime.toString()) : '');
    final roomNoController = TextEditingController(text: currentRoomNo);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Task description'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: dueTimeController,
              decoration: const InputDecoration(hintText: 'Due date & time (optional)'),
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    final dt = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
                    dueTimeController.text = DateFormat.yMd().add_jm().format(dt);
                  }
                }
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: roomNoController,
              decoration: const InputDecoration(hintText: "Room No. (optional)"),
              keyboardType: TextInputType.text,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final updated = controller.text.trim();
              final dueTimeText = dueTimeController.text.trim();
              final roomNoText = roomNoController.text.trim();
              DateTime? dueTime;
              if (dueTimeText.isNotEmpty) {
                try {
                  dueTime = DateFormat.yMd().add_jm().parseStrict(dueTimeText);
                } catch (_) {}
              }
              if (updated.isNotEmpty) {
                await _tasksCollection.doc(doc.id).update({
                  'task': updated,
                  'updatedAt': FieldValue.serverTimestamp(),
                  'dueTime': dueTime != null ? Timestamp.fromDate(dueTime) : null,
                  'roomNo': roomNoText.isNotEmpty ? roomNoText : null,
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask(DocumentSnapshot<Map<String, dynamic>> doc) async {
    await _tasksCollection.doc(doc.id).delete();
  }

  Future<void> _confirmDelete(DocumentSnapshot<Map<String, dynamic>> doc) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task?'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (proceed == true) {
      await _deleteTask(doc);
    }
  }

  Widget _buildTaskItem(BuildContext context, DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final taskText = data['task'] as String? ?? '';
    final createdAtTs = data['createdAt'] as Timestamp?;
    final createdAt = createdAtTs?.toDate();
    final completed = data['completed'] as bool? ?? false;
    final completedAtTs = data['completedAt'] as Timestamp?;
    final completedAt = completedAtTs?.toDate();
    final dueTimeTs = data['dueTime'] as Timestamp?;
    final dueTime = dueTimeTs?.toDate();
    final roomNo = data['roomNo']?.toString() ?? '';
    final textStyle = completed
        ? const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: InkWell(
          onTap: () => _markTaskCompleted(doc, !completed),
          child: Icon(
            completed ? Icons.check_circle : Icons.check_circle_outline,
            color: completed ? Colors.green : null,
          ),
        ),
        title: Text(taskText, style: textStyle),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dueTime != null)
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 4),
                  Text('Due: ' + DateFormat.yMd().add_jm().format(dueTime)),
                ],
              ),
            if (roomNo.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.meeting_room, size: 16),
                  const SizedBox(width: 4),
                  Text('Room: $roomNo'),
                ],
              ),
            if (createdAt != null)
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat.yMd().add_jm().format(
                      (completed ? (completedAt ?? createdAt) : createdAt)!,
                    ),
                  ),
                ],
              ),
          ],
        ),
        trailing: completed
            ? IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _confirmDelete(doc),
        )
            : PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'Edit') {
              _editTask(doc);
            } else if (value == 'Delete') {
              _confirmDelete(doc);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'Edit', child: Text('Edit')),
            PopupMenuItem(value: 'Delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: '$_sortField-${_descending ? 'desc' : 'asc'}',
                icon: const Icon(Icons.sort),
                style: Theme.of(context).textTheme.bodyMedium,
                items: const [
                  DropdownMenuItem(value: 'createdAt-desc', child: Row(children: [Icon(Icons.calendar_today, size: 18), SizedBox(width: 6), Text('Created (Newest)')],)),
                  DropdownMenuItem(value: 'createdAt-asc', child: Row(children: [Icon(Icons.calendar_today, size: 18), SizedBox(width: 6), Text('Created (Oldest)')],)),
                  DropdownMenuItem(value: 'dueTime-desc', child: Row(children: [Icon(Icons.access_time, size: 18), SizedBox(width: 6), Text('Due Time (Latest)')],)),
                  DropdownMenuItem(value: 'dueTime-asc', child: Row(children: [Icon(Icons.access_time, size: 18), SizedBox(width: 6), Text('Due Time (Earliest)')],)),
                  DropdownMenuItem(value: 'roomNo-desc', child: Row(children: [Icon(Icons.meeting_room, size: 18), SizedBox(width: 6), Text('Room No. (Z→A)')],)),
                  DropdownMenuItem(value: 'roomNo-asc', child: Row(children: [Icon(Icons.meeting_room, size: 18), SizedBox(width: 6), Text('Room No. (A→Z)')],)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    final parts = value.split('-');
                    setState(() {
                      _sortField = parts[0];
                      _descending = parts[1] == 'desc';
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final controller = TextEditingController();
          final dueTimeController = TextEditingController();
          final roomNoController = TextEditingController();
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('New Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: controller, decoration: const InputDecoration(hintText: 'Task description')),
                  const SizedBox(height: 8),
                  TextField(
                    controller: dueTimeController,
                    decoration: const InputDecoration(hintText: 'Due date & time (optional)'),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          final dt = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
                          dueTimeController.text = DateFormat.yMd().add_jm().format(dt);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: roomNoController,
                    decoration: const InputDecoration(hintText: "Room No. (optional)"),
                    keyboardType: TextInputType.text,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    final task = controller.text.trim();
                    final dueTimeText = dueTimeController.text.trim();
                    final roomNoText = roomNoController.text.trim();
                    DateTime? dueTime;
                    if (dueTimeText.isNotEmpty) {
                      try {
                        dueTime = DateFormat.yMd().add_jm().parseStrict(dueTimeText);
                      } catch (_) {}
                    }
                    Navigator.pop(context, {
                      'task': task,
                      'dueTime': dueTime,
                      'roomNo': roomNoText,
                    });
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          );
          if (result != null && (result['task'] as String).isNotEmpty) {
            await _tasksCollection.add({
              'task': result['task'],
              'completed': false,
              'createdAt': FieldValue.serverTimestamp(),
              'dueTime': result['dueTime'] != null ? Timestamp.fromDate(result['dueTime']) : null,
              'roomNo': (result['roomNo'] as String).isNotEmpty ? result['roomNo'] : null,
            });
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              key: ValueKey('$_sortField-$_descending'),
              stream: _tasksCollection.orderBy(_sortField, descending: _descending).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading tasks'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                final filteredDocs = _searchQuery.isEmpty
                    ? docs
                    : docs.where((doc) {
                  final data = doc.data();
                  final task = (data['task'] ?? '').toString().toLowerCase();
                  final roomNo = (data['roomNo'] ?? '').toString().toLowerCase();
                  final dueTime = data['dueTime'] is Timestamp
                      ? DateFormat.yMd().add_jm().format((data['dueTime'] as Timestamp).toDate()).toLowerCase()
                      : '';
                  return task.contains(_searchQuery.toLowerCase()) ||
                      roomNo.contains(_searchQuery.toLowerCase()) ||
                      dueTime.contains(_searchQuery.toLowerCase());
                }).toList();
                if (filteredDocs.isEmpty) {
                  return const Center(child: Text('No tasks yet'));
                }
                return ListView(
                  children: filteredDocs.map((doc) => _buildTaskItem(context, doc)).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  const ChatMessage({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, String>> _chats = [];
  String? _currentChatId;
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> _notes = [];
  String? _editingNoteId;
  final TextEditingController _noteController = TextEditingController();
  Cheetah? _cheetahChat;
  Cheetah? _cheetahNote;
  VoiceProcessor? _voiceProcessor;
  bool _isStreamingChat = false;
  bool _isStreamingNote = false;
  String _streamingTranscriptChat = '';
  String _streamingTranscriptNote = '';

  @override
  void initState() {
    super.initState();
    _initializeChats();
    _initCheetah();
    _initVoiceProcessor();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _noteController.dispose();
    _cheetahChat?.delete();
    _cheetahNote?.delete();
    _voiceProcessor?.stop();
    super.dispose();
  }

  Future<void> _initVoiceProcessor() async {
    _voiceProcessor = VoiceProcessor.instance;
  }

  Future<void> _initCheetah() async {
    try {
      const accessKey = AppConfig.cheetahAccessKey;
      final modelPath = await _loadModelAsset();
      _cheetahChat = await Cheetah.create(accessKey, modelPath, enableAutomaticPunctuation: true);
      _cheetahNote = await Cheetah.create(accessKey, modelPath, enableAutomaticPunctuation: true);
    } on CheetahException catch (e) {
      if (kDebugMode) print("Cheetah init error: ${e.message}");
    }
  }

  Future<String> _loadModelAsset() async {
    final byteData = await rootBundle.load('assets/cheetah_model.pv');
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/cheetah_model.pv');
    await tempFile.writeAsBytes(byteData.buffer.asUint8List());
    return tempFile.path;
  }

  Future<void> _initializeChats() async {
    await _loadChats();
    _startNewChat();
  }

  Future<void> _loadChats() async {
    final snapshot = await FirebaseFirestore.instance.collection('chats').orderBy('createdAt').get();
    setState(() {
      _chats = snapshot.docs.map((d) => {
        'id': d.id,
        'title': (d.data()['title'] as String?) ?? d.id,
      }).toList();
    });
  }

  void _startNewChat() {
    setState(() {
      _currentChatId = null;
      _messages.clear();
      _controller.clear();
      _notes.clear();
    });
  }

  Future<void> _selectChat(String chatId) async {
    if (mounted) Navigator.of(context).pop();
    setState(() {
      _currentChatId = chatId;
      _messages.clear();
      _controller.clear();
      _notes.clear();
    });
    final msgs = await FirebaseFirestore.instance
        .collection('chats').doc(chatId).collection('messages')
        .orderBy('timestamp').get();
    setState(() {
      _messages.addAll(msgs.docs.map((d) => ChatMessage(text: d['text'], isUser: d['isUser'])));
    });
    _scrollToBottom();
    await _loadNotes();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (_currentChatId == null) {
      final newLabel = 'chat${_chats.length + 1}';
      await FirebaseFirestore.instance.collection('chats').doc(newLabel).set({
        'createdAt': FieldValue.serverTimestamp(),
        'title': newLabel,
      });
      await _loadChats();
      setState(() => _currentChatId = newLabel);
    }
    setState(() => _messages.add(ChatMessage(text: text, isUser: true)));
    _controller.clear();
    _scrollToBottom();

    await FirebaseFirestore.instance
        .collection('chats').doc(_currentChatId).collection('messages')
        .add({'text': text, 'isUser': true, 'timestamp': FieldValue.serverTimestamp()});

    setState(() => _messages.add(const ChatMessage(text: '...', isUser: false)));
    final reply = await _callLlama(text);
    setState(() {
      _messages.removeLast();
      _messages.add(ChatMessage(text: reply, isUser: false));
    });

    await FirebaseFirestore.instance
        .collection('chats').doc(_currentChatId).collection('messages')
        .add({'text': reply, 'isUser': false, 'timestamp': FieldValue.serverTimestamp()});
    _scrollToBottom();
  }

//   Future<String> _callLlama(String userInput) async {
//     const apiUrl = 'PURDUE_ECN_SERVER_URL';
//     const modelName = 'meta-llama/Llama-3.2-3B-Instruct';
//     final functions = [
//       {
//         'name': 'extract_vitals',
//         'description': 'Extract vital signs',
//         'parameters': {
//           'type': 'object',
//           'properties': {
//             'name': {'type': 'string'},
//             'age': {'type': 'string'},
//             'blood_pressure': {'type': 'string'},
//             'heart_rate': {'type': 'string'},
//             'respiratory_rate': {'type': 'string'},
//             'temperature': {'type': 'string'},
//             'oxygen_saturation': {'type': 'string'},
//           }
//         }
//       }
//     ];
//     final payload = jsonEncode({
//       'model': modelName,
//       'messages': [
//         {'role': 'system', 'content': '''You are an extremely polite and helpful precision-focused clinical data extraction bot. Your SOLE purpose is to extract seven specific data from a user's text which you do PERFECTLY.
// RULES:
// 1.  You MUST call the `extract_vitals` function. Do not respond with conversational text. THIS IS THE MOST IMPORTANT!: If a vital sign is NOT MENTIONED in the user's text, you MUST use the string "NA" for its value in the function call.
// 2.  Extract ONLY the following seven vitals: name, age, blood_pressure, heart_rate, respiratory_rate, temperature, oxygen_saturation. No need to mention the units, only numbers. Store everything as a string.
// 3.  Do NOT invent, calculate, or infer any data. Only extract verbatim information. All vitals except name should be numbers, not words.
// 4.  The blood pressure should be in this format: systolic/diastolic. For example: 120/80
// 5.  Final Output should be strictly like this, not in json. Follow this pattern for ALL responses:
//
//    Name: NA,
//    Age: NA,
//    Blood Pressure: NA,
//    Heart Rate: NA,
//    Respiratory Rate: NA,
//    Body Temperature: NA,
//    Oxygen Saturation: NA'''},
//         {'role': 'user', 'content': userInput}
//       ],
//       'functions': functions,
//       'function_call': {'name': 'extract_vitals'}
//     });
//     try {
//       final resp = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: payload,
//       ).timeout(const Duration(seconds: 30));
//       if (resp.statusCode != 200) return 'API Error ${resp.statusCode}';
//       final data = jsonDecode(resp.body);
//       final msg = data['choices'][0]['message'];
//       if (msg.containsKey('function_call')) {
//         final args = jsonDecode(msg['function_call']['arguments']) as Map;
//         final b = StringBuffer();
//         args.forEach((k, v) {
//           final title = k.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
//           b.writeln('$title: $v');
//         });
//         return b.toString().trim();
//       }
//       return msg['content'] ?? 'Error: no content';
//     } catch (e) {
//       return 'Error: $e';
//     }
//   }

  Future<String> _callLlama(String userInput) async {
    final vitalsPrompt = '''
Extract patient vitals from this text. Format exactly as:
Name: [name or NA]
Age: [age or NA]
Blood Pressure: [systolic/diastolic or NA]
Heart Rate: [number or NA]
Respiratory Rate: [number or NA]
Body Temperature: [number or NA]
Oxygen Saturation: [number or NA]

Only extract what is explicitly mentioned. Use "NA" for missing data. Text: $userInput''';

    try {
      final resp = await http.post(
        Uri.parse(AppConfig.llmApiUrl),
        headers: {
          'Authorization': 'Bearer ${AppConfig.llmApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'template_key': 'default',
          'user_input': vitalsPrompt,
        }),
      ).timeout(const Duration(seconds: 30));

      if (resp.statusCode != 200) {
        return 'API Error ${resp.statusCode}: ${resp.body}';
      }

      final data = jsonDecode(resp.body);
      print('🔎 Raw response: $data'); // <-- Helps you debug the format

      // Handle OpenAI-style responses
      String? content;

      if (data['choices'] != null &&
          data['choices'] is List &&
          data['choices'].isNotEmpty) {
        final choice = data['choices'][0];
        if (choice is Map && choice['message'] != null) {
          content = choice['message']['content'];
        } else if (choice['text'] != null) {
          content = choice['text']; // Fallback if using completion API
        }
      }

      // Fallbacks for your previous response format
      content ??= data['response'] ?? data['output'] ?? data['text'];

      return content?.toString().trim() ?? 'Error: no content';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<void> _loadNotes() async {
    if (_currentChatId == null) { setState(() => _notes = []); return; }
    final snap = await FirebaseFirestore.instance
        .collection('chats').doc(_currentChatId).collection('notes')
        .orderBy('timestamp').get();
    setState(() {
      _notes = snap.docs.map((d) => {'id': d.id, 'content': d['content'] as String}).toList();
    });
  }

  Future<void> _saveNote() async {
    if (_currentChatId == null) return;
    final text = _noteController.text.trim();
    if (text.isEmpty) return;
    await FirebaseFirestore.instance.collection('chats').doc(_currentChatId)
        .collection('notes').add({'content': text, 'timestamp': FieldValue.serverTimestamp()});
    await _loadNotes();
    _noteController.clear();
  }

  Future<void> _updateNote() async {
    if (_currentChatId == null || _editingNoteId == null) return;
    final text = _noteController.text.trim();
    if (text.isEmpty) return;
    await FirebaseFirestore.instance.collection('chats').doc(_currentChatId)
        .collection('notes').doc(_editingNoteId).update({
      'content': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await _loadNotes();
    setState(() => _editingNoteId = null);
    _noteController.clear();
  }

  void _onNoteFrame(List<int> frame) async {
    if (_cheetahNote == null) return;
    try {
      final r = await _cheetahNote!.process(frame);
      if (r.transcript.isNotEmpty) {
        setState(() {
          _streamingTranscriptNote += r.transcript;
          _noteController
            ..text = _streamingTranscriptNote
            ..selection = TextSelection.fromPosition(TextPosition(offset: _streamingTranscriptNote.length));
        });
      }
      if (r.isEndpoint) {
        final f = await _cheetahNote!.flush();
        if (f.transcript.isNotEmpty) {
          setState(() {
            _streamingTranscriptNote += f.transcript;
            _noteController
              ..text = _streamingTranscriptNote
              ..selection = TextSelection.fromPosition(TextPosition(offset: _streamingTranscriptNote.length));
          });
        }
      }
    } catch (_) {}
  }

  void _onNoteError(VoiceProcessorException e) {
    if (kDebugMode) print('Note error: ${e.message}');
  }

  Future<void> _startNoteStreaming() async {
    if (_cheetahNote == null || _voiceProcessor == null) return;
    setState(() {
      _isStreamingNote = true;
      _streamingTranscriptNote = '';
    });
    final perm = await _voiceProcessor!.hasRecordAudioPermission();
    if (perm == true) {
      _voiceProcessor!
        ..addFrameListener(_onNoteFrame)
        ..addErrorListener(_onNoteError);
      await _voiceProcessor!.start(_cheetahNote!.frameLength, _cheetahNote!.sampleRate);
    } else {
      setState(() => _isStreamingNote = false);
    }
  }

  Future<void> _stopNoteStreaming() async {
    if (_voiceProcessor == null) return;
    await _voiceProcessor!.stop();
    _voiceProcessor!
      ..removeFrameListener(_onNoteFrame)
      ..removeErrorListener(_onNoteError);
    setState(() => _isStreamingNote = false);
  }

  void _toggleNoteStreaming() => _isStreamingNote ? _stopNoteStreaming() : _startNoteStreaming();

  void _onChatFrame(List<int> frame) async {
    if (_cheetahChat == null) return;
    try {
      final r = await _cheetahChat!.process(frame);
      if (r.transcript.isNotEmpty) {
        setState(() {
          _streamingTranscriptChat += r.transcript;
          _controller
            ..text = _streamingTranscriptChat
            ..selection = TextSelection.fromPosition(TextPosition(offset: _streamingTranscriptChat.length));
        });
      }
      if (r.isEndpoint) {
        final f = await _cheetahChat!.flush();
        if (f.transcript.isNotEmpty) {
          setState(() {
            _streamingTranscriptChat += f.transcript;
            _controller
              ..text = _streamingTranscriptChat
              ..selection = TextSelection.fromPosition(TextPosition(offset: _streamingTranscriptChat.length));
          });
        }
      }
    } catch (_) {}
  }

  void _onChatError(VoiceProcessorException e) {
    if (kDebugMode) print('Chat error: ${e.message}');
  }

  Future<void> _startChatStreaming() async {
    if (_cheetahChat == null || _voiceProcessor == null) return;
    setState(() {
      _isStreamingChat = true;
      _streamingTranscriptChat = '';
    });
    final perm = await _voiceProcessor!.hasRecordAudioPermission();
    if (perm == true) {
      _voiceProcessor!
        ..addFrameListener(_onChatFrame)
        ..addErrorListener(_onChatError);
      await _voiceProcessor!.start(_cheetahChat!.frameLength, _cheetahChat!.sampleRate);
    } else {
      setState(() => _isStreamingChat = false);
    }
  }

  Future<void> _stopChatStreaming() async {
    if (_voiceProcessor == null) return;
    await _voiceProcessor!.stop();
    _voiceProcessor!
      ..removeFrameListener(_onChatFrame)
      ..removeErrorListener(_onChatError);
    setState(() => _isStreamingChat = false);
    if (_streamingTranscriptChat.trim().isNotEmpty) {
      await _sendMessage(_streamingTranscriptChat.trim());
    }
  }

  void _toggleChatStreaming() => _isStreamingChat ? _stopChatStreaming() : _startChatStreaming();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _showNotesOverlay() async {
    if (_currentChatId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select or start a chat first')),
      );
      return;
    }
    await _loadNotes();
    _noteController.clear();
    _editingNoteId = null;
    _streamingTranscriptNote = '';
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (ctx, sc) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_isStreamingNote)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.red.withOpacity(.1),
                      border: Border.all(color: Colors.red.withOpacity(.3)),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    children: [
                      Icon(Icons.mic, color: Colors.red, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Streaming... tap to stop',
                        style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Notes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () {
                    if (_isStreamingNote) _stopNoteStreaming();
                    Navigator.pop(context);
                  }),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  controller: sc,
                  itemCount: _notes.length,
                  itemBuilder: (c, i) {
                    final note = _notes[i];
                    return ListTile(
                      title: Text(note['content']!, style: const TextStyle(color: Colors.white70)),
                      onTap: () {
                        setState(() {
                          _editingNoteId = note['id'];
                          _noteController.text = note['content']!;
                          _noteController.selection = TextSelection.fromPosition(TextPosition(offset: _noteController.text.length));
                        });
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('chats').doc(_currentChatId)
                              .collection('notes').doc(note['id']).delete();
                          await _loadNotes();
                        },
                      ),
                    );
                  },
                ),
              ),
              const Divider(color: Colors.white30),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(hintText: 'Type or speak a note…'),
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) {
                        if (_editingNoteId == null) _saveNote(); else _updateNote();
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: _isStreamingNote
                          ? Colors.redAccent
                          : Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(_isStreamingNote ? Icons.stop : Icons.mic),
                      color: Colors.black,
                      onPressed: _toggleNoteStreaming,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.save_alt),
                      color: Colors.black,
                      onPressed: () => _editingNoteId == null ? _saveNote() : _updateNote(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRenameDialog(String id, String currentTitle) {
    final ctrl = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename chat'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'New chat name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () {
            final nt = ctrl.text.trim();
            if (nt.isNotEmpty) _renameChat(id, nt);
            Navigator.pop(context);
          }, child: const Text('Rename')),
        ],
      ),
    );
  }

  void _showDeleteConfirm(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete chat?'),
        content: const Text('This will delete the chat and its messages and notes.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () {
            _deleteChat(id);
            Navigator.pop(context);
          }, child: const Text('Delete')),
        ],
      ),
    );
  }

  Future<void> _renameChat(String id, String newTitle) async {
    await FirebaseFirestore.instance.collection('chats').doc(id).update({'title': newTitle});
    await _loadChats();
  }

  Future<void> _deleteChat(String id) async {
    final msgs = await FirebaseFirestore.instance.collection('chats').doc(id).collection('messages').get();
    for (var d in msgs.docs) await d.reference.delete();
    final notes = await FirebaseFirestore.instance.collection('chats').doc(id).collection('notes').get();
    for (var d in notes.docs) await d.reference.delete();
    await FirebaseFirestore.instance.collection('chats').doc(id).delete();
    await _loadChats();
    if (_currentChatId == id) _startNewChat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Vitals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.light_mode),
            tooltip: 'Toggle theme',
            onPressed: () => AdaptiveTheme.of(context).toggleThemeMode(),
          ),
          IconButton(
            icon: const Icon(Icons.sticky_note_2_outlined),
            tooltip: 'Notes',
            onPressed: _showNotesOverlay,
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('New chat'),
                onTap: () {
                  Navigator.pop(context);
                  _startNewChat();
                },
              ),
              const Divider(color: Colors.white30),
              Expanded(
                child: ListView.builder(
                  itemCount: _chats.length,
                  itemBuilder: (c, i) {
                    final chat = _chats[i];
                    final id = chat['id']!;
                    final title = chat['title']!;
                    return ListTile(
                      title: Text(title),
                      selected: id == _currentChatId,
                      onTap: () => _selectChat(id),
                      trailing: PopupMenuButton<String>(
                        onSelected: (choice) {
                          if (choice == 'Rename') {
                            _showRenameDialog(id, title);
                          } else {
                            _showDeleteConfirm(id);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'Rename', child: Text('Rename')),
                          PopupMenuItem(value: 'Delete', child: Text('Delete')),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          if (_currentChatId == null || _messages.isEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36.0),
                    child: Text(
                      'Start a new patient conversation to record vitals.',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.13),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _messages.length,
                  itemBuilder: (c, i) {
                    final m = _messages[i];
                    if (!m.isUser && m.text == '...') {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 100,
                          height: 40,
                          child: Lottie.asset(AppConfig.typingAnimation),
                        ),
                      );
                    }
                    return Align(
                      alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 300),
                          builder: (ctx, v, child) => Transform.scale(scale: v, child: child),
                          child: ChatBubble(text: m.text, isUser: m.isUser, child: SizedBox()),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(hintText: 'Type or speak vitals…'),
                          style: Theme.of(context).textTheme.bodyMedium,
                          onSubmitted: _sendMessage,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(_isStreamingChat ? Icons.stop : Icons.mic,
                            color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black,
                          ),
                          onPressed: _toggleChatStreaming,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.send,
                            color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black,
                          ),
                          onPressed: () => _sendMessage(_controller.text),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isStreamingChat)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Lottie.asset(AppConfig.voiceWaveAnimation),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _streamingTranscriptChat.isEmpty ? 'Speak now…' : _streamingTranscriptChat,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleChatStreaming,
                        icon: const Icon(Icons.stop),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
