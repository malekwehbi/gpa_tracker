import 'package:flutter/material.dart';

import 'course.dart';
import 'gpa_calculator.dart';
import 'final_exam_planner.dart';

class GPADashboard extends StatefulWidget {
  const GPADashboard({super.key});

  @override
  State<GPADashboard> createState() => _GPADashboardState();
}

class _GPADashboardState extends State<GPADashboard> {
  static const Color blue = Color(0xFF1D4ED8);
  static const Color darkBlue = Color(0xFF123A8C);
  static const Color teal = Color(0xFF0F766E);
  static const Color pageColor = Color(0xFFF3F6FC);
  static const Color textColor = Color(0xFF172033);
  static const Color mutedColor = Color(0xFF64748B);

  double previousGPA = 0.0;
  int previousCredits = 0;

  final List<Course> courses = [];

  int get semesterCredits => GPACalculator.calculateSemesterCredits(courses);

  double get semesterGPA => GPACalculator.calculateSemesterGPA(courses);

  double get cumulativeGPA => GPACalculator.calculateCumulativeGPA(
    previousGPA: previousGPA,
    previousCredits: previousCredits,
    courses: courses,
  );

  int get totalCredits => previousCredits + semesterCredits;

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ADD / EDIT COURSE
  void showCourseDialog({int? index}) {
    final bool isEditing = index != null;
    final Course? course = isEditing ? courses[index] : null;

    final nameController = TextEditingController(text: course?.name ?? '');

    final creditsController = TextEditingController(
      text: course?.credits.toString() ?? '',
    );

    final gradeController = TextEditingController(
      text: course?.grade.toString() ?? '',
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(isEditing ? 'Edit Course' : 'Add New Course'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Course Name',
                    prefixIcon: Icon(Icons.menu_book_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: creditsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Credit Hours',
                    prefixIcon: Icon(Icons.numbers),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: gradeController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Grade (%)',
                    prefixIcon: Icon(Icons.percent),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final credits = int.tryParse(creditsController.text.trim());
                final grade = double.tryParse(gradeController.text.trim());

                if (name.isEmpty ||
                    credits == null ||
                    credits <= 0 ||
                    grade == null ||
                    !grade.isFinite ||
                    grade < 0 ||
                    grade > 100) {
                  showMessage('Please enter valid course details');
                  return;
                }

                setState(() {
                  final updatedCourse = Course(
                    name: name,
                    credits: credits,
                    grade: grade,
                  );

                  if (isEditing) {
                    courses[index] = updatedCourse;
                  } else {
                    courses.add(updatedCourse);
                  }
                });

                Navigator.pop(dialogContext);
              },
              child: Text(isEditing ? 'Save Changes' : 'Add Course'),
            ),
          ],
        );
      },
    ).then((_) {
      nameController.dispose();
      creditsController.dispose();
      gradeController.dispose();
    });
  }

  // DELETE COURSE
  void deleteCourse(int index) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Delete Course'),
          content: Text(
            'Are you sure you want to delete ${courses[index].name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  courses.removeAt(index);
                });
                Navigator.pop(dialogContext);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // PREVIOUS GPA
  void setPreviousGPA() {
    final gpaController = TextEditingController(text: previousGPA.toString());

    final creditsController = TextEditingController(
      text: previousCredits.toString(),
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Previous GPA & Credits'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: gpaController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Previous GPA',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: creditsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Previous Credits',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final gpa = double.tryParse(gpaController.text.trim());
                final credits = int.tryParse(creditsController.text.trim());

                if (gpa == null ||
                    !gpa.isFinite ||
                    gpa < 0 ||
                    gpa > 4 ||
                    credits == null ||
                    credits < 0 ||
                    (credits == 0 && gpa != 0)) {
                  showMessage('Please enter valid GPA and credits');
                  return;
                }

                setState(() {
                  previousGPA = gpa;
                  previousCredits = credits;
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).then((_) {
      gpaController.dispose();
      creditsController.dispose();
    });
  }

  // FINAL EXAM PLANNER
  void showFinalExamPlanner() {
    final currentController = TextEditingController();
    final weightController = TextEditingController();
    final targetController = TextEditingController(text: '60');
    final finalScoreController = TextEditingController();

    double? requiredScore;
    double? overallGrade;
    String resultMessage = '';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, updateDialog) {
            void calculate() {
              final current = double.tryParse(currentController.text.trim());
              final weight = double.tryParse(weightController.text.trim());
              final target = double.tryParse(targetController.text.trim());
              final finalScore = double.tryParse(
                finalScoreController.text.trim(),
              );

              final hasFinalScore = finalScoreController.text.trim().isNotEmpty;

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
                  (hasFinalScore &&
                      (finalScore == null ||
                          !finalScore.isFinite ||
                          finalScore < 0 ||
                          finalScore > 100))) {
                showMessage('Please enter valid grades and weight');
                return;
              }

              final needed = FinalExamPlanner.calculateRequiredFinal(
                currentGrade: current,
                finalWeight: weight,
                targetGrade: target,
              );

              updateDialog(() {
                requiredScore = needed;

                if (needed <= 0) {
                  resultMessage = 'You have already secured your target grade!';
                } else if (needed > 100) {
                  resultMessage = 'Your target grade is not achievable.';
                } else {
                  resultMessage =
                      'You need ${needed.toStringAsFixed(2)}% on the final exam.';
                }

                overallGrade = finalScore == null
                    ? null
                    : FinalExamPlanner.calculateOverallGrade(
                        currentGrade: current,
                        finalWeight: weight,
                        finalScore: finalScore,
                      );
              });
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Final Exam Planner'),
              content: SizedBox(
                width: 380,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: currentController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Current Grade (%)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Final Exam Weight (%)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: targetController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Target Grade (%)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: finalScoreController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Expected Final Score (%) - Optional',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (requiredScore != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              Text(
                                resultMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: darkBlue,
                                ),
                              ),
                              if (overallGrade != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Predicted Overall Grade: '
                                  '${overallGrade!.toStringAsFixed(2)}%',
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Predicted GPA: '
                                  '${GPACalculator.calculateGradePoint(overallGrade!).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: calculate,
                  child: const Text('Calculate'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      currentController.dispose();
      weightController.dispose();
      targetController.dispose();
      finalScoreController.dispose();
    });
  }

  // DASHBOARD STAT CARD
  Widget statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: blue, size: 26),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: mutedColor),
            ),
            const SizedBox(height: 7),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // COURSE CARD
  Widget courseCard(int index) {
    final course = courses[index];

    final gradePoint = GPACalculator.calculateGradePoint(course.grade);
    final letter = GPACalculator.calculateLetterGrade(course.grade);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  course.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              Text(
                gradePoint.toStringAsFixed(2),
                style: const TextStyle(
                  color: blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${course.credits} Credits • '
                  '${course.grade.toStringAsFixed(1)}% • $letter',
                  style: const TextStyle(fontSize: 13, color: mutedColor),
                ),
              ),
              IconButton(
                tooltip: 'Edit Course',
                onPressed: () => showCourseDialog(index: index),
                icon: const Icon(Icons.edit_outlined, color: blue),
              ),
              IconButton(
                tooltip: 'Delete Course',
                onPressed: () => deleteCourse(index),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MAIN DASHBOARD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GPA Tracker',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your academic progress',
                          style: TextStyle(color: mutedColor, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.school_outlined, size: 35, color: blue),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 650),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // BLUE GPA CARD
                        Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [blue, darkBlue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x301D4ED8),
                                blurRadius: 18,
                                offset: Offset(0, 7),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Current Semester GPA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${semesterGPA.toStringAsFixed(2)} / 4.00',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: (semesterGPA / 4).clamp(0.0, 1.0),
                                  minHeight: 9,
                                  backgroundColor: const Color(0xFF93C5FD),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            statCard(
                              title: 'Cumulative GPA',
                              value: cumulativeGPA.toStringAsFixed(2),
                              icon: Icons.bar_chart,
                            ),
                            const SizedBox(width: 12),
                            statCard(
                              title: 'Completed Credits',
                              value: totalCredits.toString(),
                              icon: Icons.menu_book_outlined,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        OutlinedButton.icon(
                          onPressed: setPreviousGPA,
                          icon: const Icon(Icons.edit_note),
                          label: const Text('Set Previous GPA & Credits'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: blue,
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: blue),
                            padding: const EdgeInsets.all(15),
                          ),
                        ),

                        const SizedBox(height: 28),

                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'My Courses',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            Text(
                              '${courses.length} Courses',
                              style: const TextStyle(color: mutedColor),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        if (courses.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.menu_book_outlined,
                                  size: 40,
                                  color: mutedColor,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'No courses added yet.',
                                  style: TextStyle(color: mutedColor),
                                ),
                              ],
                            ),
                          ),

                        for (int i = 0; i < courses.length; i++) courseCard(i),

                        const SizedBox(height: 18),

                        // ADD COURSE BUTTON
                        ElevatedButton.icon(
                          onPressed: () => showCourseDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text(
                            'Add Course',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: teal,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: teal,
                            disabledForegroundColor: Colors.white,
                            elevation: 3,
                            padding: const EdgeInsets.all(18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        OutlinedButton.icon(
                          onPressed: showFinalExamPlanner,
                          icon: const Icon(Icons.calculate_outlined),
                          label: const Text(
                            'Final Exam Planner',
                            style: TextStyle(fontSize: 17),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: blue,
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: blue),
                            padding: const EdgeInsets.all(18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
