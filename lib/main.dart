// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fullscreen_window/fullscreen_window.dart';
import 'package:just_audio/just_audio.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Power Nap App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: PowerNapPage(),
    );
  }
}

class PowerNapPage extends StatefulWidget {
  @override
  _PowerNapPageState createState() => _PowerNapPageState();
}

class _PowerNapPageState extends State<PowerNapPage> {
  late String selectedDuration;
   String reason="Charging Your Mind With\nPower Nap";

  @override
  void initState() {
    super.initState();
    selectedDuration = '1 Minutes';
    
    // Wakelock.enable();
  }

  void startTimer(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => CountdownPage(duration: selectedDuration, reason: reason),
    transitionDuration: Duration(seconds: 0),
    transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child,),
    
        ),
      
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 500 && constraints.maxHeight > 600) {
                // For larger screens (e.g., tablets, desktop)
                return Center(
                  child: Container(
                    width: 350,
                    // height: 300,
                    child: _buildContent(isDesktop:true),
                  ),
                );
              } else {
                // For smaller screens (e.g., mobile devices)
                return _buildContent(isDesktop:false);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent({bool isDesktop=false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.05, horizontal: 20),
      child: SizedBox(
        height: 500,
        child: Column(
          
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if(MediaQuery.of(context).orientation == Orientation.portrait || isDesktop)
            Image.asset("asset/napImage.png"),
          
           const Text("Ignite Your Alerness with the\n Power Nap!", textAlign: TextAlign.center,),
           SizedBox(height: 1,),
      
            TextField(
              onChanged: (value) {
                setState(() {
                  reason = value;
                });
              },
              decoration:const InputDecoration(
                labelText: 'Add Power Nap reason',
                hintText: 'Enter a reason',
                border: OutlineInputBorder(),
              ),
            ),
           const SizedBox(height: 16.0),
            DropdownButton<String>(
              iconSize: 28,
              value: selectedDuration,
              onChanged: (String? newValue) {
                setState(() {
                  selectedDuration = newValue!;
                });
              },
              items: <String>['1 Minutes', '15 Minutes', '20 Minutes', '25 Minutes', '30 Minutes']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                );
              }).toList(),
            ),
           const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => startTimer(context),
              child:const Text(
                'Start',
                style: TextStyle(fontSize: 18.0),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CountdownPage extends StatefulWidget {
  final String duration;
   String reason;

  CountdownPage({
    Key? key,
    required this.duration,
    required this.reason,
  }) : super(key: key);

  @override
  _CountdownPageState createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage> {
  late Timer timer;
  int countdown = -1;
  bool isPaused = false;
  bool isFullscreen = false;

  void musicPlay(int count )async{
    if(count!=-1) 
    await Future.delayed( Duration(seconds: count));
    playSampleSound();
   widget.reason=" You Are Super Energized.\n Now Start Working !";
  }

  @override
  void initState() {
    super.initState();
    countdown = int.parse(widget.duration.split(' ')[0]) * 60;
    startTimer();
    musicPlay(countdown);
    // Wakelock.enable();
    // while(countdown<=4 && countdown!=0) {
    //   playSampleSound();
    // }
 
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (!isPaused) {
          if (countdown > 0) {
            countdown--;
          } else {
            timer.cancel();
          }
        }
      });
    });
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  void stopTimer() {
    timer.cancel();
    Navigator.pop(context);
    countdown=-1;
    
  }
  // alarm method
  void playSampleSound() async {
     AudioPlayer player = AudioPlayer();
    await player.setAsset('asset/beep.mp3');
    player.play();
    debugPrint("audio method hit")
;  }
  void toggleFullscreen() {
    if (isFullscreen) {
      debugPrint("0000000000");
      FullScreenWindow.setFullScreen(false);
      setState(() {
        Wakelock.disable();
      });
    } else {
      debugPrint("11111111111111");
      debugPrint("wakelock enable");
      FullScreenWindow.setFullScreen(true);
      setState(() {
        Wakelock.enable();
      });
      
    }
    setState(() {
      isFullscreen = !isFullscreen;
    });
  }

  String formatDuration(int duration) {
    int hours = duration ~/ 3600;
    int minutes = (duration % 3600) ~/ 60;
    int seconds = (duration % 60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    timer.cancel();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600 && constraints.maxHeight > 600) {
            // For larger screens (e.g., tablets, desktop)
            return Center(
              child: Container(
                // width: 400,
                // height: 300,
                child: _buildContent(),
              ),
            );
          }          else {
            // For smaller screens (e.g., mobile devices)
            return _buildContent(isDesktop: false);
          }
        },
      ),
    );
  }

  Widget _buildContent({ bool isDesktop=true}) {
    return Stack(
      children: [
         
          Positioned(
            top: 20,
            right: 5,
            child: IconButton(
              icon: Icon(Icons.fullscreen),
              onPressed: toggleFullscreen
            ),
          ),
        Padding(
          padding: EdgeInsets.only(top: isDesktop ? 140  : 80, bottom: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                
                '${widget.reason}',
                style: TextStyle(fontSize: isDesktop ? 60 :24, fontWeight: FontWeight.bold, ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height:40),
              Text(
                'Remaining Duration:',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 8.0),
              Text(
                formatDuration(countdown),
                style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: togglePause,
                    child: Text(isPaused ? 'Play' : 'Pause'),
                  ),
                  SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: stopTimer,
                    child: Text('Stop'),
                  ),
                  //  ElevatedButton(
                  //   onPressed: playSampleSound,
                  //   child: Text('Alarm'),
                  // ),
                ],
              ),
              // SizedBox(height: 20,),
              // Image.asset("asset/mindcharging.gif", width: 350,opacity: const AlwaysStoppedAnimation(.5) ,)
            ],
          ),
        ),
      ],
    );
  }
}
