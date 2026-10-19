// Dirección del backend. Por omisión, la de desarrollo local; al compilar para
// el servidor publicado se pasa con --dart-define=SERVER_URL=https://…
const String serverURL_phone = String.fromEnvironment(
  'SERVER_URL',
  defaultValue: 'http://10.0.2.2:8000',
);

const String serverURL_web = String.fromEnvironment(
  'SERVER_URL',
  defaultValue: 'http://localhost:8000',
);
