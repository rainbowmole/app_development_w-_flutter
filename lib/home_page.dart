import 'package:flutter/material.dart';
import 'pages/activity1_page/act1_page.dart';
import 'pages/act2_page.dart';
import 'pages/act3_page.dart';
import 'pages/act4_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    var screenWidth =  MediaQuery.of(context).size.width; 
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF33415C),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 37),
            Text('Homepage', style: TextStyle(fontSize: 28.0)),
            SizedBox(height: 5),
            Text('Nathaniel F. Camacho', style: TextStyle(fontSize: 28.0)),
            SizedBox(height: 40,)
          ],
        ),
        toolbarHeight: 90,
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.directional(
          bottom: 0.07 * screenHeight, 
          top: 0.07 * screenHeight, 
          start: 0.03 * screenWidth, 
          end: 0.03 * screenWidth),

      child: GridView.count(
        crossAxisCount: (screenWidth > 1000 ? 4: (screenWidth > 800 ? 3 : (screenWidth > 600 ? 2 : 1))),
        mainAxisSpacing: 10, crossAxisSpacing: 10,

      children: [
          createButton(context, Icons.library_music, "", "Button 1"),
          createButton(context, Icons.bolt, "", "Button 2"),
          createButton(context, Icons.key, "", "Button 3"),
          createButton(context, Icons.camera, "", "Button 4"),
      ]
      ),
      ),
    );
  }
}

Widget createButton(BuildContext context, IconData icon, String label, String title){
  
  final Map<String, Widget Function()> btn = {
<<<<<<< HEAD
    'Button 1': () => const ActivityPage1(),
    'Button 2': () => const ActivityPage2(),
=======
    'Button 1': () => ActivityPage1(),
    'Button 2': () => ActivityPage2(),
>>>>>>> 10cd1941ce39992afe3822c94f885ac4e5752bff
    'Button 3': () => ActivityPage3(title: title),
    'Button 4': () => ActivityPage4(title: title),
  };
  return ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.grey,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      )
    ),
    onPressed: () {
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => btn[title]!())
        );
    }, 
  icon: Icon(icon , size: 150, color: const Color.fromARGB(255, 88, 105, 134)), 
  label: Text(label));
}