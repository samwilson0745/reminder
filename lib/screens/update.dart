import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Update extends StatefulWidget {
  String id;
  String title;
  String description;
  Update(this.id,this.title,this.description);

  @override
  State<Update> createState() => _UpdateState();
}

class _UpdateState extends State<Update> {

  TextEditingController _title=new TextEditingController();
  TextEditingController _description = new TextEditingController();
  void setFields(){
    _title.text=widget.title;
    _description.text=widget.description;
  }

  @override
  void initState(){
    setFields();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text('Update'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: (){
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
        child: Column(
          children: [
          TextFormField(
            controller: _title,
            decoration: InputDecoration(
               labelText: "Title",
                border: OutlineInputBorder()
            ),
          ),
          SizedBox(height:14 ,),
          TextField(
            controller: _description,
            maxLines: 5,
            decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder()
            ),
          ),
          SizedBox(
            height: 20,
          ),
            ElevatedButton(
                onPressed: (){
                  final result=FirebaseFirestore.instance.collection('task').doc(widget.id).update(
                    {
                      'title':_title.text,
                      'description':_description.text,
                      'time':FieldValue.serverTimestamp()
                    }
                  );
                  result.then((value){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Updated!')));
                    Future.delayed(
                      Duration(
                        seconds: 2,
                      ),
                        (){
                          Navigator.of(context).pop();
                        }
                    );
                  }
                  );
                },
                child: Text('Update')
            )
          ],
    ),
      ));
  }
}
