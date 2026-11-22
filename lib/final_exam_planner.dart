class FinalExamPlanner {
  // Calculate the final exam score needed
  static double calculateRequiredFinal({
    required double currentGrade,
    required double finalWeight,
    required double targetGrade,
  }) {
    return (targetGrade - currentGrade * (1 - finalWeight / 100)) /
        (finalWeight / 100);
  }

  // Calculate overall course grade
  static double calculateOverallGrade({
    required double currentGrade,
    required double finalWeight,
    required double finalScore,
  }) {
    return currentGrade * (1 - finalWeight / 100) +
        finalScore * (finalWeight / 100);
  }
}
