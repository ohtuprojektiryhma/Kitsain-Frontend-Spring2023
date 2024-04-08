import 'package:flutter/material.dart';
import 'package:kitsain_frontend_spring2023/app_colors.dart';

class FeedbackButton extends StatelessWidget {
  const FeedbackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.feedback),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateFeedbackForm()),
        );
      },
    );
  }
}

class FeedbackLogic {
  String _selectedFeedbackType = '';

  String get selectedFeedbackType => _selectedFeedbackType;

  void setSelectedFeedbackType(String value) {
    _selectedFeedbackType = value;
  }
}

class CreateFeedbackForm extends StatefulWidget {
  const CreateFeedbackForm({super.key});

  @override
  _CreateFeedbackFormState createState() => _CreateFeedbackFormState();
}

class _CreateFeedbackFormState extends State<CreateFeedbackForm> {
  final feedbackLogic = FeedbackLogic();
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Form'),
        backgroundColor: AppColors.main1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Type of feedback: '),
              Row(
                children: [
                  Radio(
                    value: 'Bugs',
                    groupValue: feedbackLogic.selectedFeedbackType,
                    onChanged: (value) {
                      setState(() {
                        feedbackLogic.setSelectedFeedbackType(value as String);
                      });
                    },
                  ),
                  const Text('Bugs'),
                  Radio(
                    value: 'Suggestions',
                    groupValue: feedbackLogic.selectedFeedbackType,
                    onChanged: (value) {
                      setState(() {
                        feedbackLogic.setSelectedFeedbackType(value as String);
                      });
                    },
                  ),
                  const Text('Suggestions'),
                  Radio(
                    value: 'Comments',
                    groupValue: feedbackLogic.selectedFeedbackType,
                    onChanged: (value) {
                      setState(() {
                        feedbackLogic.setSelectedFeedbackType(value as String);
                      });
                    },
                  ),
                  const Text('Comments'),
                ],
              ),
              const Text('Describe your feedback: '),
              TextFormField(
                controller: _feedbackController,
                decoration: const InputDecoration(
                  labelText: 'Feedback',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your feedback';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feedback submitted')),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}