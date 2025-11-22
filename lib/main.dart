import 'package:flutter/material.dart';
// imported shared preferences package
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:todo_list/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreen(),
    );
  }
}

class Todo {
  final int id;
  final String text;
  bool isDone;

  Todo({required this.id, required this.text, this.isDone = false});

  Map<String, dynamic> toMap() {
    return {'id': id, 'text': text, 'isDone': isDone};
  }

  static Todo fromMap(Map<String, dynamic> map) {
    return Todo(id: map['id'], text: map['text'], isDone: map['isDone']);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Todo> _todos = [];
  List<Todo> _allTodos = [];
  String _currentLabel = "All Todo's";
  Color _currentColor = Color(0xFF6A4CE6);
  String _activeFilter = "All";

  @override
  void initState() {
    super.initState();
    loadTodos();
  }

  Future<void> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    String? saved = prefs.getString("todos");

    if (saved != null) {
      List<dynamic> jsonList = jsonDecode(saved);

      setState(() {
        _allTodos = jsonList.map((item) => Todo.fromMap(item)).toList();
        _todos = List.from(_allTodos);
      });
    }
  }

  Future<void> saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> mapList = _allTodos
        .map((todo) => todo.toMap())
        .toList();

    await prefs.setString("todos", jsonEncode(mapList));
  }

  void addTodo(String text) {
    if (text.isEmpty) return;

    setState(() {
      int id = DateTime.now().millisecondsSinceEpoch;
      Todo newTodo = Todo(id: id, text: text);

      _allTodos.add(newTodo);
      _todos.add(newTodo);
    });

    saveTodos();
  }

  void deleteTodo(int id) {
    setState(() {
      _allTodos.removeWhere((todo) => todo.id == id);
      _todos.removeWhere((todo) => todo.id == id);
    });

    saveTodos();
  }

  void toggleDone(int id) {
    setState(() {
      final index = _allTodos.indexWhere((todo) => todo.id == id);
      if (index == -1) return;

      _allTodos[index].isDone = !_allTodos[index].isDone;

      final filteredIndex = _todos.indexWhere((todo) => todo.id == id);
      if (filteredIndex != -1) {
        _todos[filteredIndex].isDone = _allTodos[index].isDone;
      }
    });

    saveTodos();
  }

  void showAddTodoDialog() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(0),
            width: 500,
            height: 200,
            child: AlertDialog(
              insetPadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.fromLTRB(4, 0, 4, 15),
              titlePadding: const EdgeInsets.fromLTRB(4, 5, 4, 5),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 0,
              ),

              title: const Text("Add Todo"),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: "Enter todo text"),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    side: const BorderSide(color: Colors.black12, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    side: const BorderSide(color: Colors.black12, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    addTodo(controller.text);
                    Navigator.pop(context);
                  },
                  child: const Text("Add"),
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
        backgroundColor: Color(0xFF03869F),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('TODO list app', style: TextStyle(color: Colors.white, fontSize: 25),),
            Image.asset('assets/images/logo.jpg', height: 40),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFfbc2eb), Color(0xFFa6c1ee)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      _activeFilter == "All" ? Color(0xFF6A4CE6) : Colors.white,
                    ),
                    foregroundColor: WidgetStateProperty.all(
                      _activeFilter == "All" ? Colors.white : Colors.black,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _todos = List.from(_allTodos);
                      _currentLabel = "All Todo's";
                      _currentColor = Color(0xFF6A4CE6);
                      _activeFilter = "All";
                    });
                  },
                  child: const Text("All"),
                ),

                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      _activeFilter == "Completed"
                          ? Color(0xFF6A4CE6)
                          : Colors.white,
                    ),
                    foregroundColor: WidgetStateProperty.all(
                      _activeFilter == "Completed"
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _todos = _allTodos.where((t) => t.isDone).toList();
                      _currentLabel = "Completed ✔";
                      _currentColor = Color(0xFF6A4CE6);
                      _activeFilter = "Completed";
                    });
                  },
                  child: const Text("Completed"),
                ),

                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      _activeFilter == "Pending"
                          ? Color(0xFF6A4CE6)
                          : Colors.white,
                    ),
                    foregroundColor: WidgetStateProperty.all(
                      _activeFilter == "Pending" ? Colors.white : Colors.black,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _todos = _allTodos.where((t) => !t.isDone).toList();
                      _currentLabel = "Pending ⏳";
                      _currentColor = Color(0xFF6A4CE6);
                      _activeFilter = "Pending";
                    });
                  },
                  child: const Text("Pending"),
                ),

                // Elevated button to clear all the items at once
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _allTodos.clear();
                      _todos.clear();
                    });
                    saveTodos();
                  },
                  child: Text("Clear All"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              _currentLabel,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: _todos.length,
                itemBuilder: (context, index) {
                  final todo = _todos[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(50),
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: todo.isDone,
                          onChanged: (value) => toggleDone(todo.id),
                          activeColor: Color.fromARGB(246, 107, 78, 224),
                          checkColor: Colors.white,
                        ),
                        Expanded(
                          child: Text(
                            todo.text,
                            style: TextStyle(
                              decoration: todo.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: Colors.black87,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 219, 140, 140),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: IconButton(
                            onPressed: () => deleteTodo(todo.id),
                            icon: const Icon(Icons.delete, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: showAddTodoDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
