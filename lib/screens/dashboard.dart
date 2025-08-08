import 'package:flutter/material.dart';
import 'package:intern_app/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? user;
  List<dynamic> scores = [];
  bool _isLoading = true;

  static const String API_BASE_URL = 'http://10.0.2.2:3000/api';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userStr = prefs.getString('user');
    String? token = prefs.getString('token');

    if (userStr != null && token != null) {
      setState(() {
        user = json.decode(userStr);
      });
      await _loadScores(token);
    }
  }

  Future<void> _loadScores(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$API_BASE_URL/performance-scores/user/${user!['id']}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          scores = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading scores: $e');
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.orange;
    return Colors.red;
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Performance', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? token = prefs.getString('token');
                if (token != null) {
                  await _loadScores(token);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              user?['full_name'] ?? 'User',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.person, color: Colors.blue, size: 16),
                                const SizedBox(width: 5),
                                Text('Role: ${user?['role']?.toString().toUpperCase()}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Performance Overview
                    if (scores.isNotEmpty) ...[
                      const Text(
                        'Performance Overview',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                'Total Scores',
                                scores.length.toString(),
                                Icons.assignment_turned_in,
                                Colors.blue,
                              ),
                              _buildStatItem(
                                'Average Score',
                                (scores.fold<num>(0, (sum, item) => sum + item['score']) / scores.length)
                                    .toStringAsFixed(1),
                                Icons.trending_up,
                                Colors.green,
                              ),
                              _buildStatItem(
                                'Latest Week',
                                scores.first['week_number'].toString(),
                                Icons.calendar_today,
                                Colors.orange,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Scores List
                    const Text(
                      'Recent Scores',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    if (scores.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              const Icon(Icons.assignment, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'No scores yet',
                                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your performance scores will appear here once your supervisor adds them.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...scores.map((score) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _getScoreColor(score['score']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                '${score['score']}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _getScoreColor(score['score']),
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            score['task_title'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Text('Week ${score['week_number']}'),
                              if (score['feedback'] != null && score['feedback'].isNotEmpty) ...[
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    score['feedback'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 5),
                              Text(
                                'Submitted: ${DateTime.parse(score['created_at']).toLocal().toString().split(' ')[0]}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getScoreColor(score['score']),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${score['score']}/10',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      )),
                  ],
                ),
              ),
            ),
    );
  }
}
