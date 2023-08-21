import "package:flutter/material.dart";

import "../../utils/progress_report.dart";

class ProgressReportTab extends StatelessWidget {
  const ProgressReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(getProgressReport());
  }
}
