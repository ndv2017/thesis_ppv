import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// import 'package:path_provider/path_provider.dart';

void main() {
  runApp(DCMotorTrackerApp());
}

class DCMotorTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DC MOTOR TRACKER',
      theme: ThemeData(primarySwatch: Colors.blue),
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
  double testDuration = 60.0; // Default 60 seconds for loaded test
  final TextEditingController _durationController = TextEditingController(text: '60');

  double currentSpeed = 0.0;
  double currentCurrent = 0.0;
  double currentTemp = 0.0;

  @override
  void dispose() {
    _timer?.cancel();
    _durationController.dispose();
    super.dispose();
  }

  // Simulate or read data from file (replace with your actual data source)
  void startMonitoring(String mode) {
    if (isRunning) return;
    setState(() => isRunning = true);
    time = 0.0;
    speedData.clear();
    currentData.clear();
    tempData.clear();

    // Start the Python script with the test duration
    Process.run('python3', [
      './motor_data_simulator.py',
      testDuration.toString(),
    ]).then((result) {
      print('Python script started: ${result.stdout}');
      if (result.stderr.isNotEmpty) {
        print('Error starting Python script: ${result.stderr}');
      }
    });

    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) async {
      if (!isRunning || (time >= testDuration)) {
        stopMonitoring();
        return;
      }

      // Read from file (/tmp/motor_data.txt)
      try {
        final file = File('./tmp/motor_data.txt');
        if ((!await file.exists())) {
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
        } else {
          print('Cannot create file ./tmp/motor_data.txt');
        }

        // Dummy data for testing
        // setState(() {
        //   currentSpeed = 100 + ((time < 5 || time > 10) ? time : -time) * 10;
        //   currentCurrent = 1.0 + time * 0.1;
        //   currentTemp = 20.0 + time * 0.5;

        //   speedData.add(FlSpot(time, currentSpeed)); // Dummy speed
        //   currentData.add(FlSpot(time, 1.0 + time * 0.1)); // Dummy current
        //   tempData.add(FlSpot(time, 20.0 + time * 0.5)); // Dummy temperature
        //   time += 0.5;
        // });
      } catch (e) {
        print('Error reading data: $e');
      }
    });
  }

  void stopMonitoring() {
    _timer?.cancel();
    setState(() => isRunning = false);
    // Stop Python script (adjust command as needed)
    Process.run('pkill', ['-f', 'motor_data_simulator.py']);
  }

  void defaultMonitoring() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
      time = 0.0;
      // speedData.clear();
      // currentData.clear();
      // tempData.clear();
      testDuration = 60.0; // Reset to default
      _durationController.text = '60'; // Update input field
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
            child: Image.asset('assets/logo_vion_nobg.png', width: 60, height: 60),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left: Charts
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(child: ParameterChart('Speed (RPM)', speedData, currentSpeed, Color.fromARGB(255, 0, 204, 255), minY: 0, maxY: 350)), // Speed range
                  SizedBox(height: 16),
                  Expanded(child: ParameterChart('Current (A)', currentData, currentCurrent, Color.fromARGB(255, 255, 121, 121), minY: 0, maxY: 5)), // Current range
                  SizedBox(height: 16),
                  Expanded(child: ParameterChart('Temperature (°C)', tempData, currentTemp, Color.fromARGB(255, 248, 157, 54), minY: 0, maxY: 50)), // Temperature range
                ],
              ),
            ),
          ),
          // Right: Buttons
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Labels for current values
                  Row(
                    children: [
                      Text(
                        'Current v: ',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 20.0,
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.none,
                          color: Colors.black,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      Text(
                        '${currentSpeed.toStringAsFixed(2)} RPM',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 20.0,
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.none,
                          color: Colors.blue,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Current I: ',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 20.0,
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.none,
                          color: Colors.black,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      Text(
                        '${currentCurrent.toStringAsFixed(2)} A',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 20.0,
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.none,
                          color: Colors.red,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Current T: ',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 20.0,
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.none,
                          color: Colors.black,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      Text(
                        '${currentTemp.toStringAsFixed(2)} °C',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 20.0,
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.none,
                          color: Colors.orange,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 100), // Space between logo and buttons
                  // Row for Run Idle & Run Loaded
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isRunning ? null : () => startMonitoring('idle'),
                          child: Text('Run Idle'),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isRunning ? null : () => startMonitoring('loaded'),
                          child: Text('Run Loaded'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Row for Test Duration & Reset
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _durationController,
                          decoration: InputDecoration(labelText: 'Test Duration (s)'),
                          keyboardType: TextInputType.number,
                          enabled: !isRunning, // Disable when isRunning is true
                          onChanged: (value) {
                            testDuration = double.tryParse(value) ?? 60.0;
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isRunning ? null : defaultMonitoring,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 214, 214, 214)),
                          child: Text("Default"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  // Centered Stop button
                  ElevatedButton(
                    onPressed: isRunning ? stopMonitoring : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text('Stop'),
                  ),
                  // The 2 logos are parallel
                  SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: Image.asset(
                          'assets/logo_ppv_nobg.png',
                          width: 200,
                          height: 200,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Image.asset(
                          'assets/logobk.png',
                          width: 200,
                          height: 200,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
  final double minY;
  final double maxY;
  final double currentValue; // New parameter for current value
  final Color lineColor; // New parameter for line color

  ParameterChart(this.title, this.data, this.currentValue, this.lineColor, {required this.minY, required this.maxY});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              // '$title - ${currentValue.toStringAsFixed(2)}',
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 90, 89, 89)),
            ),
            Expanded(
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  // maxX: testDuration,
                  gridData: FlGridData(
                    show: true, // Enable grid
                    drawHorizontalLine: false, // Show horizontal lines
                    horizontalInterval: (maxY - minY) / 5, // Spacing between horizontal lines
                    drawVerticalLine: true, // Disable vertical lines for simplicity
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40, // Space for labels
                        interval: (maxY - minY) / 5, // Adjust based on data range
                      )
                    ),

                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 5, // Show a title every 5 seconds
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toStringAsFixed(0)}s', // Label as "Xs" (e.g., "5s")
                            style: TextStyle(fontSize: 10),
                          );
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
                      belowBarData: BarAreaData(show: false),
                      color: lineColor, // Set the line color
                      curveSmoothness: 0.1,
                      // isStepLineChart: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

