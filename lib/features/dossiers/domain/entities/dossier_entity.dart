enum DossierStatut { en_attente, en_cours, urgent, resolu, rejete }

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

  bool get isDemande   => statut == DossierStatut.en_attente;
  bool get isAssigned  => specialisteNom != null;
}
