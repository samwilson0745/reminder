
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:reminder/screens/notificatioApi.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:reminder/screens/update.dart';

class Home extends StatefulWidget {

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime nowtime=DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  TextEditingController _title=new TextEditingController();
  TextEditingController _description = new TextEditingController();
  TextEditingController _time=new TextEditingController();
  List data=[];
  @override
  void initState(){
    super.initState();
    NotificationApi.init();
  }


  _selectTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if(timeOfDay != null && timeOfDay != selectedTime)
    {
      setState(() {
        selectedTime = timeOfDay;
        _time.text=selectedTime.hour.toString()+":"+selectedTime.minute.toString();
        print(_time.text);
      });
    }
  }
  DateTime setTimeOfDay(TimeOfDay time) {
    return DateTime(nowtime.year, nowtime.month, nowtime.day, time.hour, time.minute);
  }
  SnackBar _showSnackBar(String text){
    return SnackBar(
      content: Text(text),
    );
  }
  Widget slideRightBackground() {
    return Container(
      color: Colors.green,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Icon(
              Icons.edit,
              color: Colors.white,
            ),
            Text(
              " Edit",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
      ),
    );
  }
  Widget slideLeftBackground() {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              " Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  Widget _listItem(String title,String description){
    return ListTile(
      title: Text(title,style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold
      ),),
      subtitle: Text(description,style: TextStyle(
        fontSize:15,
      ),),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showDialog(context: context, builder: (BuildContext context){
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Builder(
                  builder: (context) {
                  return AlertDialog(
                    title: Text("Enter Fields"),
                    actions: [
                      TextButton(onPressed: ()async{
                      if(_title.text!='' && _description.text!='' && _time.text!=''){
                        final task=FirebaseFirestore.instance.collection('task').doc();
                        final json={
                          'title':_title.text,
                          'description':_description.text,
                          'time':FieldValue.serverTimestamp()
                        };
                        await task.set(json);
                        NotificationApi.showNotification(
                          title: 'Task Added!',
                          body: 'The task will be reminded at the given time',
                          payload: 'reminder'
                        );
                        NotificationApi.showScheduledNotification(
                            title: 'hello',
                            body: 'yoo',
                            scheduledDate:setTimeOfDay(selectedTime),
                          payload: 'reminder'
                        );
                        Navigator.of(context).pop();
                      }
                      else{
                        ScaffoldMessenger.of(context).showSnackBar(_showSnackBar('Fields cannot be Empty'));
                      }
                      }, child: Text('ADD')),
                      TextButton(onPressed: (){
                        Navigator.of(context).pop();
                      }, child: Text('CANCEL'))
                    ],
                    content: Container(
                      width: MediaQuery.of(context).size.width/0.5,
                      height: MediaQuery.of(context).size.height/2.7,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                          SizedBox(height: 14,),
                          TextFormField(
                            controller: _time,
                            decoration: InputDecoration(
                              labelText: "Set Time",
                              border: OutlineInputBorder()
                            ),
                            onTap: (){
                              _selectTime(context);
                            },
                            onChanged: (value){
                              value=selectedTime.toString();
                            },
                          )
                        ],
                      ),
                    ),
                  );
                }
              ),
            );
          });
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('task').snapshots(),
        builder: (context,AsyncSnapshot<QuerySnapshot> snapshot) {
          if(snapshot.data?.size==0) {
            return Center(
              child: Text('Nothing Added!',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
            );
          }
          else if(snapshot.hasError){
            return Center(
              child: Text('Something Went Wrong!'),
            );
          }
          else if(snapshot.hasData){
            return ListView(
              children: snapshot.data!.docs.map((document){
                return Dismissible(
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Text(
                                    "Are you sure you want to delete ${document['title']}?"),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () {
                                      // TODO: Delete the item from DB etc..
                                      FirebaseFirestore.instance.collection('task').doc(document.id).delete();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                        return true;
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>Update(document.id,document['title'],document['description'])));
                      }
                    },
                    background: slideRightBackground(),
                    secondaryBackground: slideLeftBackground(),
                    key: ValueKey(document),
                    child: InkWell(child: _listItem(document['title'], document['description'])));
              }).toList()
            );
          }
          else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          // else{
          //   print('Hello');
          //   return Center(
          //     child: CircularProgressIndicator(),
          //   );
          // }
        }
      ),
    );
  }
}