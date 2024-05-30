import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:gemini_world_1/search-results.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: getFirstPageOfTheApp(),
    );
  }
  getFirstPageOfTheApp() {
    return const SearchResults(title: 'Flutter Demo Home Page');
    // return const MyHomePage(title: 'Flutter Demo Home Page');
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late GenerativeModel geminiModel;
  final apiKey = "YOUR_OWN_API_KEY";

  TextEditingController inputController = TextEditingController();

  String _geminiResponse = "";
  bool _loading = false;
  final images = [
    "assets/images/fruit-1.png",
    "assets/images/fruit-2.png"

  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    geminiModel = GenerativeModel(model: "gemini-pro-vision", apiKey: apiKey);
  }
  Future<DataPart> imageToDataPart(String imagePath) async {
    final imageByteData = await rootBundle.load(imagePath);
    final imageBytes = imageByteData.buffer.asUint8List();
    final imagePart = DataPart("image/png", imageBytes);
    return imagePart;
  }
  Future<void> _incrementCounter() async {
    String text = inputController.text;

    if (text.isEmpty) return;
    setState(() {
      _loading = true;
    });
    List<Part> promptParts = [];
    promptParts.add(TextPart("First Image:"));
    promptParts.add(await imageToDataPart(images.first));

    promptParts.add(TextPart("Second Image:"));
    promptParts.add(await imageToDataPart(images.last));

    final textPart = TextPart(text);
    promptParts.add(textPart);

    final promptContent = Content.multi(promptParts);

    final contents = [promptContent];
    var response = await geminiModel.generateContent(contents);
    _geminiResponse = response.text!;
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(height: 200,
                  child:
                  ListView.builder(
                    scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (BuildContext ctx, int index) {
                        return SizedBox(width: 200, child: Image.asset(images[index]));
                  }),
                ),
                TextField(
                  maxLines: 8,
                  controller: inputController,
                  decoration: const InputDecoration(
                      hintText: "Enter your prompt",
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0)))
                  ),
                ),
                if (_loading) CircularProgressIndicator(),
                if (!_loading)
                ElevatedButton(
                    onPressed: _incrementCounter,
                    child: Text("Ask Gemini")
                ),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: const BorderRadius.all(Radius.circular(8.0))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(

                        "$_geminiResponse",
                      style: Theme.of(context).textTheme.bodySmall),
                  ),
                )
              ],
            ),
          ),
        )

      )
    );
  }
}
