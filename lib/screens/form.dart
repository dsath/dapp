import 'package:call_me_maybe/screens/journal_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../theme.dart';
import '../models/journal_entry.dart';

class JournalEntryForm extends StatefulWidget {
  final void Function(ThisTheme) nextTheme;
  final ThisTheme themeObj;
  void Function() changeBool;

  JournalEntryForm({this.nextTheme, this.themeObj, this.changeBool});

  @override
  _JournalEntryFormState createState() => _JournalEntryFormState();
}

class _JournalEntryFormState extends State<JournalEntryForm> {
  final journalEntryFields = JournalEntryFields();
  final formKey = GlobalKey<FormState>();
  double rating = 2;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(title: Center(child: Text('Enter Journal Entry'))),
        endDrawer: Drawer(
            child: Container(
                alignment: Alignment.center,
                child: Column(children: [
                  SizedBox(height: 30),
                  Text("Dark Mode"),
                  Switch(
                    value: widget.themeObj.darkState,
                    onChanged: (newState) {
                      widget.nextTheme(widget.themeObj);
                    },
                  ),
                ]))),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Form(
                key: formKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                          autofocus: true,
                          decoration: InputDecoration(
                              labelText: 'Title', border: OutlineInputBorder()),
                          onSaved: (value) {
                            journalEntryFields.title = value;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'its empty';
                            } else {
                              return null;
                            }
                          }),
                      SizedBox(height: 10),
                      TextFormField(
                          autofocus: true,
                          decoration: InputDecoration(
                              labelText: 'Body', border: OutlineInputBorder()),
                          onSaved: (value) {
                            journalEntryFields.body = value;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'its empty';
                            } else {
                              return null;
                            }
                          }),
                      SizedBox(height: 10),
                      Slider(
                        value: rating,
                        onChanged: (newRating) {
                          setState(() => rating = newRating);
                        },
                        divisions: 3,
                        label: "Rating: $rating",
                        min: 1,
                        max: 4,
                      ),
                      SizedBox(height: 10),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RaisedButton(
                                child: Text('Save Entry'),
                                onPressed: () async {
                                  if (formKey.currentState.validate()) {
                                    formKey.currentState.save();
                                    addDateToJournalEntryValues();
                                    journalEntryFields.rating = rating;

                                    //await deleteDatabase('journal.db');
                                    final Database database =
                                        await openDatabase('journal.db',
                                            version: 1, onCreate: (Database db,
                                                int version) async {
                                      await db.execute(
                                          'CREATE TABLE IF NOT EXISTS journal_entries (id INTEGER PRIMARY KEY AUTOINCREMENT, title Text, body Text, rating Double, date Text)');
                                    });
                                    await database.transaction((txn) async {
                                      await txn.rawInsert(
                                          'INSERT INTO journal_entries(title, body, rating, date) VALUES(?,?,?,?)',
                                          [
                                            journalEntryFields.title,
                                            journalEntryFields.body,
                                            journalEntryFields.rating,
                                            (journalEntryFields.dateTime)
                                                .toString()
                                          ]);
                                    });
                                    await database.close();
                                    widget.changeBool();
                                    Navigator.of(context).pushNamed('app');
                                  }
                                }),
                            SizedBox(width: 10),
                            RaisedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }, child: Text('Cancel'))
                          ])
                    ]))));
  }

  void addDateToJournalEntryValues() {
    journalEntryFields.dateTime = DateTime.now();
  }
}

void goBack(BuildContext context) {
  Navigator.of(context).pop();
}
