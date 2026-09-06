const String rolePetugas = 'PETUGAS';
const String roleWarga = 'WARGA';
const mobileRoles = {rolePetugas, roleWarga};

const Map<String, List<String>> routeRoles = {
  '/tasks': [rolePetugas],
  '/surveyor': [rolePetugas],
  '/form-survei': [rolePetugas],
  '/riwayat': [rolePetugas],
  '/warga': [roleWarga],
  '/review': [roleWarga],
  '/sanggahan': [roleWarga],
  '/dashboard': [rolePetugas, roleWarga],
  '/notifications': [rolePetugas, roleWarga],
  '/settings': [rolePetugas, roleWarga],
  '/profile': [rolePetugas, roleWarga],
  '/stats': [rolePetugas, roleWarga],
  '/map': [rolePetugas, roleWarga],
  '/map-picker': [rolePetugas, roleWarga],
  '/create': [rolePetugas, roleWarga],
  '/create-anonymous': [rolePetugas, roleWarga],
  '/laporan': [rolePetugas, roleWarga],
  '/reports': [rolePetugas, roleWarga],
  '/detail': [rolePetugas, roleWarga],
  '/evidence': [rolePetugas, roleWarga],
  '/sync-center': [rolePetugas, roleWarga],
  '/sync': [rolePetugas, roleWarga],
};

const Map<String, String> roleHome = {
  rolePetugas: '/tasks',
  roleWarga: '/dashboard',
};
