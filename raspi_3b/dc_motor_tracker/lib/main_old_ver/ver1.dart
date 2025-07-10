import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(DCMotorTrackerApp());
}

class DCMotorTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DC Motor Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[200],
        fontFamily: 'Roboto',
      ),
      home: MotorTrackerScreen(),
    );
  }
}

class MotorTrackerScreen extends StatefulWidget {
  @override
  _MotorTrackerScreenState createState() => _MotorTrackerScreenState();
}

class _MotorTrackerScreenState extends State<MotorTrackerScreen> {
  List<FlSpot> speedData = [];
  List<FlSpot> currentData = [];
  List<FlSpot> tempData = [];
  double time = 0.0;
  Timer? _timer;
  bool isRunning = false;
  double testDuration = 60.0;
  final TextEditingController _durationController = TextEditingController(text: '60');
  Process? pythonProcess;

  double currentSpeed = 0.0;
  double currentCurrent = 0.0;
  double currentTemp = 0.0;

  @override
  void dispose() {
    _timer?.cancel();
    _durationController.dispose();
    super.dispose();
  }

  void startMonitoring(String mode) {
    if (isRunning) return;
    setState(() => isRunning = true);
    time = 0.0;
    speedData.clear();
    currentData.clear();
    tempData.clear();

    // Process.run('python3', [
    //   './receive_from_stm32.py',
    //   testDuration.toString(),
    // ]).then((result) {
    //   print('Python script started: ${result.stdout}');
    //   if (result.stderr.isNotEmpty) {
    //     print('Error starting Python script: ${result.stderr}');
    //   }
    // });
    Process.start('python3', ['./receive_from_stm32.py']).then((process) {
      pythonProcess = process;
      print("Python script started with PID: ${process.pid}");
    });


    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) async {
      if (!isRunning || time >= testDuration) {
        stopMonitoring();
        return;
      }

      try {
        final file = File('./tmp/motor_data.txt');
        if (!await file.exists()) {
          print('Creating file ./tmp/motor_data.txt');
          await file.create(recursive: true);
        }
        if (await file.exists()) {
          final data = await file.readAsString();
          final values = data.trim().split(',');
          if (values.length == 3) {
            double speed = double.parse(values[0]);
            double current = double.parse(values[1]);
            double temp = double.parse(values[2]);

            setState(() {
              speedData.add(FlSpot(time, speed));
              currentData.add(FlSpot(time, current));
              tempData.add(FlSpot(time, temp));
              time += 0.2;
              currentSpeed = speed;
              currentCurrent = current;
              currentTemp = temp;
            });
          }
        }
      } catch (e) {
        print('Error reading data: $e');
      }
    });
  }

  void stopMonitoring() {
    _timer?.cancel();
    setState(() => isRunning = false);

    // Process.run('pkill', ['-f', 'receive_from_stm32.py']);
    if (pythonProcess != null) {
      final pid = pythonProcess!.pid;
      print("Sending SIGINT to Python script (PID: $pid)");
      Process.killPid(pid, ProcessSignal.sigint);
    }
  }

  void defaultMonitoring() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
      time = 0.0;
      testDuration = 60.0;
      _durationController.text = '60';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color.fromARGB(255, 20, 136, 219),
          ),
          padding: EdgeInsets.all(115.0),
          child: Text(
            'DC MOTOR TRACKER',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w800,
              color: const Color.fromARGB(255, 3, 43, 145),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Image.asset('assets/logo_vion_nobg.png', width: 80, height: 80),
            ),
        ],
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.help),
        //     onPressed: () {
        //       showDialog(
        //         context: context,
        //         builder: (context) => AlertDialog(
        //           title: Text("Help"),
        //           content: Text("No commands available yet."),
        //           actions: [
        //             TextButton(
        //               onPressed: () => Navigator.pop(context),
        //               child: Text("Close"),
        //             ),
        //           ],
        //         ),
        //       );
        //     },
        //   ),
        // ],
      ),
      body: Row(
        children: [
          // Sidebar for Workspace and Logos
          Container(
            width: 250,
            color: Colors.grey[300],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Workspace",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  title: Row(
                    children: [
                      Text(
                        'Speed: ',
                        style: TextStyle(
                          // fontSize: 18,
                          // fontStyle: FontStyle.italic,
                          decoration: TextDecoration.none,
                          color: Colors.black,
                          // fontWeight: FontWeight.w200,
                        ),
                      ),
                      Text(
                        '${currentSpeed.toStringAsFixed(2)} RPM',
                        style: TextStyle(
                          // fontFamily: 'Roboto',
                          // fontSize: 18,
                          fontStyle: FontStyle.italic,
                          // decoration: TextDecoration.none,
                          color: Colors.blue,
                          // fontWeight: FontWeight.w200,
                        ),
                      ),
                    ],
                  )
                ),
                ListTile(
                  title: Row(
                    children: [
                      Text(
                        'Current: ',
                        style: TextStyle(
                          // fontSize: 18,
                          // fontStyle: FontStyle.italic,
                          decoration: TextDecoration.none,
                          color: Colors.black,
                          // fontWeight: FontWeight.w200,
                        ),
                      ),
                      Text(
                        '${currentCurrent.toStringAsFixed(2)} A',
                        style: TextStyle(
                          // fontFamily: 'Roboto',
                          // fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: Colors.red,
                          // fontWeight: FontWeight.w200,
                        ),
                      ),
                    ],
                  ),               
                ),
                ListTile(
                  title: Row(
                    children: [
                      Text(
                        'Temperature: ',
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                        '${currentTemp.toStringAsFixed(2)} °C',
                        style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                Divider(),
                Expanded(
                  child: SizedBox(), // Spacer to push logos to the bottom
                ),
                // Logos at the bottom-left corner
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(width: 6),
                      Image.asset('assets/logobk.png', width: 100, height: 100),
                      SizedBox(width: 16),
                      Image.asset('assets/logo_ppv_nobg.png', width: 100, height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main content area
          Expanded(
            child: Column(
              children: [
                // Toolbar
                Container(
                  color: Colors.grey[400],
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: isRunning ? null : () => startMonitoring('idle'),
                        child: Text("Run Idle"),
                      ),
                      ElevatedButton(
                        onPressed: isRunning ? null : () => startMonitoring('loaded'),
                        child: Text("Run Loaded"),
                      ),
                      ElevatedButton(
                        onPressed: isRunning ? stopMonitoring : null,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: Text("Stop"),
                      ),
                      SizedBox(width: 16),
                      SizedBox(
                        width: 150,
                        child: TextField(
                          controller: _durationController,
                          decoration: InputDecoration(
                            labelText: "Test Duration (s)",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          enabled: !isRunning,
                          onChanged: (value) {
                            testDuration = double.tryParse(value) ?? 60.0;
                          },
                        ),
                      ),
                      ElevatedButton(
                        onPressed: isRunning ? null : defaultMonitoring,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                        child: Text("Default"),
                      ),
                    ],
                  ),
                ),
                // Charts
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: ParameterChart('Speed (RPM)', speedData, currentSpeed, Color.fromARGB(255, 0, 204, 255), minY: 0, maxY: 3500),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: ParameterChart('Current (A)', currentData, currentCurrent, Color.fromARGB(255, 255, 121, 121), minY: 0, maxY: 5),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: ParameterChart('Temperature (°C)', tempData, currentTemp, Color.fromARGB(255, 248, 157, 54), minY: 0, maxY: 50),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ParameterChart extends StatelessWidget {
  final String title;
  final List<FlSpot> data;
  final double currentValue;
  final Color lineColor;
  final double minY;
  final double maxY;

  ParameterChart(this.title, this.data, this.currentValue, this.lineColor, {required this.minY, required this.maxY});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            Expanded(
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    horizontalInterval: (maxY - minY) / 5,
                    drawVerticalLine: true,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: (maxY - minY) / 5,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toStringAsFixed(0)}s', style: TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      dotData: FlDotData(show: false),
                      color: lineColor,
                      curveSmoothness: 0.1,
                    ),
                  ],
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}