import 'package:flutter/material.dart';
// imported shared preferences package
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
      home: const MyHomePage(title: 'TODO list app'),
    );
  }
}

class Todo {
  final int id;
  final String text;
  bool isDone;

  Todo({
    required this.id,
    required this.text,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isDone': isDone,
    };
  }

  static Todo fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      text: map['text'],
      isDone: map['isDone'],
    );
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
    List<Map<String, dynamic>> mapList =
        _allTodos.map((todo) => todo.toMap()).toList();

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
          actionsPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),


          title: const Text("Add Todo"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter todo text"),
          ),
          actions: [
            TextButton(
                style: TextButton.styleFrom(
                  side: const BorderSide(color: Colors.black12, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),),
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
                style: TextButton.styleFrom(
                side: const BorderSide(color: Colors.black12, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),),
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
      appBar: AppBar(backgroundColor: Colors.blue, title: Text(widget.title)),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() => _todos = List.from(_allTodos));
                  },
                  child: const Text("All"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() =>
                        _todos = _allTodos.where((t) => t.isDone).toList());
                  },
                  child: const Text("Completed"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() =>
                        _todos = _allTodos.where((t) => !t.isDone).toList());
                  },
                  child: const Text("Pending"),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text("All Todo's",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),

            Expanded(
              child: ListView.builder(
                itemCount: _todos.length,
                itemBuilder: (context, index) {
                  final todo = _todos[index];

                  return Row(
                    children: [
                      Checkbox(
                        value: todo.isDone,
                        onChanged: (value) => toggleDone(todo.id),
                      ),
                      Expanded(
                        child: Text(
                          todo.text,
                          style: TextStyle(
                            decoration: todo.isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => deleteTodo(todo.id),
                        icon: const Icon(Icons.delete),
                      )
                    ],
                  );
                },
              ),
            )
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
