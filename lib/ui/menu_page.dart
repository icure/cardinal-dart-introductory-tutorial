import 'package:flutter/material.dart';
import 'package:flutter_playground/ui/codification_page.dart';
import 'package:flutter_playground/ui/create_examination_page.dart';
import 'package:flutter_playground/ui/search_page.dart';
import 'package:flutter_playground/ui/share_hcp_page.dart';
import 'package:flutter_playground/ui/share_patient_page.dart';
import 'create_user_page.dart';

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose the Operation')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateUserPage()),
              );
            },
            child: const Text('Create Patient'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateExaminationPage()),
              );
            },
            child: const Text('Create Examination'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
            child: const Text('Search'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShareHcpPage()),
              );
            },
            child: const Text('Share with another hcp'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SharePatientPage()),
              );
            },
            child: const Text('Share with Patient'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CodificationPage()),
              );
            },
            child: const Text('Manage Codifications'),
          ),
        ],
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String label;

  const MenuButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label clicked')),
        );
      },
      child: Text(label),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 20),
        textStyle: TextStyle(fontSize: 18),
      ),
    );
  }
}