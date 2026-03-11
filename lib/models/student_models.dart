class StudentProfile {
  final String registrationId;
  final String name;
  final String email;
  final String mobile;
  final String loanNumber;
  final String sanctionAmount;
  final String totalDisbursed;
  final String course;
  final String institute;

  StudentProfile({
    required this.registrationId,
    required this.name,
    required this.email,
    required this.mobile,
    this.loanNumber = 'N/A',
    this.sanctionAmount = '0',
    this.totalDisbursed = '0',
    this.course = 'N/A',
    this.institute = 'N/A',
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      registrationId: json['registrationId']?.toString() ?? '',
      name: json['name'] ?? 'Student',
      email: json['emailId'] ?? 'N/A',
      mobile: json['phoneNo'] ?? 'N/A',
      course: json['courseName'] ?? 'N/A',
      institute: json['instituteName'] ?? 'N/A',
    );
  }

  StudentProfile copyWith({
    String? loanNumber,
    String? sanctionAmount,
    String? totalDisbursed,
  }) {
    return StudentProfile(
      registrationId: registrationId,
      name: name,
      email: email,
      mobile: mobile,
      course: course,
      institute: institute,
      loanNumber: loanNumber ?? this.loanNumber,
      sanctionAmount: sanctionAmount ?? this.sanctionAmount,
      totalDisbursed: totalDisbursed ?? this.totalDisbursed,
    );
  }
}

class DisbursementRecord {
  final String srNo;
  final String amount;
  final String date;
  final String status;
  final String mode;
  final String utrNo;

  DisbursementRecord({
    required this.srNo,
    required this.amount,
    required this.date,
    required this.status,
    required this.mode,
    this.utrNo = 'N/A',
  });

  factory DisbursementRecord.fromJson(Map<String, dynamic> json) {
    return DisbursementRecord(
      srNo: json['INST_NO']?.toString() ?? '1',
      amount: json['DISBURSE_LOAN_AMOUNT']?.toString() ?? '0',
      date: json['DISBURSEMENT_DATE'] ?? 'N/A',
      status: json['Status'] == 'C' ? 'Success' : 'Pending',
      mode: json['MODE_OF_PAYMENT'] ?? 'N/A',
      utrNo: json['UTR_no'] ?? 'N/A',
    );
  }
}
