
import 'package:firebase_auth/firebase_auth.dart';
import '../Operations/Authentication.dart';
import 'Home.dart';

import '../Operations/Userdetails.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../Widgets/Dailogbox.dart';
import 'Loading.dart';
import '../Size/SizeConfig.dart';
class Login extends StatefulWidget {
  final AuthImplementation auth;
  final VoidCallback onSignedIn;
  Login({this.auth,this.onSignedIn});

  @override
  _LoginState createState() => _LoginState();
}

enum FormType
{
  login,register
}
enum Branch1{
  CSE,ECE,MECH,CIVIL,IT,EEE
}

enum Status{
  Student,
  Alumni,
  Faculty,
}

class _LoginState extends State<Login> {
  DialogBox dialogBox= DialogBox();

  final formKey= GlobalKey<FormState>();
  FormType _formType =FormType.login;
  String email="";
  String password ="";
  String name ="";
  String branch ="CSE";
  String state ="Student";

  String phoneNumber='' ,schoolname='',skills='',worksat='';
  bool loading =false;
  Status _status= Status.Student;
  Branch1 _branch= Branch1.CSE;


  final node = FocusNode();




  bool validateAndSave(){
    final form =formKey.currentState;
    if(form.validate())
    {
        form.save();
        return true;
    }
    else{
      return false;
        }


  }
  void validateAndSubmit()async
  {
    if (validateAndSave())
      {
        try{
          if(_formType==FormType.login)
            {
              String userId =await widget.auth.SignIn(email, password,name);

              print("login userId ="+userId);
              if (userId!=null)
                {
                  setState(() {
                    loading = false;
                  });
                  Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (context)=>Home()));
                  widget.onSignedIn();
                }

            }
          else
            {
              User user =await widget.auth.SignUp(email, password,name);
               try {print("r userId ="+ user.uid);}
               catch(e){
                 print(e);
               }


             try{ if (user.uid!=null)
                 {  StoreUser userdetails = StoreUser(name);
                 String uid =userdetails.storeUserDetails( user,email, name, branch, phoneNumber,state,schoolname,skills,worksat);
               if( uid!=null)
                {
                  DatabaseReference dbref = await FirebaseDatabase.instance.reference();
                  var data={
                    "uid":uid,
                    "name":name,
                    "branch":branch,
                    "phoneNumber":phoneNumber,
                    "state":state,
                    "email":email,
                    "schoolname":schoolname,
                    "skills":skills,
                    "profileurl":"https://images.unsplash.com/photo-1511367461989-f85a21fda167?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1189&q=80",
                    "worksat":worksat,

                  };
                  await dbref.child("Users").child(uid).child("userdetails").set(data);
                  await dbref.child("Users").child(uid).child("Registerred").set("yes");


                  String Username =await widget.auth.getCurrentUsername();
                  Navigator.of(context).pop();
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context) => Home()));
                }
               else
                 {
                   //print(widget.userdetails.storeUserDetails( user, name, branch, phoneNumber,state));
                 }

              }}
              catch(e){
               print(e);
              }

            }


        }
        catch(e) {
          dialogBox.information(context,"A Error",e.toString());
          setState(() {
            loading=false;
          });



    }
      }
  }

   void moveToRegister ()
   {
     formKey.currentState.reset();
     setState(() {
       _formType=FormType.register;
     });
   }

  void moveToLogin()
  {
    formKey.currentState.reset();
    setState(() {
      _formType=FormType.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading==true? Loading():SafeArea(
      child: Scaffold(


        resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.black,


        body:Container(
          margin: EdgeInsets.fromLTRB(4*SizeConfig.blockSizeHorizontal,2.727*SizeConfig.blockSizeVertical,4.166*SizeConfig.blockSizeHorizontal,2.727*SizeConfig.blockSizeVertical),
          child: Form(
            key:formKey,
            child: ListView(
             shrinkWrap: true,
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget> [

                createInputs(),


                createButtons(),

              ]
            ),
          ),
        ),
      ),
    );
  }

  Widget createInputs()
  {
    if(_formType==FormType.login)
   {
    return Column(
        children:<Widget>[
      SizedBox(height: 5.45*SizeConfig.blockSizeVertical),


      SizedBox(height: 3*SizeConfig.blockSizeVertical),
      Text('Mrec Alumni ',textAlign: TextAlign.center,style: TextStyle(fontSize: 8.3*SizeConfig.blockSizeHorizontal,fontFamily: 'NunitoSans',color:Colors.cyan[600]),),

      SizedBox(height: 2.7*SizeConfig.blockSizeVertical),


      Material(
        borderRadius: BorderRadius.circular(2.7*SizeConfig.blockSizeVertical),
        color: Colors.cyan[400],
        elevation: 0.0,
        child: Padding(
          padding:  EdgeInsets.fromLTRB(2.2*SizeConfig.blockSizeHorizontal,1.4545*SizeConfig.blockSizeVertical,2.2*SizeConfig.blockSizeHorizontal,1.4545*SizeConfig.blockSizeVertical),
          child: TextFormField(
            autocorrect: true,
            autofocus: true,
            onFieldSubmitted: (v){

              FocusScope.of(context).requestFocus(node);
           },
            decoration: InputDecoration(hintText: '  Username',
              //border:OutlineInputBorder(),
              icon:Icon(Icons.person),
            ),

            validator: (value)
            {return value.isEmpty?'Email is required ':null;
            },
            onSaved: (value)
            {
              email=value;
            },

          ),
        ),
      ),

      SizedBox(height:0.9*SizeConfig.blockSizeVertical),

      Material(
        borderRadius: BorderRadius.circular(2.7*SizeConfig.blockSizeVertical),
        color: Colors.cyan[400],
        elevation: 0.0,

        child: Padding(
          padding:  EdgeInsets.fromLTRB(2.2*SizeConfig.blockSizeHorizontal,1.4545*SizeConfig.blockSizeVertical,2.2*SizeConfig.blockSizeHorizontal,1.4545*SizeConfig.blockSizeVertical),
          child: TextFormField(
            autocorrect: true,
            focusNode: node,
            onFieldSubmitted:(val) {
              validateAndSave();
            },
            decoration:InputDecoration(hintText:'   Password',icon:Icon(Icons.lock_open),),
            obscureText: true,
            validator: (value)
            {return value.length>=8?null:'Please create a 8 digit password';
            },
            onSaved: (value)
            {
              password=value;
            },
          ),
        ),
      ),

    ]);
   }
    else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
          children:<Widget>[

            SizedBox(height: 8.3*SizeConfig.blockSizeVertical),

            Text('Mrec Alumini ',textAlign: TextAlign.center,style: TextStyle(fontSize: 8.33*SizeConfig.blockSizeHorizontal,fontFamily:'NunitoSans',color:Colors.cyan[600]),),

            SizedBox(height: 2.72*SizeConfig.blockSizeVertical),

            SizedBox(height: 2.72*SizeConfig.blockSizeVertical),

            TextFormField(

              decoration: InputDecoration(
                labelText:'Name',

                labelStyle: TextStyle(color: Colors.cyan[600]),
                hintStyle: TextStyle(color: Colors.cyan[600],),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2*SizeConfig.blockSizeHorizontal)),
                  borderSide: BorderSide(color: Colors.cyan[600]),
                ),
                enabledBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2*SizeConfig.blockSizeHorizontal)),
                  borderSide: BorderSide(color: Colors.cyan[600]),
                ),

              ),

              style: TextStyle(color: Colors.cyan[600]),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (v){
                FocusScope.of(context).nextFocus(); // move focus to next
              },
              // autocorrect: true,
              validator: (value) {
                return value.isEmpty?'Please enter your name ':null;
              },
              onSaved: (value) {
                setState(() {
                  name=value;
                });

              },
            ),

            SizedBox(height:2.9*SizeConfig.blockSizeVertical),

            TextFormField(

              decoration: InputDecoration(
                labelText:'Email',

                labelStyle: TextStyle(color: Colors.cyan[600]),
                hintStyle: TextStyle(color: Colors.cyan[600],),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2*SizeConfig.blockSizeHorizontal)),
                  borderSide: BorderSide(color: Colors.cyan[600]),
                ),
                enabledBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2*SizeConfig.blockSizeHorizontal)),
                  borderSide: BorderSide(color: Colors.cyan[600]),
                ),

              ),

              style: TextStyle(color: Colors.cyan[600]),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (v){
                FocusScope.of(context).nextFocus(); // move focus to next
              },
              // autocorrect: true,
              validator: (value) {
                return value.isEmpty?'Please enter your email ':null;
              },
              onSaved: (value) {
                setState(() {
                  email=value;
                });

              },
            ),

            SizedBox(height:2.9*SizeConfig.blockSizeVertical),

            TextFormField(

              decoration: InputDecoration(
                labelText:'Password',

                labelStyle: TextStyle(color: Colors.cyan[600]),
                hintStyle: TextStyle(color: Colors.cyan[600],),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2*SizeConfig.blockSizeHorizontal)),
                  borderSide: BorderSide(color: Colors.cyan[600]),
                ),
                enabledBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2*SizeConfig.blockSizeHorizontal)),
                  borderSide: BorderSide(color: Colors.cyan[600]),
                ),

              ),

              style: TextStyle(color: Colors.cyan[600]),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (v){
                FocusScope.of(context).nextFocus(); // move focus to next
              },
              // autocorrect: true,
              validator: (value) {
                return value.length<8?'Please enter 8 character password ':null;
              },
              onSaved: (value) {
                setState(() {
                  password=value;
                });

              },
            ),

            SizedBox(height:2.9*SizeConfig.blockSizeVertical),







            TextFormField(
              style: TextStyle(color: Colors.cyan[600]),
              decoration: InputDecoration(
                labelText:'Phone Number',
                labelStyle: TextStyle(color: Colors.cyan[600]),
                hintStyle: TextStyle(color: Colors.cyan[600],),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2*SizeConfig.blockSizeHorizontal)),
                  borderSide: BorderSide(color: Colors.cyan[600]),
                ),
                enabledBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2*SizeConfig.blockSizeHorizontal)),
                  borderSide: BorderSide(color: Colors.cyan[600]),
                ),

              ),
              // autocorrect: true,

              textInputAction: TextInputAction.next,
              onFieldSubmitted: (v){
                FocusScope.of(context).nextFocus(); // move focus to next
              },
              validator: (value) {
                return value.length==10?null:'Phone number  is required ';
              },
              onSaved: (value) {
                setState(() {
                  phoneNumber=value;
                });

              },
            ),

            SizedBox(height:2.9*SizeConfig.blockSizeVertical),


            TextFormField(
              style: TextStyle(color: Colors.cyan[600]),
              decoration: InputDecoration(
                labelText:'School Name',
                labelStyle: TextStyle(color: Colors.cyan[600]),
                hintStyle: TextStyle(color: Colors.cyan[600],),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2*SizeConfig.blockSizeHorizontal)),
                  borderSide: BorderSide(color: Colors.cyan[600]),
                ),
                enabledBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2*SizeConfig.blockSizeHorizontal)),
                  borderSide: BorderSide(color: Colors.cyan[600]),
                ),

              ),


              textInputAction: TextInputAction.next,
              onFieldSubmitted: (v){
                FocusScope.of(context).nextFocus(); // move focus to next
              },
              //autocorrect: true,
              validator: (value) {
                return value.isEmpty?'Please enter your school name ':null;
              },
              onSaved: (value) {
                setState(() {
                  schoolname=value;
                });

              },
            ),


            SizedBox(height:2.9*SizeConfig.blockSizeVertical),


            TextFormField(
              style: TextStyle(color: Colors.cyan[600]),
              decoration: InputDecoration(
                labelText:'Skills',
                labelStyle: TextStyle(color: Colors.cyan[600]),
                hintStyle: TextStyle(color: Colors.cyan[600],),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2*SizeConfig.blockSizeHorizontal)),
                  borderSide: BorderSide(color: Colors.cyan[600]),
                ),
                enabledBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2*SizeConfig.blockSizeHorizontal)),
                  borderSide: BorderSide(color: Colors.cyan[600]),
                ),

              ),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (v){
                FocusScope.of(context).nextFocus(); // move focus to next
              },

              //autocorrect: true,
              validator: (value) {
                return value.isEmpty?'Please enter your Skills ':null;
              },
              onSaved: (value) {
                setState(() {
                  skills=value;
                });

              },
            ),
            SizedBox(height:2.9*SizeConfig.blockSizeVertical),


            TextFormField(
              style: TextStyle(color: Colors.cyan[600]),
              decoration: InputDecoration(
                labelText:'Company Name /College Name',
                labelStyle: TextStyle(color: Colors.cyan[600]),
                hintStyle: TextStyle(color: Colors.cyan[600],),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2*SizeConfig.blockSizeHorizontal)),
                  borderSide: BorderSide(color: Colors.cyan[600]),
                ),
                enabledBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2*SizeConfig.blockSizeHorizontal)),
                  borderSide: BorderSide(color: Colors.cyan[600]),
                ),

              ),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (v){
                FocusScope.of(context).nextFocus(); // move focus to next
              },

              //autocorrect: true,
              validator: (value) {
                return value.isEmpty?'Please enter your Comapny name ':null;
              },
              onSaved: (value) {
                setState(() {
                  worksat=value;
                });

              },
            ),

            SizedBox(height:2.9*SizeConfig.blockSizeVertical),
            TextFormField(
              style: TextStyle(color: Colors.cyan[600]),
              decoration: InputDecoration(
                labelText:'Student/Passed Out/Faculty',
                labelStyle: TextStyle(color: Colors.cyan[600]),
                hintStyle: TextStyle(color: Colors.cyan[600],),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2*SizeConfig.blockSizeHorizontal)),
                  borderSide: BorderSide(color: Colors.cyan[600]),
                ),
                enabledBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2*SizeConfig.blockSizeHorizontal)),
                  borderSide: BorderSide(color: Colors.cyan[600]),
                ),

              ),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (v){
                FocusScope.of(context).nextFocus(); // move focus to next
              },

              // autocorrect: true,
              validator: (value) {

                return value.isEmpty?'Please enter your role ':value=='Student'||value=='Passed Out'||value=='Faculty'?null:'Please Enter either Student/Passed Out/Faculty';

              },
              onSaved: (value) {
                setState(() {
                  state=value;
                });

              },
            ),
            SizedBox(height:2.9*SizeConfig.blockSizeVertical),
            TextFormField(
              style: TextStyle(color: Colors.cyan[600]),
              decoration: InputDecoration(
                labelText:'CSE/IT/ECE/EEE/MECH/CIVIL',
                labelStyle: TextStyle(color: Colors.cyan[600]),
                hintStyle: TextStyle(color: Colors.cyan[600],),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2*SizeConfig.blockSizeHorizontal)),
                  borderSide: BorderSide(color: Colors.cyan[600]),
                ),
                enabledBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2*SizeConfig.blockSizeHorizontal)),
                  borderSide: BorderSide(color: Colors.cyan[600]),
                ),

              ),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (v){

                  validateAndSubmit();

              },

              // autocorrect: true,
              validator: (value) {

                return value.isEmpty?'Please enter your branch ':value=='CSE'||value=='IT'||value=='ECE'||value=='EEE'||value=='MECH'||value=='CIVIL'?null:'Please Enter either Student/Passed Out/Faculty';

              },
              onSaved: (value) {
                setState(() {
                  branch=value.toUpperCase();
                });

              },
            ),

            SizedBox(height:2.9*SizeConfig.blockSizeVertical),



          ]);
    }
  }



  Widget logo() {

    return Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        child: Image.asset('images/mrec_logo.jpg'),
        radius: 17*SizeConfig.blockSizeHorizontal,
      ),
    );

  }



  Widget createButtons()
  {
   if (_formType==FormType.login)
     {
       return Column (
         crossAxisAlignment: CrossAxisAlignment.stretch,
           children : <Widget>[
         SizedBox(height:3.63*SizeConfig.blockSizeVertical),

         RaisedButton(
           child:Text('LOG IN',style :TextStyle(fontSize:4.8*SizeConfig.blockSizeHorizontal,color:Colors.black,fontFamily:'NunitoSans',letterSpacing: 0.5*SizeConfig.blockSizeHorizontal)),
           color:Colors.cyan[600],
          // splashColor: Color(0XFF00857C).withBlue(2446).withOpacity(0.2),
           onPressed: validateAndSubmit,
           shape:  RoundedRectangleBorder(
               borderRadius: new BorderRadius.circular(5*SizeConfig.blockSizeVertical),
               side: BorderSide(color: Color(0XFF00857C).withBlue(2446).withOpacity(0.2),)
           ),

         ),

         FlatButton(
           child:Text("Don't have an acoount? Create one!",style :TextStyle(fontSize:3.8*SizeConfig.blockSizeHorizontal,color:Colors.blue)),
           onPressed: moveToRegister,
         ),
         SizedBox(height:36.363*SizeConfig.blockSizeVertical),
       ]);

     }
   else {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.stretch,
         children: <Widget>[
       SizedBox(height:3.636*SizeConfig.blockSizeVertical),

       RaisedButton(
         child:Text('Create Acoount ',style :TextStyle(fontSize:3.88*SizeConfig.blockSizeHorizontal,color:Colors.white)),
         color:Colors.blueAccent,
         onPressed: validateAndSubmit,
       ),

       FlatButton(
         child:Text("Already have an acccount Log in!",style :TextStyle(fontSize:3.33*SizeConfig.blockSizeHorizontal,color:Colors.blue)),

         onPressed: moveToLogin,
       ),
       SizedBox(height:45*SizeConfig.blockSizeVertical),
     ]);
   }
  }

}
