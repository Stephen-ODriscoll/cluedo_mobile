
int _lineNumber = 0;
String _progressReport = "";

String getProgressReport() {
  return _progressReport;
}

void reportProgress(String message) {
  _progressReport += "${++_lineNumber} | $message\n";
}

void resetProgressReport([String message = ""]) {
  _lineNumber = 0;
  _progressReport = "";

  reportProgress(message);
}
