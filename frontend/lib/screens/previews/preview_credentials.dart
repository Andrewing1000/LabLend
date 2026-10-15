/// Cuenta con la que inician sesión las vistas previas. Se pasa al ejecutarlas:
/// flutter run -t lib/screens/previews/list_user_test.dart \
///   --dart-define=PREVIEW_EMAIL=<correo> --dart-define=PREVIEW_PASSWORD=<contraseña>
const String previewEmail = String.fromEnvironment('PREVIEW_EMAIL');
const String previewPassword = String.fromEnvironment('PREVIEW_PASSWORD');
