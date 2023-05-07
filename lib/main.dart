import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Work Sensei',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
          accentColor: Colors.pink,
        ),
        fontFamily: 'Montserrat',
      ),
      home: MyHomePage(title: 'To-Do List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  final List<Map<String, dynamic>> _todoList = [];

  final TextEditingController _controllerText = TextEditingController();

  void _addTodo() {
    final String id = Uuid().v4();
    setState(() {
      _todoList.add({
        'id': id,
        'title': _controllerText.text,
        'done': false,
      });
    });
    _controllerText.clear();
    _controller.forward(from: 0);
  }

  void _removeTodo(String id) {
    setState(() {
      _todoList.removeWhere((todo) => todo['id'] == id);
    });
  }

  void _toggleDone(String id) {
    setState(() {
      final todoIndex = _todoList.indexWhere((todo) => todo['id'] == id);
      _todoList[todoIndex]['done'] = !_todoList[todoIndex]['done'];
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Color(0xFE000000)),
        ),
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        brightness: Brightness.light,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin:
                    EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScaleTransition(
                      scale: _animation,
                      child: Text(
                        'Work Sensei',
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 197, 171, 241)),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _controllerText,
                      decoration: InputDecoration(
                        hintText: 'Add a to-do item',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(20),
                        suffixIcon: IconButton(
                          onPressed: _addTodo,
                          icon: Icon(Icons.add),
                        ),
                      ),
                      onSubmitted: (_) => _addTodo(),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _todoList.length,
                        itemBuilder: (context, index) {
                          final todo = _todoList[index];
                          return Dismissible(
                            key: Key(todo['id']),
                            onDismissed: (_) => _removeTodo(todo['id']),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 20),
                              color: Colors.red,
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            child: InkWell(
                              onTap: () => _toggleDone(todo['id']),
                              child: Container(
                                margin: EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: todo['done']
                                      ? Colors.grey.shade100
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: todo['done']
                                        ? Colors.green
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(
                                    todo['title'],
                                    style: TextStyle(
                                      decoration: todo['done']
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  leading: Checkbox(
                                    value: todo['done'],
                                    onChanged: (_) => _toggleDone(todo['id']),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
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
