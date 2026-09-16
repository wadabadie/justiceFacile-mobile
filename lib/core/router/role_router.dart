/// Central role → route resolver. Every place that redirects a user after
/// authentication (splash auto-redirect, login success, verify-email success,
/// registration flow) must go through here so the landing screen matches the
/// role instead of always dumping everyone on the citoyen dashboard.
String routeForRole(String? role) {
  final r = (role ?? '').toLowerCase();
  switch (r) {
    case 'juriste':
    case 'psychologue':
      return '/home-specialiste';
    case 'ong':
      return '/home-ong';
    case 'admin':
      return '/admin';
    case 'citoyen':
    case 'victime_vbg':
    default:
      return '/home';
  }
}

enum UserRole { citoyen, victimeVbg, juriste, psychologue, ong, admin }

UserRole parseRole(String? role) {
  final r = (role ?? '').toLowerCase();
  return switch (r) {
    'juriste'     => UserRole.juriste,
    'psychologue' => UserRole.psychologue,
    'ong'         => UserRole.ong,
    'admin'       => UserRole.admin,
    'victime_vbg' => UserRole.victimeVbg,
    _             => UserRole.citoyen,
  };
}

bool isSpecialiste(String? role) {
  final r = parseRole(role);
  return r == UserRole.juriste || r == UserRole.psychologue || r == UserRole.ong;
}
