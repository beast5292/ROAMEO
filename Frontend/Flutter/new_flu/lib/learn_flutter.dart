import 'package:flutter/material.dart';

class LearnFlutterPage extends StatefulWidget {
  LearnFlutterPage({Key? key}) : super(key: key);

  @override
  State<LearnFlutterPage> createState() => _LearnFlutterPageState();
}

class _LearnFlutterPageState extends State<LearnFlutterPage> {
  bool isSwitch = false;
  bool? isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Learn Flutter'),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  debugPrint('actions');
                },
                icon: Icon(Icons.info_outlined))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset('images/flutterLearn.png'),
              SizedBox(
                height: 10,
              ),
              const Divider(
                color: Colors.white,
              ),
              Container(
                margin: const EdgeInsets.all(10.0),
                padding: const EdgeInsets.all(10.0),
                color: Colors.blueGrey,
                width: double.infinity,
                child: const Center(
                  child: Text('Enjoy Learning',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSwitch ? Colors.pink : Colors.purple,
                ),
                onPressed: () {
                  debugPrint('Elevated pressed!');
                },
                child: const Text('Elevated Learn More'),
              ),
              OutlinedButton(
                onPressed: () {
                  debugPrint('Outlined pressed!');
                },
                child: const Text('Outlined Learn More'),
              ),
              TextButton(
                onPressed: () {
                  debugPrint('Text pressed!');
                },
                child: const Text('Texted Learn More'),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  debugPrint('Row on fire!');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.purple,
                    ),
                    Text('Fire'),
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.purple,
                    )
                  ],
                ),
              ),
              Switch(
                  value: isSwitch,
                  onChanged: (bool boolVal) {
                    setState(() {
                      isSwitch = boolVal;
                    });
                  }),
              Checkbox(
                  value: isChecked,
                  onChanged: (bool? checkBool) {
                    setState(() {
                      isChecked = checkBool;
                    });
                  }),
              Image.network(
                  'https://www.simplilearn.com/ice9/free_resources_article_thumb/What_is_Dart_Programming.jpg')
            ],
          ),
        ));
  }
}
