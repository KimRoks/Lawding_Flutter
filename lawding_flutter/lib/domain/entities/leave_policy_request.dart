class WorkTimeSlot {
  final String start; // "HH:mm"
  final String end; // "HH:mm"

  const WorkTimeSlot({required this.start, required this.end});
}

class LeavePolicyRequest {
  final String nickname;
  final bool acceptedTerms;
  final int leaveAccrualBasis; // 1: 입사일기준, 2: 회계연도기준
  final int? fiscalYearBaseMonth; // 1-12, 회계연도기준일 때만 사용
  final String hireDate; // "YYYY-MM-DD"
  final Map<String, WorkTimeSlot> workPattern; // "MONDAY" → {start, end}
  final Map<String, WorkTimeSlot> breakTimePattern; // "MONDAY" → {start, end}
  final int companySize;
  final double totalLeave;
  final double usedLeave;

  const LeavePolicyRequest({
    required this.nickname,
    required this.acceptedTerms,
    required this.leaveAccrualBasis,
    this.fiscalYearBaseMonth,
    required this.hireDate,
    required this.workPattern,
    required this.breakTimePattern,
    required this.companySize,
    required this.totalLeave,
    required this.usedLeave,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'nickname': nickname,
      'acceptedTerms': acceptedTerms,
      'leaveAccrualBasis': leaveAccrualBasis,
      'hireDate': hireDate,
      'workPattern': {
        for (final e in workPattern.entries)
          e.key: {'start': e.value.start, 'end': e.value.end},
      },
      'breakTimePattern': {
        for (final e in breakTimePattern.entries)
          e.key: {'start': e.value.start, 'end': e.value.end},
      },
      'companySize': companySize,
      'totalLeave': totalLeave,
      'usedLeave': usedLeave,
    };
    if (fiscalYearBaseMonth != null) {
      json['fiscalYearBaseMonth'] = fiscalYearBaseMonth;
    }
    return json;
  }
}
