/// Cuenta con la que inician sesión las vistas previas. Se pasa al ejecutarlas:
/// flutter run -t lib/screens/previews/list_user_test.dart \
///   --dart-define=PREVIEW_USER=<código de usuario> --dart-define=PREVIEW_PASSWORD=<contraseña>
const String previewUser = String.fromEnvironment('PREVIEW_USER');
const String previewPassword = String.fromEnvironment('PREVIEW_PASSWORD');
