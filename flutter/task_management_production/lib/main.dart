import 'package:flutter/material.dart';

void main() {
  runApp(const TaskApp());
}

// ========== THEME & CONSTANTS ==========

class AppTheme {
  static const Color primary       = Color(0xFF6C63FF);
  static const Color primaryDark   = Color(0xFF4B44CC);
  static const Color background    = Color(0xFFF4F5F9);
  static const Color surface       = Colors.white;

  static const Color highColor     = Color(0xFFE53935);
  static const Color mediumColor   = Color(0xFFFB8C00);
  static const Color lowColor      = Color(0xFF43A047);

  static const Color textPrimary   = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          background: background,
          surface: surface,
        ),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: highColor, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: highColor, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
        ),
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 6,
        ),
      );
}

// ========== MODELS ==========

enum Priority { high, medium, low }

extension PriorityExtension on Priority {
  String get label {
    switch (this) {
      case Priority.high:   return 'High';
      case Priority.medium: return 'Medium';
      case Priority.low:    return 'Low';
    }
  }

  Color get color {
    switch (this) {
      case Priority.high:   return AppTheme.highColor;
      case Priority.medium: return AppTheme.mediumColor;
      case Priority.low:    return AppTheme.lowColor;
    }
  }

  IconData get icon {
    switch (this) {
      case Priority.high:   return Icons.keyboard_double_arrow_up_rounded;
      case Priority.medium: return Icons.drag_handle_rounded;
      case Priority.low:    return Icons.keyboard_double_arrow_down_rounded;
    }
  }
}

// 🎓 Viva Q: "What are enums used for in sort/filter logic?"
// A: Enums represent a fixed set of named constants. Using them for sort/filter
//    options is safer than using raw strings — the compiler catches typos, and
//    switch statements can be exhaustive.
enum SortOption { dueDate, priority, title }
enum FilterOption { all, high, medium, low }

class Task {
  final String id;
  String title;
  Priority priority;
  DateTime dueDate;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    required this.dueDate,
    this.isCompleted = false,
  });
}

// ========== MAIN APP ==========

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskMaster',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const TaskDashboardScreen(),
    );
  }
}

// ========== SCREENS ==========

// 🎓 Viva Q: "Why SingleTickerProviderStateMixin?"
// A: Provides a single vsync Ticker for the TabController animation — efficient
//    because only one animation runs at a time in this widget.
class TaskDashboardScreen extends StatefulWidget {
  const TaskDashboardScreen({super.key});

  @override
  State<TaskDashboardScreen> createState() => _TaskDashboardScreenState();
}

class _TaskDashboardScreenState extends State<TaskDashboardScreen>
    with SingleTickerProviderStateMixin {

  // ---- Seed data ----
  final List<Task> _tasks = [
    Task(id: '1', title: 'Design app wireframes',   priority: Priority.high,   dueDate: DateTime.now().add(const Duration(days: 1))),
    Task(id: '2', title: 'Write unit tests',         priority: Priority.medium, dueDate: DateTime.now().add(const Duration(days: 3))),
    Task(id: '3', title: 'Read Flutter documentation', priority: Priority.low, dueDate: DateTime.now().add(const Duration(days: 7)), isCompleted: true),
    Task(id: '4', title: 'Fix critical login bug',   priority: Priority.high,   dueDate: DateTime.now()),
    Task(id: '5', title: 'Weekly team sync meeting', priority: Priority.medium, dueDate: DateTime.now().add(const Duration(days: 2)), isCompleted: true),
  ];

  late TabController _tabController;

  // ---- Search / Sort / Filter state ----
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SortOption _sortOption = SortOption.dueDate;
  FilterOption _filterOption = FilterOption.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) setState(() {});
    });
    // Rebuild list on every keystroke in the search field
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose(); // Prevent memory leak
    super.dispose();
  }

  // ---- Computed filtered + sorted list ----

  // 🎓 Viva Q: "Walk me through how the list is filtered and sorted."
  // A: We first filter by tab (all/pending/completed), then by priority if a
  //    priority filter is active, then by search query. Finally we sort a copy
  //    of the filtered list using Dart's List.sort() with a Comparator.
  List<Task> get _processedTasks {
    // Step 1: tab filter
    List<Task> result;
    switch (_tabController.index) {
      case 1:  result = _tasks.where((t) => !t.isCompleted).toList(); break;
      case 2:  result = _tasks.where((t) => t.isCompleted).toList();  break;
      default: result = List.from(_tasks);
    }

    // Step 2: priority filter
    if (_filterOption != FilterOption.all) {
      final priorityMap = {
        FilterOption.high:   Priority.high,
        FilterOption.medium: Priority.medium,
        FilterOption.low:    Priority.low,
      };
      result = result.where((t) => t.priority == priorityMap[_filterOption]).toList();
    }

    // Step 3: search filter
    if (_searchQuery.isNotEmpty) {
      result = result.where((t) => t.title.toLowerCase().contains(_searchQuery)).toList();
    }

    // Step 4: sort
    // 🎓 Viva Q: "What does List.sort() do and what is a Comparator?"
    // A: sort() mutates the list in-place using a comparison function.
    //    A Comparator returns negative if a < b, 0 if equal, positive if a > b.
    switch (_sortOption) {
      case SortOption.dueDate:
        result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case SortOption.priority:
        // high(0) < medium(1) < low(2) — lower index = higher urgency
        result.sort((a, b) => a.priority.index.compareTo(b.priority.index));
        break;
      case SortOption.title:
        result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }

    return result;
  }

  int get _completedCount => _tasks.where((t) => t.isCompleted).length;

  // ---- Mutators ----

  void _toggleTask(String id) {
    setState(() {
      final task = _tasks.firstWhere((t) => t.id == id);
      task.isCompleted = !task.isCompleted;
    });
  }

  void _deleteTask(String id) {
    setState(() => _tasks.removeWhere((t) => t.id == id));
  }

  void _addTask(Task task) {
    setState(() => _tasks.add(task));
  }

  // ---- Bottom Sheet ----
  void _showAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskBottomSheet(onAdd: _addTask),
    );
  }

  // ---- Sort / Filter bottom sheet ----
  // 🎓 Viva Q: "Why use a bottom sheet for sort/filter instead of a dropdown?"
  // A: Bottom sheets are more touch-friendly on mobile — they provide bigger
  //    tap targets and feel more native on Android/iOS than dropdown menus.
  void _showSortFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SortFilterSheet(
        currentSort:   _sortOption,
        currentFilter: _filterOption,
        onApply: (sort, filter) {
          setState(() {
            _sortOption   = sort;
            _filterOption = filter;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final processed = _processedTasks;
    final bool hasActiveFilters =
        _sortOption != SortOption.dueDate || _filterOption != FilterOption.all;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskMaster'),
        leading: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Icon(Icons.check_circle_outline_rounded, color: Colors.white),
        ),
        actions: [
          // Sort/Filter button — badge appears when non-default options are active
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(Icons.tune_rounded, color: Colors.white),
                  tooltip: 'Sort & Filter',
                  onPressed: _showSortFilterSheet,
                ),
                // 🎓 Viva Q: "What is this dot pattern called?"
                // A: A notification badge. It uses a Stack to overlay a small
                //    colored circle on top of an icon — a common UX pattern.
                if (hasActiveFilters)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.amberAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primary, width: 1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ---- Progress Card ----
          ProgressSection(completed: _completedCount, total: _tasks.length),

          // ---- Search Bar ----
          // 🎓 Viva Q: "How does live search work here?"
          // A: TextEditingController has an addListener callback. Every keystroke
          //    calls setState() updating _searchQuery, which triggers a rebuild
          //    and the getter re-filters the list with the new query.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks…',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppTheme.textSecondary, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // ---- Active filter chips row ----
          if (hasActiveFilters)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Row(
                children: [
                  const Icon(Icons.filter_list_rounded, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Sorted by: ${_sortOption.label}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  if (_filterOption != FilterOption.all) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _filterOption.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _filterOption.color.withOpacity(0.4)),
                      ),
                      child: Text(
                        _filterOption.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _filterOption.color,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() {
                      _sortOption   = SortOption.dueDate;
                      _filterOption = FilterOption.all;
                    }),
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ---- Task List ----
          Expanded(
            child: processed.isEmpty
                ? EmptyState(
                    isSearching: _searchQuery.isNotEmpty || hasActiveFilters,
                    onAddTask: _showAddTaskSheet,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: processed.length,
                    // 🎓 Viva Q: "Why ListView.builder over ListView?"
                    // A: .builder is lazy — it only instantiates widgets that are
                    //    currently visible. For large lists this saves memory.
                    itemBuilder: (context, index) {
                      final task = processed[index];
                      return TaskCard(
                        key: ValueKey(task.id),
                        task: task,
                        onToggle: () => _toggleTask(task.id),
                        onDelete: () => _deleteTask(task.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ========== WIDGETS ==========

// ---------- Progress Section ----------

class ProgressSection extends StatelessWidget {
  final int completed;
  final int total;

  const ProgressSection({super.key, required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final double progress = total == 0 ? 0.0 : completed / total;
    final int percentage = (progress * 100).round();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Today's Progress",
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    '$completed of $total tasks completed',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                child: Center(
                  child: Text('$percentage%',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Task Card ----------

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskCard({super.key, required this.task, required this.onToggle, required this.onDelete});

  // 🎓 Viva Q: "Explain the date formatting logic."
  // A: We strip the time component by constructing DateTime with year/month/day
  //    only, then compute inDays difference. This avoids edge cases where
  //    "today at 11pm" minus "now at 1pm" returns 0 days incorrectly.
  String _formatDate(DateTime date) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d     = DateTime(date.year, date.month, date.day);
    final diff  = d.difference(today).inDays;
    if (diff < 0)  return '⚠ Overdue';
    if (diff == 0) return 'Due Today';
    if (diff == 1) return 'Due Tomorrow';
    if (diff <= 7) return 'In $diff days';
    return 'Due ${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // 🎓 Viva Q: "How does Dismissible work?"
    // A: Wraps a widget and listens for horizontal drag. onDismissed fires after
    //    animation. You MUST remove the item from data in onDismissed or Flutter
    //    throws an error expecting the item to be gone.
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
            color: Colors.red.shade400, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text('Delete',
                style: TextStyle(
                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      // 🎓 Viva Q: "What is AnimatedContainer?"
      // A: Smoothly interpolates between old and new decoration values over
      //    `duration` when setState is called — zero boilerplate animation.
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: task.isCompleted ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: task.priority.color.withOpacity(task.isCompleted ? 0.25 : 0.75),
            width: 2,
          ),
          boxShadow: task.isCompleted
              ? []
              : [
                  BoxShadow(
                    color: task.priority.color.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (_) => onToggle(),
            activeColor: task.priority.color,
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: task.isCompleted ? AppTheme.textSecondary : AppTheme.textPrimary,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              decorationColor: AppTheme.textSecondary,
            ),
          ),
          // StatusChip removed — checkbox + strikethrough already communicate status
          // cleanly. Redundant chips added visual clutter.
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                PriorityBadge(priority: task.priority),
                const SizedBox(width: 8),
                Icon(Icons.schedule_rounded, size: 13, color: AppTheme.textSecondary),
                const SizedBox(width: 3),
                Text(
                  _formatDate(task.dueDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: task.dueDate.isBefore(DateTime.now()) && !task.isCompleted
                        ? Colors.red.shade400
                        : AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- Priority Badge ----------

class PriorityBadge extends StatelessWidget {
  final Priority priority;
  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: priority.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: priority.color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(priority.icon, size: 12, color: priority.color),
          const SizedBox(width: 4),
          Text(
            priority.label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: priority.color),
          ),
        ],
      ),
    );
  }
}

// ---------- Empty State ----------

// 🎓 Viva Q: "Why does EmptyState take parameters now?"
// A: It behaves differently in two contexts: when there are genuinely no tasks,
//    we show an onboarding CTA. When the user searched and got no results, we
//    show a 'no results' message instead. Passing context via constructor keeps
//    the widget reusable without internal logic knowing about parent state.
class EmptyState extends StatelessWidget {
  final bool isSearching;
  final VoidCallback onAddTask;

  const EmptyState({super.key, required this.isSearching, required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustrated icon in a soft circle background
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching
                    ? Icons.search_off_rounded
                    : Icons.rocket_launch_rounded,
                size: 52,
                color: AppTheme.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearching ? 'No tasks found' : 'Your task list is clear!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isSearching
                  ? 'Try a different search term\nor adjust your filters.'
                  : 'You\'re all caught up. Add your first task\nand start crushing your goals 🚀',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
            ),
            // Only show the CTA when there are genuinely no tasks, not when filtering
            if (!isSearching) ...[
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: onAddTask,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Your First Task',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------- Sort & Filter Bottom Sheet ----------

// 🎓 Viva Q: "Why is SortFilterSheet a StatefulWidget?"
// A: It has its own temporary local state for the selected sort/filter options.
//    The user can change selections without affecting the parent — they only
//    apply when 'Apply' is tapped. This is the "local draft state" pattern.
class SortFilterSheet extends StatefulWidget {
  final SortOption currentSort;
  final FilterOption currentFilter;
  final Function(SortOption, FilterOption) onApply;

  const SortFilterSheet({
    super.key,
    required this.currentSort,
    required this.currentFilter,
    required this.onApply,
  });

  @override
  State<SortFilterSheet> createState() => _SortFilterSheetState();
}

class _SortFilterSheetState extends State<SortFilterSheet> {
  late SortOption _sort;
  late FilterOption _filter;

  @override
  void initState() {
    super.initState();
    // Initialise with the parent's current values
    _sort   = widget.currentSort;
    _filter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Sort & Filter',
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 20),

          // ---- Sort Options ----
          const _FieldLabel(text: 'Sort by'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: SortOption.values.map((opt) {
              final bool selected = _sort == opt;
              return ChoiceChip(
                label: Text(opt.label),
                selected: selected,
                onSelected: (_) => setState(() => _sort = opt),
                selectedColor: AppTheme.primary,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: Colors.grey.shade100,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ---- Filter by Priority ----
          const _FieldLabel(text: 'Filter by priority'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: FilterOption.values.map((opt) {
              final bool selected = _filter == opt;
              final Color chipColor = opt == FilterOption.all
                  ? AppTheme.primary
                  : opt.color;
              return ChoiceChip(
                label: Text(opt.label),
                selected: selected,
                onSelected: (_) => setState(() => _filter = opt),
                selectedColor: chipColor,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: Colors.grey.shade100,
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // ---- Apply Button ----
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_sort, _filter);
                Navigator.of(context).pop();
              },
              child: const Text('Apply',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Add Task Bottom Sheet ----------

// 🎓 Viva Q: "Why is AddTaskBottomSheet StatefulWidget?"
// A: It owns local form state (title, priority, date) that only matters while
//    the sheet is open. When dismissed, this state is cleanly disposed.
class AddTaskBottomSheet extends StatefulWidget {
  final Function(Task) onAdd;
  const AddTaskBottomSheet({super.key, required this.onAdd});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  // 🎓 Viva Q: "What is GlobalKey<FormState>?"
  // A: Gives programmatic access to the Form widget. Calling
  //    _formKey.currentState!.validate() triggers all field validators.
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  Priority _selectedPriority = Priority.medium;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _titleController.dispose(); // Prevent memory leak
    super.dispose();
  }

  // 🎓 Viva Q: "Why is _pickDate async and uses await?"
  // A: showDatePicker shows a dialog and returns a Future<DateTime?> — it
  //    completes asynchronously when the user picks a date or cancels.
  //    We await it so the code below only runs once the dialog is dismissed.
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onAdd(Task(
        id:       DateTime.now().millisecondsSinceEpoch.toString(),
        title:    _titleController.text.trim(),
        priority: _selectedPriority,
        dueDate:  _selectedDate,
      ));
      Navigator.of(context).pop();
    }
  }

  // ---- Relative date label for the date picker display ----
  // 🎓 Viva Q: "Where is this used and why is it here and not in TaskCard?"
  // A: TaskCard also has a similar method. Both are private helpers on their
  //    respective State/StatelessWidget classes. They're intentionally separate
  //    because TaskCard's version shows "⚠ Overdue" while this one only shows
  //    future-relative labels — the same method wouldn't suit both contexts.
  String _relativeDateLabel(DateTime date) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d     = DateTime(date.year, date.month, date.day);
    final diff  = d.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff <= 7) return 'In $diff days';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // 🎓 Viva Q: "What is DraggableScrollableSheet?"
    // A: A sheet that the user can drag to different height fractions.
    //    initialChildSize is the starting height as a fraction of screen height.
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          // viewInsets.bottom = keyboard height; keeps fields visible above keyboard
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24, right: 24, top: 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Add New Task',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                const Text('Fill in the details below',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                const SizedBox(height: 24),

                // ---- Title Field ----
                const _FieldLabel(text: 'Task Title *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Complete project report',
                    prefixIcon: Icon(Icons.title_rounded, color: AppTheme.primary),
                  ),
                  // 🎓 Viva Q: "What is a Form validator?"
                  // A: A function receiving the current value; returns an error
                  //    String if invalid, or null if valid. Called by validate().
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Task title cannot be empty';
                    }
                    if (value.trim().length < 3) {
                      return 'Title must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ---- Priority Selector ----
                const _FieldLabel(text: 'Priority Level'),
                const SizedBox(height: 10),
                Row(
                  children: Priority.values.map((p) {
                    final bool isSelected = _selectedPriority == p;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedPriority = p),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? p.color : p.color.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: p.color, width: isSelected ? 2 : 1),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: p.color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                                  : [],
                            ),
                            child: Column(
                              children: [
                                Icon(p.icon, color: isSelected ? Colors.white : p.color, size: 22),
                                const SizedBox(height: 5),
                                Text(
                                  p.label,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : p.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // ---- Due Date Picker ----
                const _FieldLabel(text: 'Due Date'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: AppTheme.primary),
                        const SizedBox(width: 12),
                        // ---- IMPROVED: relative label + numeric date ----
                        // 🎓 Viva Q: "Why show both relative and absolute date?"
                        // A: The relative label ('Tomorrow') is cognitively faster
                        //    to parse. The numeric date provides precision. Together
                        //    they reduce user error when picking deadlines.
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _relativeDateLabel(_selectedDate),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: const TextStyle(
                                  fontSize: 11, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ---- Submit Button ----
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.add_task_rounded),
                    label: const Text('Add Task',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- Field Label (reusable) ----------

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        color: AppTheme.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}

// ========== EXTENSIONS (helpers for labels/colors on enums) ==========

extension SortOptionExtension on SortOption {
  String get label {
    switch (this) {
      case SortOption.dueDate:  return 'Due Date';
      case SortOption.priority: return 'Priority';
      case SortOption.title:    return 'Title';
    }
  }
}

extension FilterOptionExtension on FilterOption {
  String get label {
    switch (this) {
      case FilterOption.all:    return 'All';
      case FilterOption.high:   return 'High';
      case FilterOption.medium: return 'Medium';
      case FilterOption.low:    return 'Low';
    }
  }

  Color get color {
    switch (this) {
      case FilterOption.all:    return AppTheme.primary;
      case FilterOption.high:   return AppTheme.highColor;
      case FilterOption.medium: return AppTheme.mediumColor;
      case FilterOption.low:    return AppTheme.lowColor;
    }
  }
}