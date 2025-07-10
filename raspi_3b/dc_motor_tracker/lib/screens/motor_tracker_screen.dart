import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/parameter_chart.dart';
import '../screens/start_screen.dart';

class MotorTrackerScreen extends StatefulWidget {
  @override
  _MotorTrackerScreenState createState() => _MotorTrackerScreenState();
}

class _MotorTrackerScreenState extends State<MotorTrackerScreen> {
  List<FlSpot> speedData = [];
  List<FlSpot> currentData = [];
  List<FlSpot> tempData = [];
  List<FlSpot> torqueData = [];
  double time = 0.0;
  Timer? _timer;
  bool isRunning = false;
  double testDuration = 60.0;
  final TextEditingController _durationController = TextEditingController(text: '60');
  Process? pythonProcess;

  double currentSpeed = 0.0;
  double currentCurrent = 0.0;
  double currentTemp = 0.0;
  double currentTorque = 0.0;

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
    torqueData.clear();

    Process.start('python3', ['home/thesisppv/workspace_thesis/thesis_ppv/dc_motor_tracker/motor_data_simulator.py']).then((process) {
      pythonProcess = process;
      print("Python script started with PID: ${process.pid}");
    });

    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) async {
      if (!isRunning || time >= testDuration) {
        stopMonitoring();
        return;
      }

      try {
        final file = File('home/thesisppv/workspace_thesis/thesis_ppv/dc_motor_tracker/tmp/motor_data.txt');
        if (!await file.exists()) {
          print('Creating file ./tmp/motor_data.txt');
          await file.create(recursive: true);
        }
        if (await file.exists()) {
          final data = await file.readAsString();
          final values = data.trim().split(',');
          if (values.length == 4) {
            double speed = double.parse(values[0]);
            double current = double.parse(values[1]);
            double temp = double.parse(values[2]);
            double torque = double.parse(values[3]);

            setState(() {
              speedData.add(FlSpot(time, speed));
              currentData.add(FlSpot(time, current));
              tempData.add(FlSpot(time, temp));
              torqueData.add(FlSpot(time, torque));
              time += 0.2;
              currentSpeed = speed;
              currentCurrent = current;
              currentTemp = temp;
              currentTorque = torque;
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => StartScreen()),
            );
          },
        ),
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
      ),
      body: Row(
        children: [
          Container(
            width: 250,
            color: Colors.grey[300],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Workspace", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  title: Row(
                    children: [
                      Text('Speed: ', style: TextStyle(decoration: TextDecoration.none, color: Colors.black)),
                      Text('${currentSpeed.toStringAsFixed(2)} RPM', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blue)),
                    ],
                  )
                ),
                ListTile(
                  title: Row(
                    children: [
                      Text('Current: ', style: TextStyle(decoration: TextDecoration.none, color: Colors.black)),
                      Text('${currentCurrent.toStringAsFixed(2)} A', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.red)),
                    ],
                  )
                ),
                ListTile(
                  title: Row(
                    children: [
                      Text('Temperature: ', style: TextStyle(color: Colors.black)),
                      Text('${currentTemp.toStringAsFixed(2)} °C', style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic)),
                    ],
                  )
                ),
                ListTile(
                  title: Row(
                    children: [
                      Text('Torque: ', style: TextStyle(color: Colors.black)),
                      Text('${currentTorque.toStringAsFixed(2)} Nmm', style: TextStyle(color: Colors.purple, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                Divider(),
                Expanded(child: SizedBox()),
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
          Expanded(
            child: Column(
              children: [
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: ParameterChart('Speed (RPM)', speedData, currentSpeed, Color.fromARGB(255, 0, 204, 255), minY: 0, maxY: 2000),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: ParameterChart('Current (A)', currentData, currentCurrent, Color.fromARGB(255, 255, 121, 121), minY: 0, maxY: 100),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: ParameterChart('Temperature (°C)', tempData, currentTemp, Color.fromARGB(255, 248, 157, 54), minY: 0, maxY: 50),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: ParameterChart('Torque (Nmm)', torqueData, currentTorque, Colors.purple, minY: 0, maxY: 100),
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
