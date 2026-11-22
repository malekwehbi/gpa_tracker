import 'course.dart';

class GPACalculator {
  // Convert percentage to GPA
  static double calculateGradePoint(double grade) {
    if (grade >= 90) return 4.0;
    if (grade >= 60) return (grade - 50) / 10;
    return 0.0;
  }

  // Convert percentage to letter grade
  static String calculateLetterGrade(double grade) {
    if (grade >= 90) return 'A';
    if (grade >= 85) return 'B+';
    if (grade >= 80) return 'B';
    if (grade >= 75) return 'C+';
    if (grade >= 70) return 'C';
    if (grade >= 65) return 'D+';
    if (grade >= 60) return 'D';
    return 'F';
  }

  // Calculate semester credits
  static int calculateSemesterCredits(List<Course> courses) {
    int total = 0;

    for (final course in courses) {
      total += course.credits;
    }

    return total;
  }

  // Calculate semester GPA
  static double calculateSemesterGPA(List<Course> courses) {
    final credits = calculateSemesterCredits(courses);

    if (credits == 0) return 0.0;

    double totalPoints = 0;

    for (final course in courses) {
      totalPoints += calculateGradePoint(course.grade) * course.credits;
    }

    return totalPoints / credits;
  }

  // Calculate cumulative GPA
  static double calculateCumulativeGPA({
    required double previousGPA,
    required int previousCredits,
    required List<Course> courses,
  }) {
    final semesterCredits = calculateSemesterCredits(courses);
    final totalCredits = previousCredits + semesterCredits;

    if (totalCredits == 0) return 0.0;

    final semesterGPA = calculateSemesterGPA(courses);

    return (previousGPA * previousCredits + semesterGPA * semesterCredits) /
        totalCredits;
  }
}
