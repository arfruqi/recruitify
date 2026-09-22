class InterviewQuestion {
  final String id;
  final String jobId;
  final String questionText;

  InterviewQuestion({
    required this.id,
    required this.jobId,
    required this.questionText,
  });

  factory InterviewQuestion.fromJson(Map<String, dynamic> json) {
    return InterviewQuestion(
      id: json['id'],
      jobId: json['job_id'],
      questionText: json['question_text'],
    );
  }
}

class InterviewAnswer {
  final String id;
  final String applicationId;
  final String questionId;
  final String answerText;

  InterviewAnswer({
    required this.id,
    required this.applicationId,
    required this.questionId,
    required this.answerText,
  });

  factory InterviewAnswer.fromJson(Map<String, dynamic> json) {
    return InterviewAnswer(
      id: json['id'],
      applicationId: json['application_id'],
      questionId: json['question_id'],
      answerText: json['answer_text'],
    );
  }
}
