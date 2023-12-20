/// Converts the provided Swift `Error` into a `FlutterError`.
func getFlutterError(_ error: Error) -> FlutterError {
  let e = error as NSError
  return FlutterError(
    code: "Error: \(e.code)",
    message: e.domain,
    details: error.localizedDescription
  )
}
