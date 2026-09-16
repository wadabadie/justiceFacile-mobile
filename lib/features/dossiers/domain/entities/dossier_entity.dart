enum DossierStatut { en_attente, approuve, en_cours, urgent, resolu, rejete }

class DossierEntity {
  const DossierEntity({
    required this.id,
    required this.numero,
    required this.titre,
    required this.categorie,
    required this.description,
    required this.statut,
    required this.dateCreation,
    required this.dateMaj,
    this.specialisteNom,
    this.specialisteRole,
    this.region,
  });

  final int id;
  final String numero;
  final String titre;
  final String categorie;
  final String description;
  final DossierStatut statut;
  final DateTime dateCreation;
  final DateTime dateMaj;
  final String? specialisteNom;
  final String? specialisteRole;
  final String? region;

  bool get isDemande  => statut == DossierStatut.en_attente || statut == DossierStatut.approuve;
  bool get isAssigned => specialisteNom != null;

  // Builds from GET /demandes/ item.
  factory DossierEntity.fromDemande(Map<String, dynamic> json) {
    final estUrgent = json['est_urgent'] as bool? ?? false;
    final statutRaw = (json['statut'] as String? ?? '').toUpperCase();

    DossierStatut statut;
    if (estUrgent) {
      statut = DossierStatut.urgent;
    } else {
      statut = switch (statutRaw) {
        'REJETE'      => DossierStatut.rejete,
        'APPROUVE'    => DossierStatut.approuve,
        'EN_COURS'    => DossierStatut.en_cours,
        'PROPOSITION' => DossierStatut.en_attente,
        _             => DossierStatut.en_attente,
      };
    }

    return DossierEntity(
      id:           json['id'] as int,
      numero:       json['code_reference'] as String? ?? '',
      titre:        json['titre'] as String? ?? '',
      categorie:    json['categorie_display'] as String? ?? json['categorie'] as String? ?? '',
      description:  json['resume_public'] as String? ?? json['description'] as String? ?? '',
      statut:       statut,
      dateCreation: DateTime.tryParse(json['date_creation'] as String? ?? '') ?? DateTime.now(),
      dateMaj:      DateTime.tryParse(json['date_modification'] as String? ?? '') ?? DateTime.now(),
    );
  }

  // Builds from GET /dossiers/ item.
  factory DossierEntity.fromDossier(Map<String, dynamic> json) {
    final demande    = json['demande_details'] as Map<String, dynamic>? ?? {};
    final statutRaw  = (json['statut'] as String? ?? '').toUpperCase();

    final statut = switch (statutRaw) {
      'RESOLU'  => DossierStatut.resolu,
      'ARCHIVE' => DossierStatut.resolu,
      _         => DossierStatut.en_cours,
    };

    final nomJuriste = json['nom_juriste'] as String? ?? '';
    final nomPsy     = json['nom_psychologue'] as String? ?? '';
    final nomOng     = json['nom_ong'] as String? ?? '';

    String? specialisteNom;
    String? specialisteRole;

    if (nomJuriste.isNotEmpty && !nomJuriste.startsWith('Aucun')) {
      specialisteNom  = nomJuriste;
      specialisteRole = 'Juriste';
    } else if (nomPsy.isNotEmpty && !nomPsy.startsWith('Aucun')) {
      specialisteNom  = nomPsy;
      specialisteRole = 'Psychologue';
    } else if (nomOng.isNotEmpty && !nomOng.startsWith('Aucune')) {
      specialisteNom  = nomOng;
      specialisteRole = 'ONG';
    }

    return DossierEntity(
      id:            json['id'] as int,
      numero:        demande['code_reference'] as String? ?? '',
      titre:         demande['titre'] as String? ?? '',
      categorie:     demande['categorie_display'] as String? ?? demande['categorie'] as String? ?? '',
      description:   demande['resume_public'] as String? ?? demande['description'] as String? ?? '',
      statut:        statut,
      dateCreation:  DateTime.tryParse(json['date_creation'] as String? ?? '') ?? DateTime.now(),
      dateMaj:       DateTime.tryParse(json['date_modification'] as String? ?? '') ?? DateTime.now(),
      specialisteNom:  specialisteNom,
      specialisteRole: specialisteRole,
    );
  }
}
