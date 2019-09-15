import 'package:flutter/material.dart';

class LoginSignUpPage extends StatefulWidget {
  @override
  _LoginSignUpPageState createState() => _LoginSignUpPageState();
}

enum FormMode { LOGIN, SIGNUP }

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  final _formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  String _errorMessage;

  FormMode _formMode = FormMode.LOGIN;
  bool _isIos;
  bool _isLoading;

  bool _validateAndSave(){
    final form = _formKey.currentState;
    if(form.validate()){
      form.save();
      return true;
    }
    return false;
  }

  void _validateAndSubmit() async {
    setState(() {
     _errorMessage = "";
     _isLoading = true; 
    });

    if(_validateAndSave()) {
      String userId = "";
      try {
        if(_formMode == FormMode.LOGIN) {
          userId = "";//await widget.
        } else {
          userId = "";
          _showVerifyEmailSentDialog();
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
         _isLoading = false;
         if(_isIos) {
           _errorMessage = e.details;
         } else {
           _errorMessage = e.message;
         } 
        });
      }
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
     _formMode = FormMode.SIGNUP; 
    });
  }

  void _changeFormToLogin() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
     _formMode = FormMode.LOGIN; 
    });
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return Scaffold(
      appBar: AppBar(
        title: Text('Great Booking Login'),
      ),
      body: Stack(
        children: <Widget>[
          _showBody(),
          _showCircularProgress()
        ],
      )
    );
  }

  Widget _showCircularProgress(){
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } 
    return Container(height: 0.0, width: 0.0,);
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verify your account'),
          content: Text('Link to verify account has been sent your email'),
          actions: <Widget>[
            FlatButton(
              child: Text('Dismiss'),
              onPressed: (){
                _changeFormToLogin();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }

  Widget _showEmailInput(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Email',
          icon: Icon(
            Icons.mail,
            color: Colors.grey,
          )
        ),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value.trim(),
      )
    );
  }

  Widget _showPasswordInput(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Password',
          icon: Icon(
            Icons.lock,
            color: Colors.grey,
          )
        ),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget _showPrimaryButton(){
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: MaterialButton(
        elevation: 5.0,
        minWidth: 200.0,
        height: 42.0,
        color: Colors.blue,
        child: _formMode == FormMode.LOGIN ? Text('Login',
          style: TextStyle(fontSize: 20.0, color: Colors.white )) : 
            Text('Create account',
              style: TextStyle(fontSize: 20.0,color: Colors.white)),
        onPressed: _validateAndSubmit,
      ),
    );
  }

  Widget _showSecondaryButton() {
    return FlatButton(
      child: _formMode == FormMode.LOGIN ? 
        Text('Create account',
        style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.w300)) : 
        Text('Have an account? Sign in',
        style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.w300)),
      onPressed: _formMode == FormMode.LOGIN ? 
      _changeFormToSignUp :
      _changeFormToLogin,
    );
  }

  Widget _showBody(){
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            _showLogo(),
            _showEmailInput(),
            _showPasswordInput(),
            _showPrimaryButton(),
            _showSecondaryButton(),
            _showErrorMessage()
          ],
        ),
      ),
    );
  }

  Widget _showLogo(){
    return Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset('assets/flutter-icon.png'),
        ),
      ),
    );
  }

  Widget _showErrorMessage() {
    if(_errorMessage.length > 0 && _errorMessage != null) {
      return Text(
        _errorMessage,
        style: TextStyle(
          fontSize: 13.0,
          color: Colors.red,
          height: 1.0,
          fontWeight: FontWeight.w300
        ),
      );
    } else {
      return Container(
        height: 0.0,
      );
    }
  }
}