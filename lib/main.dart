import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jqxapjehxmxkmihxqmky.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpxeGFwamVoeG14a21paHhxbWt5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjM0NzQ1OTIsImV4cCI6MjAzOTA1MDU5Mn0.6WE0MTgpRQvXROTFsWajWQpwgRRxU_EHWGyeIj5bynA',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _notesStream =
      Supabase.instance.client.from('notes').stream(primaryKey: ['id']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('My Notes',
            style: GoogleFonts.mPlusRounded1c(
                color: Colors.white, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _notesStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final notes = snapshot.data!;

          return Center(
            child: SizedBox(
              width: 800,
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(15),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.black),
                          onPressed: () async {
                            await Supabase.instance.client
                                .from('notes')
                                .delete()
                                .eq('id', notes[index]['id']);
                          },
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              final TextEditingController _controller =
                                  TextEditingController(
                                      text: notes[index]['body']);
                              return SimpleDialog(
                                title: Text('Edit Note'),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                children: [
                                  TextFormField(
                                    controller: _controller,
                                    onFieldSubmitted: (value) async {
                                      await Supabase.instance.client
                                          .from('notes')
                                          .update({'body': value}).eq(
                                              'id', notes[index]['id']);

                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                            },
                          );
                        },
                        tileColor: Colors.white,
                        title: Text(notes[index]['body'],
                            style: GoogleFonts.mPlusRounded1c(
                                color: Colors.black,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: Text('Add a Note'),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                children: [
                  TextFormField(
                    onFieldSubmitted: (value) async {
                      await Supabase.instance.client
                          .from('notes')
                          .insert({'body': value});
                    },
                  )
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
