import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'models/player.dart';
import 'models/task.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Добавь этот импорт!

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru_RU', null); // Инициализация локали
  runApp(const LifePlannerApp());
}

class LifePlannerApp extends StatelessWidget {
  const LifePlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Planner RPG',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LifePlannerHomePage(),
    );
  }
}

class LifePlannerHomePage extends StatefulWidget {
  const LifePlannerHomePage({super.key});

  @override
  State<LifePlannerHomePage> createState() => _LifePlannerHomePageState();
}

class _LifePlannerHomePageState extends State<LifePlannerHomePage> {
  // Имитация работы с ИИ (на собесе скажешь, что это интерфейс для API)
  Future<String> _predictStatWithAI(String taskTitle) async {
    // Тут в будущем будет вызов OpenAI API
    String title = taskTitle.toLowerCase();
    if (title.contains('зал') || title.contains('тренировка')) return 'strength';
    if (title.contains('читать') || title.contains('учить')) return 'intelligence';
    if (title.contains('бег') || title.contains('плавание')) return 'endurance';
    return 'willpower'; // По умолчанию
  }
  int _currentIndex = 0;
  final List<Task> _tasks = [];
  final Player _player = Player();
  DateTime _selectedDate = DateTime.now(); // НОВО: выбранная дата

  // Вспомогательная функция для форматирования времени
  String _formatTimeOfDay(TimeOfDay? time, BuildContext context) {
    if (time == null) return 'Не выбрано';
    return time.format(context);
  }

  // Получение цвета для стата
  Color _getStatColor(String statType) {
    switch (statType) {
      case 'strength':
        return Colors.red;
      case 'agility':
        return Colors.green;
      case 'intelligence':
        return Colors.blue;
      case 'willpower':
        return Colors.purple;
      case 'endurance':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Получение задач на выбранную дату
  List<Task> _getTasksForDate(DateTime date) {
    return _tasks.where((task) =>
    task.date.year == date.year &&
        task.date.month == date.month &&
        task.date.day == date.day
    ).toList();
  }

  // Добавление задачи
  void _addTask(Task task) {
    setState(() {
      _tasks.add(task);
    });
  }

  // Редактирование задачи
  void _editTask(Task oldTask, Task newTask) {
    setState(() {
      final index = _tasks.indexOf(oldTask);
      if (index != -1) {
        _tasks[index] = newTask;
      }
    });
  }

  // Удаление задачи
  void _deleteTask(Task task) {
    setState(() {
      _tasks.remove(task);
    });
  }

  // Переключение статуса выполнения задачи
  void _toggleTaskCompletion(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
      if (task.isCompleted) {
        // Начисляем статы за выполненную задачу
        switch (task.statType) {
          case 'strength':
            _player.strength += 10;
            break;
          case 'agility':
            _player.agility += 10;
            break;
          case 'intelligence':
            _player.intelligence += 10;
            break;
          case 'willpower':
            _player.willpower += 10;
            break;
          case 'endurance':
            _player.endurance += 10;
            break;
        }
        // Начисляем Life Points
        _player.lifePoints += 5;

        // Проверка на повышение уровня (каждые 100 очков)
        int totalStats = _player.strength + _player.agility +
            _player.intelligence + _player.willpower +
            _player.endurance;
        _player.level = 1 + (totalStats ~/ 100);
      }
    });
  }

  // Диалог добавления/редактирования задачи
  void _showTaskDialog({Task? taskToEdit}) {
    final titleController = TextEditingController(text: taskToEdit?.title ?? '');
    String selectedStat = taskToEdit?.statType ?? 'strength';
    TimeOfDay? startTime = taskToEdit?.startTime;
    TimeOfDay? endTime = taskToEdit?.endTime;
    DateTime selectedDate = taskToEdit?.date ?? _selectedDate; // НОВО: дата из задачи или выбранная

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(taskToEdit == null ? 'Добавить задачу' : 'Редактировать задачу'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Название задачи',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // НОВО: выбор даты
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Дата'),
                            Text(
                              DateFormat('dd.MM.yyyy').format(selectedDate),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedStat,
                      decoration: const InputDecoration(
                        labelText: 'Тип стата',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        'strength', 'agility', 'intelligence',
                        'willpower', 'endurance', 'neutral'
                      ].map((stat) {
                        return DropdownMenuItem(
                          value: stat,
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                color: _getStatColor(stat),
                              ),
                              const SizedBox(width: 8),
                              Text(stat),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedStat = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Время начала
                    GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: startTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            startTime = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Время начала'),
                            Text(
                              _formatTimeOfDay(startTime, context),
                              style: TextStyle(
                                color: startTime != null ? Colors.black : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Время окончания
                    GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: endTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            endTime = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Время окончания'),
                            Text(
                              _formatTimeOfDay(endTime, context),
                              style: TextStyle(
                                color: endTime != null ? Colors.black : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        startTime != null &&
                        endTime != null) {

                      final newTask = Task(
                        title: titleController.text,
                        statType: selectedStat,
                        startTime: startTime!,
                        endTime: endTime!,
                        isCompleted: taskToEdit?.isCompleted ?? false,
                        date: selectedDate,
                      );

                      if (taskToEdit == null) {
                        _addTask(newTask);
                      } else {
                        _editTask(taskToEdit, newTask);
                      }

                      Navigator.pop(context);
                    }
                  },
                  child: Text(taskToEdit == null ? 'Добавить' : 'Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Трата Life Points (тестовая функция)
  void _spendLifePoints() {
    setState(() {
      if (_player.lifePoints >= 10) {
        _player.lifePoints -= 10;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Потрачено 10 LP! Скоро здесь будет вход в подземелье...'),
            backgroundColor: Colors.amber,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Недостаточно LP! Выполняйте задачи чтобы заработать очки.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Planner RPG'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // НОВО: индикатор выбранной даты в AppBar
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              DateFormat('dd.MM.yyyy').format(_selectedDate),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          PlannerScreen(
            tasks: _getTasksForDate(_selectedDate),
            allTasks: _tasks,
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
            onToggle: _toggleTaskCompletion,
            onDelete: _deleteTask,
            onEdit: _showTaskDialog,
            onAdd: () => _showTaskDialog(),
            getStatColor: _getStatColor,
            formatTime: _formatTimeOfDay,
          ),
          AvatarScreen(
            player: _player,
            onSpendLP: _spendLifePoints,
            getStatColor: _getStatColor,
          ),
          const DungeonScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Планировщик',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Аватар',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.castle),
            label: 'Подземелье',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}

// Экран планировщика с календарем
class PlannerScreen extends StatelessWidget {
  final List<Task> tasks;
  final List<Task> allTasks;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Function(Task) onToggle;
  final Function(Task) onDelete;
  final Function({Task? taskToEdit}) onEdit;
  final VoidCallback onAdd;
  final Color Function(String) getStatColor;
  final String Function(TimeOfDay?, BuildContext) formatTime;

  const PlannerScreen({
    super.key,
    required this.tasks,
    required this.allTasks,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
    required this.onAdd,
    required this.getStatColor,
    required this.formatTime,
  });

  // Получение количества задач на день
  int _getTasksCountForDay(DateTime date) {
    return allTasks.where((task) =>
    task.date.year == date.year &&
        task.date.month == date.month &&
        task.date.day == date.day
    ).length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Календарь
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CalendarDatePicker(
            initialDate: selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            onDateChanged: onDateSelected,
            currentDate: DateTime.now(),
          ),
        ),

        // Заголовок с количеством задач
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, dd MMMM yyyy', 'ru_RU').format(selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tasks.length} задач',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              // Кнопка быстрого добавления на текущий день
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Добавить задачу'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Список задач
        Expanded(
          child: tasks.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Нет задач на этот день',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Нажмите + чтобы добавить задачу',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) => onToggle(task),
                    activeColor: getStatColor(task.statType),
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? Colors.grey : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: getStatColor(task.statType).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          task.statType,
                          style: TextStyle(
                            color: getStatColor(task.statType),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${formatTime(task.startTime, context)} - ${formatTime(task.endTime, context)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Редактировать'),
                        ),
                        value: 'edit',
                      ),
                      const PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Удалить', style: TextStyle(color: Colors.red)),
                        ),
                        value: 'delete',
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit(taskToEdit: task);
                      } else if (value == 'delete') {
                        onDelete(task);
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Экран аватара (без изменений)
class AvatarScreen extends StatelessWidget {
  final Player player;
  final VoidCallback onSpendLP;
  final Color Function(String) getStatColor;

  const AvatarScreen({
    super.key,
    required this.player,
    required this.onSpendLP,
    required this.getStatColor,
  });

  Widget _buildStatBar(String label, int value, Color color) {
    double progress = (value % 100) / 100.0;
    int level = (value / 100).floor();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text('Ур. $level ($value очков)'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 3),
              image: const DecorationImage(
                image: AssetImage('assets/avatar.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text(
                      'Уровень',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${player.level}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                Column(
                  children: [
                    const Text(
                      'LP',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${player.lifePoints}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Характеристики',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildStatBar('Сила', player.strength, Colors.red),
                _buildStatBar('Ловкость', player.agility, Colors.green),
                _buildStatBar('Интеллект', player.intelligence, Colors.blue),
                _buildStatBar('Сила воли', player.willpower, Colors.purple),
                _buildStatBar('Выносливость', player.endurance, Colors.orange),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSpendLP,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Потратить 10 LP (Тест)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Экран подземелья
class DungeonScreen extends StatelessWidget {
  const DungeonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.castle,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          const Text(
            'Подземелье',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Базовое подземелье -- будет расширено позже',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Планы на будущее:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildFeatureRow('Комнаты и этажи'),
                _buildFeatureRow('Монстры и боссы'),
                _buildFeatureRow('Лут и экипировка'),
                _buildFeatureRow('Анимация боя'),
                _buildFeatureRow('Награды за LP'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[400], size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
