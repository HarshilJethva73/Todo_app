import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'TODO list app'),
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
  final List<Map<String, dynamic>> _todos = [];
  final List<Map<String, dynamic>> _allTodos = [];

  void addTodo(String text) {
    if (text.isNotEmpty) {
      setState(() {
        _todos.add({'text': text, 'isDone': false});
        _allTodos.add({'text': text, 'isDone': false});
      });
    }
  }

  void deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
      _allTodos.removeAt(index);
    });
  }

  void toggleDone(int index) {
    setState(() {
      _todos[index]['isDone'] = !_todos[index]['isDone'];
      _allTodos[index]['isDone'] = _todos[index]['isDone'];
    });
  }

  void showAddTodoDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Todo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter todo text'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              addTodo(controller.text);
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue, title: Text(widget.title)),
      body: Container(
        decoration: BoxDecoration(
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
                    setState(() {
                      _todos.clear();
                      _todos.addAll(_allTodos);
                    });
                  },
                  child: const Text('All'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _todos.clear();
                      _todos.addAll(_allTodos.where((todo) => todo['isDone']));
                    });
                  },
                  child: const Text('Completed'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _todos.clear();
                      _todos.addAll(_allTodos.where((todo) => !todo['isDone']));
                    });
                  },
                  child: const Text('Pending'),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 5),
              child: const Text(
                "All Todo's",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _todos.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Checkbox(
                        value: _todos[index]['isDone'],
                        onChanged: (value) => toggleDone(index),
                      ),
                      Expanded(
                        child: Text(
                          _todos[index]['text'],
                          style: TextStyle(
                            decoration: _todos[index]['isDone']
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => deleteTodo(index),
                      ),
                    ],
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
