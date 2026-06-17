import 'package:flutter/material.dart';

// ── 1. ENTRY POINT ──────────────────────────────────
void main() => runApp(const TideApp());

// ── 2. DESIGN TOKENS (your S01 Figma colours) ───────
class TideColors {
  static const primary = Color(0xFF5A8FB0);
  static const ink = Color(0xFF1A1A1A);
  static const inkMuted = Color(0xFF6B6B6B);
  static const surface = Color(0xFFFCFAF3);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFEFE9D8);
  static const priHigh = Color(0xFFC76A55);
  static const priMed = Color(0xFFC9A23A);
  static const priLow = Color(0xFF7A9165);
}

// ── 3. DATA MODEL ───────────────────────────────────
class Task {
  final String title;
  final String priority;
  bool isDone;
  Task({required this.title, this.priority = 'med', this.isDone = false});

  Color get priorityColor {
    if (priority == 'high') return TideColors.priHigh;
    if (priority == 'low') return TideColors.priLow;
    return TideColors.priMed;
  }
}

// ── 4. ROOT APP WIDGET ──────────────────────────────
class TideApp extends StatelessWidget {
  const TideApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(scaffoldBackgroundColor: TideColors.surface),
        home: const HomeScreen(),
      );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // THE STATE — the master task list
  final List<Task> tasks = [
    Task(title: 'Submit DBMS assignment', priority: 'high'),
    Task(title: 'Call Amma 6 PM'),
    Task(title: 'Gym — leg day', priority: 'low'),
    Task(title: 'Review Figma prototype', isDone: true),
  ];
  void _toggle(Task t) => setState(() => t.isDone = !t.isDone);
  void _add(String title, String priority) {
    if (title.trim().isEmpty) return;
    setState(() => tasks.add(Task(title: title.trim(), priority: priority)));
  }

  void _openSheet() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: TideColors.card,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (_) => AddTaskSheet(onAdd: _add),
      );
  @override
  Widget build(BuildContext context) {
    final remaining = tasks.where((t) => !t.isDone).length;
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Good evening 👋',
              style: TextStyle(fontSize: 14, color: TideColors.inkMuted)),
          const Text('Today',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: TideColors.ink)),
          Text('$remaining tasks remaining',
              style: const TextStyle(color: TideColors.inkMuted)),
          const SizedBox(height: 24),
          Expanded(
              child: ListView(
            children: tasks
                .map((t) => TaskCard(task: t, onTap: () => _toggle(t)))
                .toList(),
          )),
        ]),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: _openSheet,
        backgroundColor: TideColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ── 6a. TASKCARD (your Figma card-task component) ───
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  const TaskCard({super.key, required this.task, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TideColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TideColors.border),
          ),
          child: Row(children: [
            Container(
              // checkbox
              width: 24, height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: TideColors.primary, width: 2),
                color: task.isDone ? TideColors.priLow : Colors.transparent,
              ),
              child: task.isDone
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(task.title,
                    style: TextStyle(
                      fontSize: 16,
                      color: task.isDone ? TideColors.inkMuted : TideColors.ink,
                      decoration: task.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ))),
            Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: task.priorityColor)), // dot
          ]),
        ),
      );
}

// ── 6b. ADDTASKSHEET (the slide-up bottom sheet) ────
class AddTaskSheet extends StatefulWidget {
  final void Function(String, String) onAdd;
  const AddTaskSheet({super.key, required this.onAdd});
  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _c = TextEditingController();
  String _priority = 'med';
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom:
                MediaQuery.of(context).viewInsets.bottom + 24), // keyboard-safe
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New task',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                  controller: _c,
                  autofocus: true,
                  decoration: InputDecoration(
                      hintText: 'What needs doing?',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 16),
              Row(
                  children: ['high', 'med', 'low'].map((p) {
                final sel = _priority == p;
                return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                        label: Text(p.toUpperCase()),
                        selected: sel,
                        selectedColor: TideColors.primary,
                        labelStyle: TextStyle(
                            fontSize: 12,
                            color: sel ? Colors.white : TideColors.inkMuted),
                        onSelected: (_) => setState(() => _priority = p)));
              }).toList()),
              const SizedBox(height: 24),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: TideColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () {
                        widget.onAdd(_c.text, _priority);
                        Navigator.pop(context);
                      },
                      child: const Text('Save Task',
                          style:
                              TextStyle(color: Colors.white, fontSize: 16)))),
            ]),
      );
}