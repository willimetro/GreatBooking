import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:great_booking/src/models/todo.dart';
import 'package:great_booking/src/services/authentication.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId,this.onSignedOut}) : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> _todoList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();

  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;

  Query _todoQuery;

  bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();

    _checkEmailVerification();

    _todoList = new List();
    _todoQuery = _database
      .reference()
      .child("todo")
      .orderByChild("userId")
      .equalTo(widget.userId);

    _onTodoAddedSubscription = _todoQuery.onChildAdded.listen(_onEntryAdded);
    _onTodoChangedSubscription = _todoQuery.onChildChanged.listen(_onEntryChanged);
  }

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if(_isEmailVerified) {
      _showVerifyEmailDialog();
    }
  }

  void _resentVerifyEmail() {
    widget.auth.sendEmailVerification();
    _showVerifyEmailDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verify your account'),
          content: Text('Please verify account in the link sent to email'),
          actions: <Widget>[
            FlatButton(
              child: Text('Reset link'),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            FlatButton(
              child: Text('dismiss'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verify your account'),
          content: Text('Link to verify account has been sent to your email'),
          actions: <Widget>[
            FlatButton(
              child: Text('Dismiss'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
  }

  _onEntryChanged(Event event) {
    var oldEntry = _todoList.singleWhere((entry){
      return entry.key == event.snapshot.key;
    });

    setState(() {
     _todoList[_todoList.indexOf(oldEntry)] = Todo.fromSnapshot(event.snapshot); 
    });
  }

  _onEntryAdded(Event event) {
    setState(() {
     _todoList.add(Todo.fromSnapshot(event.snapshot)); 
    });
  }

  _singOut() async {
    try{
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  _addNewTodo(String todoItem) {
    if(todoItem.length > 0) {
      Todo todo = new Todo(todoItem.toString(), widget.userId, false);
      _database.reference().child("todo").push().set(todo.toJson());
    }
  }

  _updateTodo(Todo todo) {
    todo.completed = !todo.completed;
    if(todo != null) {
      _database.reference().child("todo").child("todo.key").set(todo.toJson());
    }
  }

  _deleteTodo(String todoId, int index) {
    _database.reference().child("todo").child("todoId").remove().then((_){
      print("Delete $todoId successful");
      setState(() {
       _todoList.removeAt(index); 
      });
    });
  }

  _showDialog(BuildContext context) async {
    _textEditingController.clear();
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _textEditingController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Add new todo',
                  ),
                ),
              )
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: const Text('Save'),
              onPressed: () {
                _addNewTodo(_textEditingController.text.toString());
                Navigator.pop(context);
              },
            )
          ],
        );
      }
    );
  }

  Widget _showTodoList() {
    if(_todoList.length > 0) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: _todoList.length,
        itemBuilder: (BuildContext context, int index) {
          String todoId = _todoList[index].key;
          String subject = _todoList[index].subject;
          bool completed = _todoList[index].completed;
          String userId = _todoList[index].userId;
          return Dismissible(
            key: Key(todoId),
            background: Container(color: Colors.red),
            onDismissed: (direction) async {
              _deleteTodo(todoId, index);
            },
            child: ListTile(
              title: Text(
                subject,
                style: TextStyle(fontSize: 20.0),
              ),
              trailing: IconButton(
                icon: (completed) ? Icon(
                  Icons.done_outline,
                  color: Colors.green,
                  size: 20.0,
                ) : Icon(Icons.done, color: Colors.grey, size: 20.0),
                onPressed: () {
                  _updateTodo(_todoList[index]);
                },
              ),
            ),
          );
        },
      );
    } else {
      return Center(
        child: Text('Welcome. Your list is empty',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Login demo'),
        actions: <Widget>[
          FlatButton(
            child: Text('Logout',
            style: TextStyle(fontSize: 17.0, color: Colors.white),),
            onPressed: _singOut(),
          )
        ],
      ),
      body: _showTodoList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDialog(context);
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  
}