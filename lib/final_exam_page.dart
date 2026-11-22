import 'package:flutter/material.dart';

import 'final_exam_planner.dart';
import 'gpa_calculator.dart';

class FinalExamPage extends StatefulWidget {
  const FinalExamPage({super.key});

  @override
  State<FinalExamPage> createState() => _FinalExamPageState();
}

class _FinalExamPageState extends State<FinalExamPage> {
  final currentController = TextEditingController();
  final weightController = TextEditingController();
  final targetController = TextEditingController(text: '60');
  final expectedController = TextEditingController();

  double? requiredFinal;
  double? predictedGrade;
  String resultMessage = '';

  static const Color blue = Color(0xFF1D4ED8);
  static const Color teal = Color(0xFF0F766E);

  void calculate() {
    final current = double.tryParse(currentController.text.trim());
    final weight = double.tryParse(weightController.text.trim());
    final target = double.tryParse(targetController.text.trim());
    final expectedText = expectedController.text.trim();
    final expected = double.tryParse(expectedText);

    if (current == null ||
        !current.isFinite ||
        current < 0 ||
        current > 100 ||
        weight == null ||
        !weight.isFinite ||
        weight <= 0 ||
        weight > 100 ||
        target == null ||
        !target.isFinite ||
        target < 0 ||
        target > 100 ||
        (expectedText.isNotEmpty &&
            (expected == null ||
                !expected.isFinite ||
                expected < 0 ||
                expected > 100))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid values.')),
      );
      return;
    }

    final needed = FinalExamPlanner.calculateRequiredFinal(
      currentGrade: current,
      finalWeight: weight,
      targetGrade: target,
    );

    setState(() {
      requiredFinal = needed;

      if (needed <= 0) {
        resultMessage = 'Your target grade is already secured!';
      } else if (needed > 100) {
        resultMessage = 'Your target grade is not achievable.';
      } else {
        resultMessage =
            'You need ${needed.toStringAsFixed(2)}% on your final exam.';
      }

      predictedGrade = expectedText.isEmpty
          ? null
          : FinalExamPlanner.calculateOverallGrade(
              currentGrade: current,
              finalWeight: weight,
              finalScore: expected!,
            );
    });
  }

  Widget gradeField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: blue),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    currentController.dispose();
    weightController.dispose();
    targetController.dispose();
    expectedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      appBar: AppBar(
        title: const Text('Final Exam Planner'),
        backgroundColor: blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: blue,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.calculate_outlined,
                        color: Colors.white,
                        size: 45,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Plan Your Final Exam',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Find out what score you need to reach your goal.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                gradeField(
                  'Current Grade (%)',
                  currentController,
                  Icons.school_outlined,
                ),
                gradeField(
                  'Final Exam Weight (%)',
                  weightController,
                  Icons.percent,
                ),
                gradeField(
                  'Target Grade (%)',
                  targetController,
                  Icons.flag_outlined,
                ),
                gradeField(
                  'Expected Final Score (%) - Optional',
                  expectedController,
                  Icons.edit_outlined,
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: calculate,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calculate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(18),
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (requiredFinal != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Your Result',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: blue,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          resultMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 17),
                        ),
                        if (predictedGrade != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Predicted Overall Grade: '
                            '${predictedGrade!.toStringAsFixed(2)}%',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Predicted GPA: '
                            '${GPACalculator.calculateGradePoint(predictedGrade!).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: teal,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
