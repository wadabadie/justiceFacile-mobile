abstract final class ApiConstants {
  static const baseUrl = 'https://justicefacile-backend-production.up.railway.app/api/v1';

  // ── Auth ────────────────────────────────────────────────────────────────────
  static const login           = '$baseUrl/auth/login/';
  static const register        = '$baseUrl/auth/register/';
  static const tokenRefresh    = '$baseUrl/auth/token/refresh/';
  static const logout          = '$baseUrl/auth/logout/';
  static const me              = '$baseUrl/auth/me/';
  static const verifyEmail     = '$baseUrl/auth/verify-email/';
  static const resendCode      = '$baseUrl/auth/resend-verification/';
  static const googleAuth      = '$baseUrl/auth/google/';
  static const toggleDeuxFa    = '$baseUrl/auth/deux-fa/';
  static const valider2fa      = '$baseUrl/auth/valider-2fa/';
  static const loginDiscret    = '$baseUrl/auth/login-discret/';
  static const configurerPin   = '$baseUrl/auth/configurer-pin-detresse/';
  static const supprimerCompte = '$baseUrl/auth/supprimer-mon-compte/';
  static const fcmToken        = '$baseUrl/auth/fcm-token/';

  // ── Textes de loi ───────────────────────────────────────────────────────────
  static const textesLoi         = '$baseUrl/textes-loi/';
  static String texteLoi(int id) => '$baseUrl/textes-loi/$id/';

  // ── Demandes ────────────────────────────────────────────────────────────────
  static const demandes                        = '$baseUrl/demandes/';
  static const demandesDisponibles             = '$baseUrl/demandes/disponibles/';
  static String demandeProposer(int id)        => '$baseUrl/specialiste/demandes/$id/proposer/';
  static String demandeConfirmer(int id)       => '$baseUrl/citoyen/demandes/$id/confirmer/';
  static String demandePreuves(int id)         => '$baseUrl/demandes/$id/preuves/';
  static String preuveDelete(int id)           => '$baseUrl/preuves/$id/';
  static const adminEscalade                   = '$baseUrl/admin/executer-escalade/';

  // ── Dossiers ────────────────────────────────────────────────────────────────
  static const dossiers                              = '$baseUrl/dossiers/';
  static String dossier(int id)                      => '$baseUrl/dossiers/$id/';
  static String dossierCompteRendu(int id)           => '$baseUrl/specialiste/dossiers/$id/comptes-rendus/';
  static String dossierStatut(int id)                => '$baseUrl/specialiste/dossiers/$id/statut/';
  static String dossierProposerResolution(int id)    => '$baseUrl/specialiste/dossiers/$id/proposer-resolution/';
  static String dossierConfirmerResolution(int id)   => '$baseUrl/citoyen/dossiers/$id/confirmer-resolution/';
  static String dossierAnalyseIa(int id)             => '$baseUrl/specialiste/dossiers/$id/analyse-ia/';
  static String dossierRemplacerSpecialiste(int id)  => '$baseUrl/admin/dossiers/$id/remplacer-specialiste/';
  static String dossierExportPdf(int id)             => '$baseUrl/dossiers/$id/export-pdf/';

  // ── Tchat sécurisé ──────────────────────────────────────────────────────────
  static String dossierCanaux(int id)                        => '$baseUrl/dossiers/$id/canaux/';
  static String dossierMessages(int id, String canal)        => '$baseUrl/dossiers/$id/messages/$canal/';
  static String dossierMessagesNonLus(int id, String canal)  => '$baseUrl/dossiers/$id/messages/$canal/non-lus/';

  // ── Agent juridique ─────────────────────────────────────────────────────────
  static const agentJuridique           = '$baseUrl/agent-juridique/';
  static const agentJuridiqueHistorique = '$baseUrl/agent-juridique/historique/';

  // ── Spécialistes ────────────────────────────────────────────────────────────
  static const specialistes                  = '$baseUrl/specialistes/';
  static const soumettreDocuments            = '$baseUrl/specialistes/soumettre-documents/';
  static const adminSpecialistesEnAttente    = '$baseUrl/admin/specialistes-en-attente/';
  static String adminCertifier(int id)       => '$baseUrl/admin/specialistes/$id/certifier/';

  // ── Ressources & FAQ ────────────────────────────────────────────────────────
  static const ressources                  = '$baseUrl/juriste/ressources-juridiques/';
  static String ressource(int id)          => '$baseUrl/ressources-juridiques/$id/';
  static String ressourceModerer(int id)   => '$baseUrl/ressources-juridiques/$id/moderer/';
  static const faq                         = '$baseUrl/juriste/faq/';
  static String faqItem(int id)            => '$baseUrl/faq/$id/';
  static String faqModerer(int id)         => '$baseUrl/faq/$id/moderer/';

  // ── Structures d'aide ───────────────────────────────────────────────────────
  static const structuresAide          = '$baseUrl/structures-aide/';
  static String structureAide(int id)  => '$baseUrl/structures-aide/$id/';

  // ── Notifications ───────────────────────────────────────────────────────────
  static const notifications             = '$baseUrl/notifications/';
  static const notificationsNonLues      = '$baseUrl/notifications/non-lues/';
  static String notificationLire(int id) => '$baseUrl/notifications/$id/lire/';
  static const notificationsToutLire     = '$baseUrl/notifications/tout-lire/';

  // ── Rendez-vous ─────────────────────────────────────────────────────────────
  static const mesDisponibilites                               = '$baseUrl/specialiste/rendez-vous/mes-disponibilites/';
  static String supprimerDispo(int id)                         => '$baseUrl/specialiste/rendez-vous/mes-disponibilites/$id/';
  static String rdvDisponibilites(int dossierId, String canal) => '$baseUrl/dossiers/$dossierId/rendez-vous/disponibilites/$canal/';
  static String demanderRdv(int dossierId, String canal)       => '$baseUrl/dossiers/$dossierId/rendez-vous/$canal/';
  static const monPlanning                                     = '$baseUrl/specialiste/rendez-vous/mon-planning/';
  static String validerRdv(int id)                             => '$baseUrl/specialiste/rendez-vous/$id/valider/';
  static String tokenVisio(int id)                             => '$baseUrl/rendez-vous/$id/token-visio/';

  // ── Module ONG & Activités terrain ─────────────────────────────────────────
  static const activites                     = '$baseUrl/activites/';
  static String activite(int id)             => '$baseUrl/activites/$id/';
  static const mesActivites                  = '$baseUrl/mes-activites/';
  static String activiteInscription(int id)  => '$baseUrl/citoyen/activites/$id/inscription/';
  static String activiteAnnuler(int id)      => '$baseUrl/citoyen/activites/$id/annuler/';
  static const mesInscriptions               = '$baseUrl/citoyens/mes-inscriptions/';
  static String activiteParticipants(int id) => '$baseUrl/ong/activites/$id/participants/';
  static String inscriptionPresence(int id)  => '$baseUrl/ong/inscriptions/$id/presence/';
  static String activiteRapport(int id)      => '$baseUrl/ong/activites/$id/rapport/';

  // ── Témoignages anonymes ────────────────────────────────────────────────────
  static const temoignages                       = '$baseUrl/temoignages/';
  static String temoignageSoutenir(int id)       => '$baseUrl/temoignages/$id/soutenir/';
  static const adminTemoignagesEnAttente         = '$baseUrl/admin/temoignages-en-attente/';
  static String adminTemoignageModerer(int id)   => '$baseUrl/admin/temoignages/$id/moderer/';

  // ── Alerte SOS ──────────────────────────────────────────────────────────────
  static const sosDeclencer       = '$baseUrl/sos/declencher/';
  static const sosMesAlertes      = '$baseUrl/sos/mes-alertes/';
  static const sosAlertesRecues   = '$baseUrl/sos/alertes-recues/';
  static String sosStatut(int id) => '$baseUrl/sos/$id/statut/';

  // ── Parentalité positive ────────────────────────────────────────────────────
  static const parentaliteContenus                = '$baseUrl/parentalite/contenus/';
  static String parentaliteContenu(int id)        => '$baseUrl/parentalite/contenus/$id/';
  static String parentaliteContenuLu(int id)      => '$baseUrl/parentalite/contenus/$id/lu/';
  static String parentaliteQuiz(int id)           => '$baseUrl/parentalite/contenus/$id/quiz/';
  static String parentaliteQuizSoumettre(int id)  => '$baseUrl/parentalite/quiz/$id/soumettre/';
  static const parentaliteProgressions            = '$baseUrl/parentalite/mes-progressions/';
  static const agentParentalite                   = '$baseUrl/agent-parentalite/';
  static const agentParentaliteHistorique         = '$baseUrl/agent-parentalite/historique/';

  // ── Paiements & micro-dons ──────────────────────────────────────────────────
  static const paiementInitierDon = '$baseUrl/paiement/initier-don/';
  static const paiementWebhook    = '$baseUrl/paiement/webhook/notchpay/';

  // ── Admin ───────────────────────────────────────────────────────────────────
  static const adminDashboardStats    = '$baseUrl/admin/dashboard-stats/';
  static const adminJournalAudit      = '$baseUrl/admin/journal-audit/';
  static const adminExportDossiersCsv = '$baseUrl/admin/export/dossiers-csv/';
  static const adminExportRapportPdf  = '$baseUrl/admin/export/rapport-global-pdf/';
}
