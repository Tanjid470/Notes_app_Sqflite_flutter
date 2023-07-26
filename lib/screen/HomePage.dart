import 'package:flutter/material.dart';
import 'package:note/services/sql_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> notes = [];
  bool isLoadding = true;

  void refreshState() async {
    final data = await SqlHalper.getAllItem();
    setState(() {
      notes = data;
      isLoadding = false;
    });
  }

// initState call when the app load or refresh the app
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshState();
    // print("length of list ${notes.length}");
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  var currentId;
  Future<void> _updateItem(int id) async {
    await SqlHalper.updateItem(
        id, _titleController.text, _descriptionController.text);
    refreshState();
  }

  void _showFrom(int? id) async {
    if (id != null) {
      currentId = id;
      print("\n\n\n\n\n\n\n\n${currentId}");
      final existingNote = notes.firstWhere((element) => element['id'] == id);
      _titleController.text = existingNote['title'];
      _descriptionController.text = existingNote['description'];
    }
    showModalBottomSheet(
      elevation: 5,
      isDismissible: true,
      //For full Screen
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(
            15, 15, 15, MediaQuery.of(context).viewInsets.bottom + 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Title"),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Description',
                label: Text('Description'),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    gapPadding: 4.5),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await SqlHalper.createItem(
                        _titleController.text, _descriptionController.text);
                    refreshState();
                  }
                  if (id != null) {
                    await _updateItem(id);
                  }
                  //Clean the form
                  _titleController.text = '';
                  _descriptionController.text = '';

                  Navigator.of(context).pop();
                },
                child: Text(id == null ? "Create" : "Update"))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       // leading: const Icon(Icons.person),
        title: const Text(
          "NoteBook",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // backgroundColor: Colors.teal,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color.fromARGB(255, 40, 40, 41),
                ]),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFrom(null),
        label: const Row(
          children: [
            Icon(
              Icons.add,
              size: 26,
            ),
            Text(
              'Add New.',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color.fromARGB(255, 5, 0, 0)),
            )
          ],
        ),

        backgroundColor: Color.fromARGB(255, 61, 144, 240),
        // children: [ Icon(Icons.add)],
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) => Container(
          // color: Colors.red,
          margin: EdgeInsets.only(bottom: 10),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  _showFrom(notes[index]['id']);
                },
                child: Card(
                  color: Color.fromARGB(255, 218, 218, 218),
                  margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: ListTile(
                      title: Text(notes[index]['title'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color.fromARGB(255, 0, 0, 0))),
                      subtitle: Text(notes[index]['description'],
                          style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 17,
                              color: Color.fromARGB(255, 21, 22, 21))),
                      trailing: const Icon(
                        Icons.edit,
                        color: Colors.black,
                      )),
                ),
              ),

              //Delete

              GestureDetector(
                onTap: () async {
                  _showMyDialog(context, index);
                },
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  decoration:const BoxDecoration(
                      color: Color.fromARGB(255, 192, 80, 5),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5))),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Delete',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.delete,
                        color: Color.fromARGB(255, 34, 33, 33),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialog(BuildContext context, int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return Container(
          child: AlertDialog(
            backgroundColor: Color.fromARGB(255, 71, 70, 70),
            // elevation: 10,
            // scrollable: true,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Alert'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Are you sure to delete it'),
                  //Text('Would you like to approve of this message?'),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                        Color.fromARGB(255, 226, 102, 53))),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                onPressed: () async {
                  await SqlHalper.deleteItem(notes[index]['id']);
                  Navigator.of(context).pop();
                  refreshState();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Note deleted'),
                    duration: const Duration(milliseconds: 1000),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ));
                },
              ),
              ElevatedButton(
                child: const Text('Cancle',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 11,
                    )),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
