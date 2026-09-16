import 'package:flutter/material.dart';

class AppStrings {
  const AppStrings._({
    // ── App / Splash ──────────────────────────────────────────────────────────
    required this.appName,
    required this.splashTagline,
    required this.splashPill1, required this.splashPill2, required this.splashPill3,
    required this.btnLogin, required this.btnRegister,
    // ── Onboarding ────────────────────────────────────────────────────────────
    required this.ob1Title, required this.ob1Desc,
    required this.ob2Title, required this.ob2Desc,
    required this.ob3Title, required this.ob3Desc,
    required this.btnNext, required this.btnStart, required this.btnSkip,
    // ── Login ─────────────────────────────────────────────────────────────────
    required this.loginTitle, required this.loginSubtitle,
    required this.fieldEmail, required this.fieldPassword,
    required this.loginForgot, required this.orSeparator, required this.continueGoogle,
    required this.loginNoAccount, required this.btnSignUp,
    // ── Register ──────────────────────────────────────────────────────────────
    required this.registerTitle, required this.registerSubtitle,
    required this.fieldFirstName, required this.fieldLastName,
    required this.fieldConfirmPassword, required this.fieldRole,
    required this.roleCitoyen, required this.roleJuriste,
    required this.rolePsychologue, required this.roleOng,
    required this.termsAccept, required this.registerHasAccount,
    // ── Verify email ──────────────────────────────────────────────────────────
    required this.verifyEmailTitle, required this.verifyEmailDesc, required this.verifyEmailBtn,
    required this.codeIncomplete, required this.codeInvalid,
    required this.codeResent, required this.codeNotReceived,
    required this.resendCode, required this.backToLogin,
    required this.goVerifyEmail,
    // ── Home ──────────────────────────────────────────────────────────────────
    required this.homeGreeting, required this.homeSearch,
    required this.homeQuickActions, required this.homeRecentDossiers,
    required this.homeVbgLabel, required this.homeVbgTitle,
    required this.homeVbgDesc, required this.homeVbgBtn,
    required this.homeQaDossier, required this.homeQaIa,
    required this.homeQaJuriste, required this.homeQaLois,
    // ── Tips (showcase) ───────────────────────────────────────────────────────
    required this.tipSearch, required this.tipActions,
    required this.tipVbg, required this.tipMessages,
    required this.tipGotIt, required this.tipNext,
    // ── Dossiers ──────────────────────────────────────────────────────────────
    required this.dossiersTitle,
    required this.dossiersNewBtn,
    required this.dossiersSearch,
    required this.filterAll, required this.filterDemandes,
    required this.filterInProgress, required this.filterUrgent, required this.filterResolved,
    required this.demandeAwaitAssignment, required this.demandeBtnFollow,
    required this.dossierBtnView,
    required this.dossiersEmpty, required this.dossiersEmptyDesc,
    required this.statusUrgent, required this.statusInProgress,
    required this.statusResolved, required this.statusPending, required this.statusRejected, required this.statusApproved,
    required this.statusProposition,
    required this.specialistAssigned,
    // ── New Dossier ───────────────────────────────────────────────────────────
    required this.newDossierTitle,
    required this.ndStep1, required this.ndStep2, required this.ndStep3,
    required this.ndSelectCategory, required this.ndSelectCategoryDesc,
    required this.ndTitleLabel, required this.ndTitleDesc, required this.ndTitleHint,
    required this.ndDescLabel, required this.ndDescDesc, required this.ndDescHint,
    required this.ndMinChars,
    required this.ndRegionLabel, required this.ndRegionDesc,
    required this.ndReviewTitle, required this.ndReviewBanner, required this.ndReviewBannerDesc,
    required this.ndReviewCategory, required this.ndReviewTitleLabel,
    required this.ndReviewDesc, required this.ndReviewRegion,
    required this.ndAiTitle, required this.ndAiDesc,
    required this.ndAnonLabel, required this.ndAnonDesc,
    required this.ndPrivacy, required this.ndSuccess, required this.btnSubmit,
    // ── Juristes ──────────────────────────────────────────────────────────────
    required this.juristesTitle, required this.juristesSubtitle,
    required this.juristesSearch,
    required this.juristesCertified, required this.juristesContact,
    required this.juristesNoDossierMsg,
    required this.juristesNoDossierCreate, required this.juristesNoDossierView,
    required this.juristesEmpty, required this.juristesEmptyDesc,
    // ── Textes de loi ─────────────────────────────────────────────────────────
    required this.loisTitle, required this.loisSubtitle,
    required this.loisSearch, required this.loisKeywords,
    required this.loisExcerpt, required this.loisReadMore, required this.loisReduce,
    required this.loisEmpty, required this.loisEmptyDesc, required this.loisEmptyHint,
    // ── Messagerie ────────────────────────────────────────────────────────────
    required this.messagerieTitle, required this.messagerieSubtitle,
    required this.messagerieEmpty, required this.messagerieEmptyDesc,
    // ── Chat ──────────────────────────────────────────────────────────────────
    required this.chatSecure, required this.chatEncryptionBanner,
    required this.chatEmpty, required this.chatHint,
    // ── VBG ───────────────────────────────────────────────────────────────────
    required this.vbgModuleLabel, required this.vbgTitle, required this.vbgConfidential,
    required this.sosPressInstruction, required this.sosCall, required this.sosAlertRecorded,
    required this.vbgNeedHelp, required this.vbgEmergency,
    required this.vbgPolice, required this.vbgFirefighters, required this.vbgSamu,
    required this.btnCall,
    required this.vbgRightsLabel,
    required this.vbgRightsText1, required this.vbgRightsText2, required this.vbgRightsText3,
    required this.vbgAllLaws, required this.vbgAnonymity,
    required this.vbgReportAnonymous, required this.vbgConsultLawyer,
    required this.vbgPsySupport, required this.vbgNgoPartners, required this.vbgComingSoon,
    // ── Search ────────────────────────────────────────────────────────────────
    required this.searchHint, required this.searchQuickAccess,
    required this.searchLaws, required this.searchFaq,
    required this.searchLawyers, required this.searchAi, required this.searchFiles,
    required this.searchNoResultsHint, required this.searchAskAi,
    // ── AI Agent ──────────────────────────────────────────────────────────────
    required this.aiTitle, required this.aiSubtitle, required this.aiOnline,
    required this.aiWelcome, required this.aiSubhead, required this.aiDisclaimer,
    required this.aiQuestionsLabel, required this.aiInputHint, required this.aiListening,
    // ── Profil ────────────────────────────────────────────────────────────────
    required this.profilTitle,
    required this.profilSectionPersonal, required this.profilSectionPreferences,
    required this.profilSectionSecurity,
    required this.profilFullName, required this.profilEmail,
    required this.profilPhone, required this.profilPhoneEmpty,
    required this.profilRegion, required this.profilRegionEmpty,
    required this.profilNotifications, required this.profilLanguage,
    required this.profilVoiceAssistant, required this.profilVoiceInfo,
    required this.profilTwoFactor, required this.profilPrivacy,
    required this.profilEnabled, required this.profilDisabled,
    required this.profilLogout, required this.profilDeleteAccount,
    required this.profilVersion,
    required this.profilUpdated, required this.twoFaInProgress,
    required this.profilEditTitle, required this.profilSave,
    required this.logoutTitle, required this.logoutMsg, required this.logoutBtn,
    required this.deleteTitle, required this.deleteMsg, required this.deleteBtn,
    // ── Admin ─────────────────────────────────────────────────────────────────
    required this.adminTitle, required this.adminBadge,
    required this.adminOverview, required this.adminActions,
    required this.adminUsers, required this.adminFiles,
    required this.adminInProgress, required this.adminResolved,
    required this.adminVbgReports, required this.adminSpecialists,
    required this.adminCertify, required this.adminModerate,
    required this.adminReports, required this.adminEscalate, required this.adminEscalating,
    required this.adminAlertsRequired, required this.adminEscalateSuccess,
    // ── Notifications ─────────────────────────────────────────────────────────
    required this.notificationsTitle, required this.notificationsMarkAll,
    required this.notificationsEmpty, required this.notificationsEmptyDesc,
    // ── Shared ────────────────────────────────────────────────────────────────
    required this.btnRetry, required this.btnCancel, required this.btnOk,
    required this.btnConsult,
    required this.errRequired, required this.errEmail,
    required this.errPasswordMin, required this.errPasswordMatch,
    required this.errCredentials, required this.errGeneric,
    // ── Rapports ──────────────────────────────────────────────────────────────
    required this.rapportsTitle, required this.rapportsAuditLog, required this.rapportsEmpty,
    required this.rapportsCsvSuccess, required this.rapportsPdfSuccess,
    // ── Dossier detail ────────────────────────────────────────────────────────
    required this.detailMaDemande, required this.detailMonDossier,
    required this.detailInfoTitle, required this.detailCreeLe, required this.detailMisAJour,
    required this.detailDescription, required this.detailVoirPlus, required this.detailVoirMoins,
    required this.detailPendingTitle, required this.detailPendingDesc,
    required this.detailApprovedTitle, required this.detailApprovedDesc,
    required this.detailSpecialisteAssigne, required this.detailComptesRendus,
    required this.detailNoCr, required this.detailCrLoadError,
    required this.detailResolutionTitle, required this.detailResolutionDesc,
    required this.detailBtnAccept, required this.detailBtnRefuse,
    required this.detailResolutionAccepted, required this.detailResolutionRefused,
    required this.detailResolutionError, required this.detailConfirmRefuseTitle,
    required this.detailConfirmRefuseMsg,
    required this.propositionTitle, required this.propositionSubtitle,
    required this.propositionBtnAccept, required this.propositionAccepted,
    required this.propositionRefused, required this.propositionError,
    required this.propositionConfirmRefuseTitle, required this.propositionConfirmRefuseMsg,
    // ── Forgot password ───────────────────────────────────────────────────────
    required this.forgotTitle, required this.forgotSubtitle,
    required this.forgotEmailHint, required this.forgotBtnSend,
    required this.forgotError,
    // ── Reset password (OTP) ──────────────────────────────────────────────────
    required this.resetTitle,
    required this.resetCodeLabel, required this.resetResendCode,
    required this.resetNewPwdHint, required this.resetConfirmPwdHint,
    required this.resetBtnConfirm, required this.resetSuccessTitle,
    required this.resetSuccessDesc, required this.resetSuccessBackLogin,
    required this.resetErrExpired, required this.resetErrInvalidCode,
    required this.resetErrGeneric,
    // ── Prise de RDV ──────────────────────────────────────────────────────────
    required this.rdvBookTitle, required this.rdvBookBtn,
    required this.rdvConfirmTitle, required this.rdvConfirmBtn,
    required this.rdvBookedSuccess, required this.rdvBookedError,
    required this.rdvNoSlotsTitle, required this.rdvNoSlotsDesc,
    // ── Certification ────────────────────────────────────────────────────────
    required this.certTitle, required this.certMenuLabel,
    required this.certStatutNonSoumisTitle, required this.certStatutNonSoumisDesc,
    required this.certStatutEnAttenteTitle, required this.certStatutEnAttenteDesc,
    required this.certStatutValideTitle, required this.certStatutValideDesc,
    required this.certStatutRejeteTitle, required this.certStatutRejeteDesc,
    required this.certLabelNomStructure, required this.certLabelNumeroCarte,
    required this.certDocsTitle,
    required this.certDocCartePro, required this.certDocAgrement,
    required this.certDocDiplome, required this.certDocCni, required this.certDocPhotoOpt,
    required this.certDocPick, required this.certDocReplace,
    required this.certDocPickHint, required this.certDocOptional, required this.certDocUploaded,
    required this.certBtnSubmit, required this.certFooterNote,
    required this.certPickError, required this.certUploadError,
    required this.certFileTooBig, required this.certMissingDocs,
    required this.certSubmittedSuccess, required this.certRecapTitle,
    required this.certNotSpecialisteTitle, required this.certNotSpecialisteDesc,
    // ── Home spécialiste / ONG ────────────────────────────────────────────────
    required this.homeSpecCasDispoLabel, required this.homeSpecMesDossiersLabel,
    required this.homeSpecActionsTitle,
    required this.homeSpecPlanningLabel, required this.homeSpecPlanningDesc,
    required this.homeSpecMessagesLabel, required this.homeSpecMessagesDesc,
    required this.homeSpecProfileLabel, required this.homeSpecProfileDesc,
    required this.homeSpecCertifCta,
    required this.homeOngActivitesLabel, required this.homeOngActivitesActionLabel,
    required this.homeOngActivitesActionDesc, required this.homeOngDossiersActionDesc,
    // ── Cas disponibles ───────────────────────────────────────────────────────
    required this.casTitle, required this.casSubtitle,
    required this.casProposeBtn, required this.casProposeConfirmTitle,
    required this.casProposeConfirmBtn, required this.casProposeSuccess,
    required this.casProposeError,
    required this.casEmptyTitle, required this.casEmptyDesc,
    // ── Politique ─────────────────────────────────────────────────────────────
    required this.politiqueTitle, required this.politiqueLastUpdateLabel,
    required this.politiqueContactTitle, required this.politiqueContactDelay,
    // ── Activités ─────────────────────────────────────────────────────────────
    required this.activitesTitle, required this.activitesSubtitle,
    required this.activitesTab1, required this.activitesTab2,
    required this.activitesEmpty, required this.activitesNoInscriptions,
    required this.activitesInscrit, required this.activitesComplet,
    required this.activitesSInscrire, required this.activitesAnnulerInscription,
    required this.activitesInscriptionComplete,
    required this.activitesParticipants, required this.activitesRapport,
    required this.activitesPresent, required this.activitesMarquer,
    required this.activitesInscriptionConfirmee, required this.activitesInscriptionAnnulee,
    required this.activitesRapportGenere, required this.activitesPlaces,
    // ── Dons ──────────────────────────────────────────────────────────────────
    required this.donsTitle, required this.donsSubtitle, required this.donsImpactTitle,
    required this.donsChoixMontant, required this.donsMobileMoney,
    required this.donsNomSection, required this.donsMessageSection,
    required this.donsBtnPayer, required this.donsMontantMin, required this.donsMinVal,
    required this.donsNumInvalide, required this.donsAutre, required this.donsMontantPersonnalise,
    required this.donsNomDonateur, required this.donsAnonymeLabel, required this.donsMsgEncouragement,
    required this.donsSecurite, required this.donsConfirmTitle,
    required this.donsReferenceLabel, required this.donsReferenceCopied,
    required this.donsMerci, required this.donsCompris,
    required this.donsImpossible, required this.donsRedirection,
    required this.donsSummaryPrefix, required this.donsSummarySuffix,
    // ── Parentalité ───────────────────────────────────────────────────────────
    required this.parentaliteTitle, required this.parentaliteSubtitle,
    required this.parentaliteTab1, required this.parentaliteTab2, required this.parentaliteTab3,
    required this.parentaliteEmpty, required this.parentaliteProgressEmpty,
    required this.parentaliteLus, required this.parentaliteScoreMoyen,
    required this.parentaliteAgentBanner, required this.parentaliteAgentEmpty,
    required this.parentaliteHint, required this.parentaliteLu, required this.parentaliteNonLu,
    required this.parentaliteDemarrerQuiz, required this.parentaliteQuizTitle,
    required this.parentaliteSoumettre, required this.parentaliteRepondreToutes,
    required this.parentaliteExcellent, required this.parentaliteBien, required this.parentaliteReviser,
    // ── Planning ──────────────────────────────────────────────────────────────
    required this.planningTitle, required this.planningSubtitle,
    required this.planningTabAvenir, required this.planningTabPasses,
    required this.planningAucunAvenir, required this.planningAucunPasse,
    required this.planningRejoindreVisio, required this.planningSessionPrete,
    required this.planningSessionInfo, required this.planningCanal,
    required this.planningCopierToken, required this.planningTokenCopie,
    required this.planningFermer,
    required this.statutConfirme, required this.statutEnAttente,
    required this.statutAnnule, required this.statutTermine, required this.statutInconnu,
    required this.canalVisio, required this.canalChat, required this.canalPresentiel,
    // ── Témoignages ───────────────────────────────────────────────────────────
    required this.temoignagesTitle, required this.temoignagesSubtitle,
    required this.temoignagesEmpty, required this.temoignagesEmptyDesc,
    required this.temoignagesBtnTemoigner, required this.temoignagesValide,
    required this.temoignagesVoirMoins, required this.temoignagesLireSuite,
    required this.temoignagesPartagerTitle, required this.temoignagesPartagerDesc,
    required this.temoignagesHint, required this.temoignagesAnonyme,
    required this.temoignagesSoumettre, required this.temoignagesModeration,
    required this.temoignagesAujourdhui, required this.temoignagesHier,
    required this.temoignagesJoursLabel,
  });

  // ── App / Splash ────────────────────────────────────────────────────────────
  final String appName, splashTagline;
  final String splashPill1, splashPill2, splashPill3;
  final String btnLogin, btnRegister;
  // ── Onboarding ──────────────────────────────────────────────────────────────
  final String ob1Title, ob1Desc, ob2Title, ob2Desc, ob3Title, ob3Desc;
  final String btnNext, btnStart, btnSkip;
  // ── Login ────────────────────────────────────────────────────────────────────
  final String loginTitle, loginSubtitle, fieldEmail, fieldPassword;
  final String loginForgot, orSeparator, continueGoogle, loginNoAccount, btnSignUp;
  // ── Register ─────────────────────────────────────────────────────────────────
  final String registerTitle, registerSubtitle;
  final String fieldFirstName, fieldLastName, fieldConfirmPassword, fieldRole;
  final String roleCitoyen, roleJuriste, rolePsychologue, roleOng;
  final String termsAccept, registerHasAccount;
  // ── Verify email ─────────────────────────────────────────────────────────────
  final String verifyEmailTitle, verifyEmailDesc, verifyEmailBtn;
  final String codeIncomplete, codeInvalid, codeResent, codeNotReceived, resendCode, backToLogin;
  final String goVerifyEmail;
  // ── Home ─────────────────────────────────────────────────────────────────────
  final String homeGreeting, homeSearch;
  final String homeQuickActions, homeRecentDossiers;
  final String homeVbgLabel, homeVbgTitle, homeVbgDesc, homeVbgBtn;
  final String homeQaDossier, homeQaIa, homeQaJuriste, homeQaLois;
  // ── Tips ─────────────────────────────────────────────────────────────────────
  final String tipSearch, tipActions, tipVbg, tipMessages, tipGotIt, tipNext;
  // ── Dossiers ─────────────────────────────────────────────────────────────────
  final String dossiersTitle, dossiersNewBtn, dossiersSearch;
  final String filterAll, filterDemandes, filterInProgress, filterUrgent, filterResolved;
  final String demandeAwaitAssignment, demandeBtnFollow, dossierBtnView;
  final String dossiersEmpty, dossiersEmptyDesc;
  final String statusUrgent, statusInProgress, statusResolved, statusPending, statusRejected, statusApproved;
  final String statusProposition;
  final String specialistAssigned;
  // ── New Dossier ──────────────────────────────────────────────────────────────
  final String newDossierTitle, ndStep1, ndStep2, ndStep3;
  final String ndSelectCategory, ndSelectCategoryDesc;
  final String ndTitleLabel, ndTitleDesc, ndTitleHint;
  final String ndDescLabel, ndDescDesc, ndDescHint;
  final String ndMinChars;
  final String ndRegionLabel, ndRegionDesc;
  final String ndReviewTitle, ndReviewBanner, ndReviewBannerDesc;
  final String ndReviewCategory, ndReviewTitleLabel, ndReviewDesc, ndReviewRegion;
  final String ndAiTitle, ndAiDesc;
  final String ndAnonLabel, ndAnonDesc;
  final String ndPrivacy, ndSuccess, btnSubmit;
  // ── Juristes ─────────────────────────────────────────────────────────────────
  final String juristesTitle, juristesSubtitle, juristesSearch;
  final String juristesCertified, juristesContact;
  final String juristesNoDossierMsg, juristesNoDossierCreate, juristesNoDossierView;
  final String juristesEmpty, juristesEmptyDesc;
  // ── Textes de loi ────────────────────────────────────────────────────────────
  final String loisTitle, loisSubtitle, loisSearch, loisKeywords;
  final String loisExcerpt, loisReadMore, loisReduce;
  final String loisEmpty, loisEmptyDesc, loisEmptyHint;
  // ── Messagerie ───────────────────────────────────────────────────────────────
  final String messagerieTitle, messagerieSubtitle, messagerieEmpty, messagerieEmptyDesc;
  // ── Chat ─────────────────────────────────────────────────────────────────────
  final String chatSecure, chatEncryptionBanner, chatEmpty, chatHint;
  // ── VBG ──────────────────────────────────────────────────────────────────────
  final String vbgModuleLabel, vbgTitle, vbgConfidential;
  final String sosPressInstruction, sosCall, sosAlertRecorded;
  final String vbgNeedHelp, vbgEmergency;
  final String vbgPolice, vbgFirefighters, vbgSamu, btnCall;
  final String vbgRightsLabel, vbgRightsText1, vbgRightsText2, vbgRightsText3;
  final String vbgAllLaws, vbgAnonymity;
  final String vbgReportAnonymous, vbgConsultLawyer, vbgPsySupport, vbgNgoPartners, vbgComingSoon;
  // ── Search ───────────────────────────────────────────────────────────────────
  final String searchHint, searchQuickAccess;
  final String searchLaws, searchFaq, searchLawyers, searchAi, searchFiles;
  final String searchNoResultsHint, searchAskAi;
  // ── AI Agent ─────────────────────────────────────────────────────────────────
  final String aiTitle, aiSubtitle, aiOnline;
  final String aiWelcome, aiSubhead, aiDisclaimer;
  final String aiQuestionsLabel, aiInputHint, aiListening;
  // ── Profil ───────────────────────────────────────────────────────────────────
  final String profilTitle;
  final String profilSectionPersonal, profilSectionPreferences, profilSectionSecurity;
  final String profilFullName, profilEmail, profilPhone, profilPhoneEmpty;
  final String profilRegion, profilRegionEmpty;
  final String profilNotifications, profilLanguage, profilVoiceAssistant, profilVoiceInfo;
  final String profilTwoFactor, profilPrivacy;
  final String profilEnabled, profilDisabled;
  final String profilLogout, profilDeleteAccount, profilVersion;
  final String profilUpdated, twoFaInProgress;
  final String profilEditTitle, profilSave;
  final String logoutTitle, logoutMsg, logoutBtn;
  final String deleteTitle, deleteMsg, deleteBtn;
  // ── Admin ────────────────────────────────────────────────────────────────────
  final String adminTitle, adminBadge, adminOverview, adminActions;
  final String adminUsers, adminFiles, adminInProgress, adminResolved;
  final String adminVbgReports, adminSpecialists;
  final String adminCertify, adminModerate, adminReports;
  final String adminEscalate, adminEscalating, adminAlertsRequired, adminEscalateSuccess;
  // ── Notifications ────────────────────────────────────────────────────────────
  final String notificationsTitle, notificationsMarkAll;
  final String notificationsEmpty, notificationsEmptyDesc;
  // ── Shared ───────────────────────────────────────────────────────────────────
  final String btnRetry, btnCancel, btnOk, btnConsult;
  final String errRequired, errEmail, errPasswordMin, errPasswordMatch;
  final String errCredentials, errGeneric;
  // ── Rapports ─────────────────────────────────────────────────────────────────
  final String rapportsTitle, rapportsAuditLog, rapportsEmpty;
  final String rapportsCsvSuccess, rapportsPdfSuccess;
  // ── Dossier detail ───────────────────────────────────────────────────────────
  final String detailMaDemande, detailMonDossier;
  final String detailInfoTitle, detailCreeLe, detailMisAJour;
  final String detailDescription, detailVoirPlus, detailVoirMoins;
  final String detailPendingTitle, detailPendingDesc;
  final String detailApprovedTitle, detailApprovedDesc;
  final String detailSpecialisteAssigne, detailComptesRendus;
  final String detailNoCr, detailCrLoadError;
  final String detailResolutionTitle, detailResolutionDesc;
  final String detailBtnAccept, detailBtnRefuse;
  final String detailResolutionAccepted, detailResolutionRefused, detailResolutionError;
  final String detailConfirmRefuseTitle, detailConfirmRefuseMsg;
  final String propositionTitle, propositionSubtitle, propositionBtnAccept;
  final String propositionAccepted, propositionRefused, propositionError;
  final String propositionConfirmRefuseTitle, propositionConfirmRefuseMsg;
  final String forgotTitle, forgotSubtitle, forgotEmailHint, forgotBtnSend;
  final String forgotError;
  final String resetTitle, resetCodeLabel, resetResendCode;
  final String resetNewPwdHint, resetConfirmPwdHint;
  final String resetBtnConfirm, resetSuccessTitle, resetSuccessDesc, resetSuccessBackLogin;
  final String resetErrExpired, resetErrInvalidCode, resetErrGeneric;
  final String rdvBookTitle, rdvBookBtn;
  final String rdvConfirmTitle, rdvConfirmBtn;
  final String rdvBookedSuccess, rdvBookedError;
  final String rdvNoSlotsTitle, rdvNoSlotsDesc;
  final String certTitle, certMenuLabel;
  final String certStatutNonSoumisTitle, certStatutNonSoumisDesc;
  final String certStatutEnAttenteTitle, certStatutEnAttenteDesc;
  final String certStatutValideTitle, certStatutValideDesc;
  final String certStatutRejeteTitle, certStatutRejeteDesc;
  final String certLabelNomStructure, certLabelNumeroCarte, certDocsTitle;
  final String certDocCartePro, certDocAgrement, certDocDiplome, certDocCni, certDocPhotoOpt;
  final String certDocPick, certDocReplace, certDocPickHint, certDocOptional, certDocUploaded;
  final String certBtnSubmit, certFooterNote;
  final String certPickError, certUploadError, certFileTooBig, certMissingDocs;
  final String certSubmittedSuccess, certRecapTitle;
  final String certNotSpecialisteTitle, certNotSpecialisteDesc;
  final String homeSpecCasDispoLabel, homeSpecMesDossiersLabel, homeSpecActionsTitle;
  final String homeSpecPlanningLabel, homeSpecPlanningDesc;
  final String homeSpecMessagesLabel, homeSpecMessagesDesc;
  final String homeSpecProfileLabel, homeSpecProfileDesc;
  final String homeSpecCertifCta;
  final String homeOngActivitesLabel, homeOngActivitesActionLabel;
  final String homeOngActivitesActionDesc, homeOngDossiersActionDesc;
  final String casTitle, casSubtitle;
  final String casProposeBtn, casProposeConfirmTitle, casProposeConfirmBtn;
  final String casProposeSuccess, casProposeError;
  final String casEmptyTitle, casEmptyDesc;
  // ── Politique ────────────────────────────────────────────────────────────────
  final String politiqueTitle, politiqueLastUpdateLabel;
  final String politiqueContactTitle, politiqueContactDelay;
  // ── Activités ────────────────────────────────────────────────────────────────
  final String activitesTitle, activitesSubtitle, activitesTab1, activitesTab2;
  final String activitesEmpty, activitesNoInscriptions;
  final String activitesInscrit, activitesComplet;
  final String activitesSInscrire, activitesAnnulerInscription, activitesInscriptionComplete;
  final String activitesParticipants, activitesRapport, activitesPresent, activitesMarquer;
  final String activitesInscriptionConfirmee, activitesInscriptionAnnulee, activitesRapportGenere;
  final String activitesPlaces;
  // ── Dons ─────────────────────────────────────────────────────────────────────
  final String donsTitle, donsSubtitle, donsImpactTitle;
  final String donsChoixMontant, donsMobileMoney, donsNomSection, donsMessageSection;
  final String donsBtnPayer, donsMontantMin, donsMinVal, donsNumInvalide;
  final String donsAutre, donsMontantPersonnalise, donsNomDonateur;
  final String donsAnonymeLabel, donsMsgEncouragement, donsSecurite;
  final String donsConfirmTitle, donsReferenceLabel, donsReferenceCopied;
  final String donsMerci, donsCompris, donsImpossible, donsRedirection;
  final String donsSummaryPrefix, donsSummarySuffix;
  // ── Parentalité ──────────────────────────────────────────────────────────────
  final String parentaliteTitle, parentaliteSubtitle;
  final String parentaliteTab1, parentaliteTab2, parentaliteTab3;
  final String parentaliteEmpty, parentaliteProgressEmpty;
  final String parentaliteLus, parentaliteScoreMoyen;
  final String parentaliteAgentBanner, parentaliteAgentEmpty, parentaliteHint;
  final String parentaliteLu, parentaliteNonLu;
  final String parentaliteDemarrerQuiz, parentaliteQuizTitle;
  final String parentaliteSoumettre, parentaliteRepondreToutes;
  final String parentaliteExcellent, parentaliteBien, parentaliteReviser;
  // ── Planning ─────────────────────────────────────────────────────────────────
  final String planningTitle, planningSubtitle, planningTabAvenir, planningTabPasses;
  final String planningAucunAvenir, planningAucunPasse;
  final String planningRejoindreVisio, planningSessionPrete, planningSessionInfo;
  final String planningCanal, planningCopierToken, planningTokenCopie, planningFermer;
  final String statutConfirme, statutEnAttente, statutAnnule, statutTermine, statutInconnu;
  final String canalVisio, canalChat, canalPresentiel;
  // ── Témoignages ──────────────────────────────────────────────────────────────
  final String temoignagesTitle, temoignagesSubtitle;
  final String temoignagesEmpty, temoignagesEmptyDesc, temoignagesBtnTemoigner;
  final String temoignagesValide, temoignagesVoirMoins, temoignagesLireSuite;
  final String temoignagesPartagerTitle, temoignagesPartagerDesc;
  final String temoignagesHint, temoignagesAnonyme, temoignagesSoumettre;
  final String temoignagesModeration, temoignagesAujourdhui, temoignagesHier;
  final String temoignagesJoursLabel;

  // ── Interpolated helpers ─────────────────────────────────────────────────────
  String ndMinCharsMsg(int n) => ndMinChars.replaceAll('{n}', '$n');
  String loisEmptyQuery(String q) => loisEmptyDesc.replaceAll('{q}', q);
  String searchNoResults(String q) => searchNoResultsHint.replaceAll('{q}', q);
  String juristesNoDossierTitle(String name) => 'Contacter $name';
  String notificationsUnread(int n) => n == 1
      ? (Localizations.localeOf(_ctx!).languageCode == 'en' ? '1 unread' : '1 non lue')
      : (Localizations.localeOf(_ctx!).languageCode == 'en' ? '$n unread' : '$n non lues');
  String rapportsCsvReady(int count) => Localizations.localeOf(_ctx!).languageCode == 'en'
      ? 'CSV export ready — $count files'
      : 'Export CSV prêt — $count dossiers';
  String detailContacter(String role) => Localizations.localeOf(_ctx!).languageCode == 'en'
      ? 'Contact $role'
      : 'Contacter $role';
  String resetSubtitleOtp(String email) => Localizations.localeOf(_ctx!).languageCode == 'en'
      ? 'We sent a 6-digit code to $email. Enter it then choose a new password.'
      : 'Nous avons envoyé un code à 6 chiffres à $email. Saisissez-le puis choisissez un nouveau mot de passe.';
  String rdvConfirmMsg(String nom, String date, String debut, String fin) =>
      Localizations.localeOf(_ctx!).languageCode == 'en'
          ? 'Book with $nom on $date from $debut to $fin?'
          : 'Réserver avec $nom le $date de $debut à $fin ?';
  String rdvBookSubtitle(String nom) => Localizations.localeOf(_ctx!).languageCode == 'en'
      ? 'With $nom'
      : 'Avec $nom';
  String casProposeConfirmMsg(String code) => Localizations.localeOf(_ctx!).languageCode == 'en'
      ? 'Take case $code? The citizen will be notified and can confirm you as their specialist.'
      : 'Prendre le cas $code ? Le citoyen sera notifié et pourra vous confirmer comme son spécialiste.';
  String politiqueLastUpdate(String date) => '$politiqueLastUpdateLabel $date';
  String activitesPlacesRestantes(int n) => n > 1
      ? activitesPlaces.replaceAll('{n}', '$n').replaceAll('{s}', 's')
      : activitesPlaces.replaceAll('{n}', '$n').replaceAll('{s}', '');
  String donsMontantLabel(int n) => Localizations.localeOf(_ctx!).languageCode == 'en'
      ? 'Amount: $n XAF'
      : 'Montant : $n FCFA';
  String donsSummary(int n) => '$donsSummaryPrefix $n FCFA $donsSummarySuffix';
  String temoignagesJours(int n) => temoignagesJoursLabel.replaceAll('{n}', '$n');
  String temoignagesSoutiens(int n) => Localizations.localeOf(_ctx!).languageCode == 'en'
      ? '$n support${n > 1 ? 's' : ''}'
      : '$n soutien${n > 1 ? 's' : ''}';

  static BuildContext? _ctx;

  static AppStrings of(BuildContext context) {
    _ctx = context;
    final code = Localizations.localeOf(context).languageCode;
    return code == 'en' ? _en : _fr;
  }

  // ── FRENCH ───────────────────────────────────────────────────────────────────

  static const _fr = AppStrings._(
    appName: 'Justice Facile',
    splashTagline: 'LA JUSTICE À PORTÉE DE MAIN',
    splashPill1: 'Droits', splashPill2: 'Signalement', splashPill3: 'Accompagnement',
    btnLogin: 'Se connecter', btnRegister: 'Créer un compte',

    ob1Title: 'Votre droit, simplifié',
    ob1Desc: 'Accédez à tous les textes de loi camerounais et comprenez vos droits en quelques secondes.',
    ob2Title: 'Assistance juridique',
    ob2Desc: 'Consultez des juristes et psychologues certifiés pour vous accompagner dans vos démarches.',
    ob3Title: 'Protection VBG',
    ob3Desc: 'Signalez anonymement et en toute sécurité les violences basées sur le genre.',
    btnNext: 'Suivant', btnStart: 'Commencer', btnSkip: 'Passer',

    loginTitle: 'Bon retour', loginSubtitle: 'Connectez-vous à votre espace sécurisé',
    fieldEmail: 'Adresse email', fieldPassword: 'Mot de passe',
    loginForgot: 'Mot de passe oublié ?',
    orSeparator: 'ou', continueGoogle: 'Continuer avec Google',
    loginNoAccount: 'Pas encore de compte ?', btnSignUp: 'S\'inscrire',

    registerTitle: 'Créer un compte', registerSubtitle: 'Rejoignez Justice Facile',
    fieldFirstName: 'Prénom', fieldLastName: 'Nom',
    fieldConfirmPassword: 'Confirmer le mot de passe',
    fieldRole: 'Vous êtes',
    roleCitoyen: 'Citoyen(ne)', roleJuriste: 'Juriste',
    rolePsychologue: 'Psychologue', roleOng: 'ONG / Association',
    termsAccept: 'J\'accepte les conditions d\'utilisation et la politique de confidentialité',
    registerHasAccount: 'Déjà inscrit ? Se connecter',

    verifyEmailTitle: 'Vérifiez votre email',
    verifyEmailDesc: 'Saisissez le code à 6 chiffres envoyé à',
    verifyEmailBtn: 'Valider mon compte',
    codeIncomplete: 'Saisissez les 6 chiffres du code.',
    codeInvalid: 'Code incorrect. Vérifiez et réessayez.',
    codeResent: 'Un nouveau code a été envoyé.',
    codeNotReceived: 'Code non reçu ?',
    resendCode: 'Renvoyer', backToLogin: 'Retour à la connexion',
    goVerifyEmail: 'Vérifier mon adresse email',

    homeGreeting: 'Bonjour,', homeSearch: 'Rechercher une loi, un droit...',
    homeQuickActions: 'Actions rapides', homeRecentDossiers: 'Dossiers récents',
    homeVbgLabel: 'MODULE VBG', homeVbgTitle: 'Besoin d\'aide urgente ?',
    homeVbgDesc: 'Signalement sécurisé et confidentiel, accessible 24h/24.',
    homeVbgBtn: 'Signaler maintenant',
    homeQaDossier: 'Mes\nDossiers', homeQaIa: 'Assistant\nIA',
    homeQaJuriste: 'Trouver\nJuriste', homeQaLois: 'Textes\nde Loi',

    tipSearch: 'Recherchez une loi ou posez une question juridique ici.',
    tipActions: 'Vos raccourcis vers les fonctions essentielles de l\'app.',
    tipVbg: 'Accès direct au module d\'urgence VBG — signalement confidentiel.',
    tipMessages: 'Vos échanges sécurisés avec vos juristes et psychologues.',
    tipGotIt: 'Compris !', tipNext: 'Suivant',

    dossiersTitle: 'Mes Dossiers', dossiersNewBtn: 'Nouvelle demande',
    dossiersSearch: 'Rechercher par titre, numéro, catégorie...',
    filterAll: 'Tous', filterDemandes: 'Demandes',
    filterInProgress: 'En cours', filterUrgent: 'Urgents', filterResolved: 'Résolus',
    demandeAwaitAssignment: 'Un spécialiste vous sera assigné prochainement.',
    demandeBtnFollow: 'Suivre ma demande', dossierBtnView: 'Voir le dossier',
    dossiersEmpty: 'Aucun dossier', dossiersEmptyDesc: 'Soumettez votre première demande d\'assistance juridique.',
    statusUrgent: 'Urgent', statusInProgress: 'En cours',
    statusResolved: 'Résolu', statusPending: 'En attente', statusRejected: 'Rejeté', statusApproved: 'Approuvée',
    statusProposition: 'Spécialiste proposé',
    specialistAssigned: 'Spécialiste assigné',

    newDossierTitle: 'Nouvelle demande',
    ndStep1: 'Catégorie & Titre', ndStep2: 'Description', ndStep3: 'Confirmation',
    ndSelectCategory: 'Sélectionnez une catégorie',
    ndSelectCategoryDesc: 'Choisissez le domaine juridique qui correspond à votre situation.',
    ndTitleLabel: 'Titre de votre demande',
    ndTitleDesc: 'Résumez votre situation en quelques mots.',
    ndTitleHint: 'Ex : Licenciement sans motif valable',
    ndDescLabel: 'Décrivez votre situation',
    ndDescDesc: 'Soyez précis(e) pour que le spécialiste comprenne bien votre cas. Minimum 20 caractères.',
    ndDescHint: 'Décrivez les faits, les dates importantes, les personnes impliquées...',
    ndMinChars: 'Encore {n} caractères minimum',
    ndRegionLabel: 'Votre région',
    ndRegionDesc: 'Optionnel — permet d\'orienter votre dossier vers un spécialiste local.',
    ndReviewTitle: 'Récapitulatif',
    ndReviewBanner: 'Vérifiez votre demande',
    ndReviewBannerDesc: 'Une fois soumise, votre demande sera examinée par un administrateur.',
    ndReviewCategory: 'Catégorie', ndReviewTitleLabel: 'Titre',
    ndReviewDesc: 'Description', ndReviewRegion: 'Région',
    ndAiTitle: 'Prise en charge automatique',
ndAiDesc: 'Notre IA analyse votre situation, détecte l\'urgence et oriente votre dossier vers le bon spécialiste. Vous n\'avez rien d\'autre à faire.',
ndAnonLabel: 'Rester anonyme',
ndAnonDesc: 'Votre identité reste masquée pour les spécialistes — seul l\'administrateur peut vous identifier.',
ndPrivacy: 'Vos informations sont confidentielles et ne seront partagées qu\'avec le spécialiste assigné à votre dossier.',
    ndSuccess: 'Votre demande a été soumise avec succès.',
    btnSubmit: 'Soumettre ma demande',

    juristesTitle: 'Juristes & Experts', juristesSubtitle: 'RÉSEAU DE SPÉCIALISTES',
    juristesSearch: 'Nom, spécialité, ville...',
    juristesCertified: 'Certifié', juristesContact: 'Contacter',
    juristesNoDossierMsg: 'Pour échanger avec ce spécialiste, vous devez d\'abord ouvrir un dossier. Il vous sera assigné automatiquement.',
    juristesNoDossierCreate: 'Créer un dossier', juristesNoDossierView: 'Voir mes dossiers',
    juristesEmpty: 'Aucun spécialiste trouvé', juristesEmptyDesc: 'Modifiez vos filtres de recherche.',

    loisTitle: 'Textes de Loi', loisSubtitle: 'BIBLIOTHÈQUE JURIDIQUE',
    loisSearch: 'Rechercher une loi, un droit...',
    loisKeywords: 'Mots-clés',
    loisExcerpt: 'Extrait du texte', loisReadMore: 'Lire plus', loisReduce: 'Réduire',
    loisEmpty: 'Aucun texte disponible',
    loisEmptyDesc: 'Aucun résultat pour « {q} »',
    loisEmptyHint: 'Essayez un autre mot-clé ou sélectionnez une autre catégorie.',

    messagerieTitle: 'Messages', messagerieSubtitle: 'Conversations sécurisées',
    messagerieEmpty: 'Aucun message pour l\'instant',
    messagerieEmptyDesc: 'Vos échanges avec les spécialistes apparaîtront ici une fois un dossier ouvert.',

    chatSecure: 'Canal sécurisé',
    chatEncryptionBanner: 'Messages chiffrés de bout en bout · Confidentialité garantie',
    chatEmpty: 'Aucun message. Commencez la conversation.',
    chatHint: 'Votre message...',

    vbgModuleLabel: 'MODULE VBG', vbgTitle: 'Protection & Accompagnement',
    vbgConfidential: 'Espace confidentiel · Signalement anonyme disponible',
    sosPressInstruction: 'Appuyez pour appeler la Police nationale',
    sosCall: 'APPELER', sosAlertRecorded: 'Alerte SOS enregistrée',
    vbgNeedHelp: 'Besoin d\'aide ?', vbgEmergency: 'Numéros d\'urgence',
    vbgPolice: 'Police nationale', vbgFirefighters: 'Pompiers', vbgSamu: 'SAMU',
    btnCall: 'Appeler',
    vbgRightsLabel: 'VOS DROITS',
    vbgRightsText1: 'Loi n° 2016/007 du 12 juillet 2016 — Code pénal camerounais (arts. 292–297 : violences conjugales)',
    vbgRightsText2: 'La violence domestique est un crime passible d\'emprisonnement selon le droit camerounais',
    vbgRightsText3: 'Vous pouvez déposer une plainte anonymement via ce module',
    vbgAllLaws: 'Voir tous les textes de loi',
    vbgAnonymity: 'Aucune information personnelle n\'est requise pour signaler. Votre identité reste protégée.',
    vbgReportAnonymous: 'Signalement\nAnonyme',
    vbgConsultLawyer: 'Consulter\nun Juriste',
    vbgPsySupport: 'Soutien\nPsychologique',
    vbgNgoPartners: 'ONG\nPartenaires',
    vbgComingSoon: 'Bientôt',

    searchHint: 'Lois, FAQ, juristes...',
    searchQuickAccess: 'Accès rapide',
    searchLaws: 'Textes de loi', searchFaq: 'FAQ juridique',
    searchLawyers: 'Juristes', searchAi: 'Assistant IA', searchFiles: 'Mes dossiers',
    searchNoResultsHint: 'Aucun résultat pour « {q} »',
    searchAskAi: 'Poser à l\'assistant IA',

    aiTitle: 'Assistant IA', aiSubtitle: 'Conseil juridique intelligent', aiOnline: 'En ligne',
    aiWelcome: 'Bonjour ! Je suis JF·IA',
    aiSubhead: 'Votre assistant juridique intelligent.\nPosez-moi n\'importe quelle question sur vos droits au Cameroun.',
    aiDisclaimer: 'Les réponses sont informatives. Consultez un juriste pour un avis professionnel.',
    aiQuestionsLabel: 'Questions fréquentes',
    aiInputHint: 'Posez votre question juridique...',
    aiListening: 'Écoute en cours… Parlez maintenant',

    profilTitle: 'Mon Profil',
    profilSectionPersonal: 'Informations personnelles',
    profilSectionPreferences: 'Préférences',
    profilSectionSecurity: 'Sécurité & Confidentialité',
    profilFullName: 'Nom complet', profilEmail: 'Email',
    profilPhone: 'Téléphone', profilPhoneEmpty: 'Non renseigné',
    profilRegion: 'Région', profilRegionEmpty: 'Non renseignée',
    profilNotifications: 'Notifications', profilLanguage: 'Langue',
    profilVoiceAssistant: 'Assistant vocal',
    profilVoiceInfo: 'Quand il est activé, l\'assistant vocal lit les réponses de l\'IA à voix haute et vous permet de dicter vos questions en appuyant sur l\'icône microphone dans le chat IA.',
    profilTwoFactor: 'Double authentification',
    profilPrivacy: 'Politique de confidentialité',
    profilEnabled: 'Activé', profilDisabled: 'Désactivé',
    profilLogout: 'Se déconnecter', profilDeleteAccount: 'Supprimer mon compte',
    profilVersion: 'Justice Facile · v1.0.0',
    profilUpdated: 'Profil mis à jour.',
    twoFaInProgress: 'La double authentification est en cours de déploiement.',
    profilEditTitle: 'Modifier le profil', profilSave: 'Enregistrer',
    logoutTitle: 'Se déconnecter',
    logoutMsg: 'Voulez-vous vraiment vous déconnecter de votre compte ?',
    logoutBtn: 'Se déconnecter',
    deleteTitle: 'Supprimer le compte',
    deleteMsg: 'Cette action est irréversible. Toutes vos données seront supprimées définitivement.',
    deleteBtn: 'Supprimer',

    adminTitle: 'Administration', adminBadge: 'ADMIN',
    adminOverview: 'Vue d\'ensemble', adminActions: 'Actions admin',
    adminUsers: 'Utilisateurs', adminFiles: 'Dossiers',
    adminInProgress: 'En cours', adminResolved: 'Résolus',
    adminVbgReports: 'Signalements VBG', adminSpecialists: 'Spécialistes',
    adminCertify: 'Certifier des spécialistes',
    adminModerate: 'Modérer les témoignages',
    adminReports: 'Rapports et exports',
    adminEscalate: 'Exécuter l\'escalade',
    adminEscalating: 'Escalade en cours…',
    adminAlertsRequired: 'Actions requises',
    adminEscalateSuccess: 'Escalade exécutée avec succès',

    notificationsTitle: 'Notifications',
    notificationsMarkAll: 'Tout marquer comme lu',
    notificationsEmpty: 'Aucune notification',
    notificationsEmptyDesc: 'Vos alertes et mises à jour apparaîtront ici.',

    btnRetry: 'Réessayer', btnCancel: 'Annuler', btnOk: 'OK', btnConsult: 'Consulter',
    errRequired: 'Ce champ est obligatoire',
    errEmail: 'Adresse email invalide',
    errPasswordMin: '8 caractères minimum',
    errPasswordMatch: 'Les mots de passe ne correspondent pas',
    errCredentials: 'Email ou mot de passe incorrect',
    errGeneric: 'Une erreur est survenue. Réessayez.',

    rapportsTitle: 'Rapports & Exports', rapportsAuditLog: 'Journal d\'audit',
    rapportsEmpty: 'Journal vide',
    rapportsCsvSuccess: 'Export CSV généré avec succès',
    rapportsPdfSuccess: 'Rapport PDF généré avec succès',

    detailMaDemande: 'Ma demande', detailMonDossier: 'Mon dossier',
    detailInfoTitle: 'Informations', detailCreeLe: 'Créé le', detailMisAJour: 'Mis à jour',
    detailDescription: 'Description', detailVoirPlus: 'Voir plus', detailVoirMoins: 'Voir moins',
    detailPendingTitle: 'En attente d\'assignation',
    detailPendingDesc: 'Un spécialiste va examiner votre demande et vous sera assigné prochainement.',
    detailApprovedTitle: 'Demande approuvée',
    detailApprovedDesc: 'Votre demande a été approuvée. Un spécialiste va confirmer sa prise en charge et votre dossier sera créé prochainement.',
    detailSpecialisteAssigne: 'Spécialiste assigné',
    detailComptesRendus: 'Comptes-rendus',
    detailNoCr: 'Aucun compte-rendu pour l\'instant.',
    detailCrLoadError: 'Impossible de charger les comptes-rendus.',
    detailResolutionTitle: 'Proposition de clôture',
    detailResolutionDesc: 'Votre spécialiste propose de clôturer ce dossier. Confirmez si votre situation est bien résolue.',
    detailBtnAccept: 'Accepter la clôture',
    detailBtnRefuse: 'Refuser',
    detailResolutionAccepted: 'Dossier clôturé avec succès.',
    detailResolutionRefused: 'Proposition refusée. Le dossier reste actif.',
    detailResolutionError: 'Impossible de confirmer pour le moment.',
    detailConfirmRefuseTitle: 'Refuser la clôture ?',
    detailConfirmRefuseMsg: 'Le dossier restera actif et votre spécialiste continuera de vous accompagner.',
    propositionTitle: 'Un spécialiste vous a été proposé',
    propositionSubtitle: 'Confirmez pour créer votre dossier',
    propositionBtnAccept: 'Accepter la proposition',
    propositionAccepted: 'Spécialiste accepté. Votre dossier est créé.',
    propositionRefused: 'Proposition refusée. Un autre spécialiste vous sera proposé.',
    propositionError: 'Impossible de confirmer pour le moment.',
    propositionConfirmRefuseTitle: 'Refuser ce spécialiste ?',
    propositionConfirmRefuseMsg: 'Votre demande retournera en attente et un autre spécialiste pourra se proposer.',
    forgotTitle: 'Mot de passe oublié',
    forgotSubtitle: 'Entrez votre email. Si un compte existe, vous recevrez un code de réinitialisation.',
    forgotEmailHint: 'Adresse email',
    forgotBtnSend: 'Envoyer le code',
    forgotError: 'Impossible d\'envoyer le code pour le moment.',
    resetTitle: 'Nouveau mot de passe',
    resetCodeLabel: 'Code de réinitialisation',
    resetResendCode: 'Renvoyer le code',
    resetNewPwdHint: 'Nouveau mot de passe',
    resetConfirmPwdHint: 'Confirmer le mot de passe',
    resetBtnConfirm: 'Réinitialiser',
    resetSuccessTitle: 'Mot de passe modifié',
    resetSuccessDesc: 'Votre mot de passe a été réinitialisé avec succès. Vous pouvez maintenant vous connecter.',
    resetSuccessBackLogin: 'Se connecter',
    resetErrExpired: 'Ce code a expiré ou trop de tentatives. Refaites une demande depuis l\'écran de connexion.',
    resetErrInvalidCode: 'Code invalide. Vérifiez le code reçu par email.',
    resetErrGeneric: 'Impossible de réinitialiser pour le moment.',
    rdvBookTitle: 'Prendre rendez-vous',
    rdvBookBtn: 'Prendre rendez-vous',
    rdvConfirmTitle: 'Confirmer la réservation',
    rdvConfirmBtn: 'Réserver',
    rdvBookedSuccess: 'Rendez-vous demandé. En attente de validation.',
    rdvBookedError: 'Impossible de réserver ce créneau.',
    rdvNoSlotsTitle: 'Aucun créneau disponible',
    rdvNoSlotsDesc: 'Votre spécialiste n\'a pas encore publié de disponibilités. Revenez plus tard.',
    certTitle: 'Ma certification',
    certMenuLabel: 'Ma certification',
    certStatutNonSoumisTitle: 'Certification à soumettre',
    certStatutNonSoumisDesc: 'Vous devez soumettre vos documents pour être visible dans le répertoire des spécialistes et recevoir des demandes de citoyens.',
    certStatutEnAttenteTitle: 'Certification en cours d\'examen',
    certStatutEnAttenteDesc: 'Nos administrateurs examinent vos documents. Vous serez notifié dès validation.',
    certStatutValideTitle: 'Certification validée',
    certStatutValideDesc: 'Vous êtes désormais visible dans le répertoire et pouvez vous proposer sur des demandes.',
    certStatutRejeteTitle: 'Certification rejetée',
    certStatutRejeteDesc: 'Votre dossier a été refusé. Corrigez les points indiqués ci-dessous puis soumettez à nouveau.',
    certLabelNomStructure: 'Nom de la structure',
    certLabelNumeroCarte: 'Numéro de carte professionnelle',
    certDocsTitle: 'Documents à fournir',
    certDocCartePro: 'Carte professionnelle',
    certDocAgrement: 'Agrément / récépissé',
    certDocDiplome: 'Diplôme',
    certDocCni: 'CNI (recto-verso)',
    certDocPhotoOpt: 'Photo professionnelle (optionnel)',
    certDocPick: 'Choisir',
    certDocReplace: 'Remplacer',
    certDocPickHint: 'PDF, JPG ou PNG — 10 Mo max',
    certDocOptional: 'Facultatif',
    certDocUploaded: 'Envoyé',
    certBtnSubmit: 'Soumettre pour validation',
    certFooterNote: 'Vos documents ne sont visibles que par les administrateurs. Aucun autre utilisateur n\'y a accès.',
    certPickError: 'Impossible d\'ouvrir le sélecteur de fichier.',
    certUploadError: 'Échec de l\'envoi du fichier. Réessayez.',
    certFileTooBig: 'Fichier trop volumineux (10 Mo maximum).',
    certMissingDocs: 'Merci de renseigner tous les champs obligatoires.',
    certSubmittedSuccess: 'Documents soumis. Vous serez notifié après validation.',
    certRecapTitle: 'Dossier soumis',
    certNotSpecialisteTitle: 'Espace réservé aux spécialistes',
    certNotSpecialisteDesc: 'La certification concerne uniquement les juristes, psychologues et ONG. En tant que citoyen, aucune démarche n\'est nécessaire.',
    homeSpecCasDispoLabel: 'Cas disponibles',
    homeSpecMesDossiersLabel: 'Mes dossiers',
    homeSpecActionsTitle: 'Actions rapides',
    homeSpecPlanningLabel: 'Mon planning',
    homeSpecPlanningDesc: 'Gérer mes disponibilités et rendez-vous',
    homeSpecMessagesLabel: 'Messagerie',
    homeSpecMessagesDesc: 'Échanges sécurisés avec les citoyens',
    homeSpecProfileLabel: 'Mon profil',
    homeSpecProfileDesc: 'Informations et paramètres',
    homeSpecCertifCta: 'Soumettre mes documents',
    homeOngActivitesLabel: 'Activités organisées',
    homeOngActivitesActionLabel: 'Mes activités terrain',
    homeOngActivitesActionDesc: 'Créer et gérer les activités de mon ONG',
    homeOngDossiersActionDesc: 'Dossiers VBG assignés à mon ONG',
    casTitle: 'Cas disponibles',
    casSubtitle: 'Demandes en attente d\'un spécialiste',
    casProposeBtn: 'Me proposer sur ce cas',
    casProposeConfirmTitle: 'Prendre ce cas ?',
    casProposeConfirmBtn: 'Confirmer',
    casProposeSuccess: 'Vous êtes proposé sur ce cas. Le citoyen sera notifié.',
    casProposeError: 'Impossible de vous proposer pour le moment.',
    casEmptyTitle: 'Aucun cas disponible',
    casEmptyDesc: 'Il n\'y a pas de nouvelle demande à traiter pour l\'instant. Revenez plus tard.',

    politiqueTitle: 'Politique de confidentialité',
    politiqueLastUpdateLabel: 'Dernière mise à jour :',
    politiqueContactTitle: 'Questions sur vos données ?',
    politiqueContactDelay: 'Délai de réponse : 30 jours maximum.',

    activitesTitle: 'Activités ONG', activitesSubtitle: 'Terrain & Accompagnement',
    activitesTab1: 'Activités', activitesTab2: 'Mes inscriptions',
    activitesEmpty: 'Aucune activité disponible',
    activitesNoInscriptions: 'Vous n\'êtes inscrit à aucune activité',
    activitesInscrit: 'Inscrit', activitesComplet: 'Complet',
    activitesSInscrire: 'S\'inscrire',
    activitesAnnulerInscription: 'Annuler mon inscription',
    activitesInscriptionComplete: 'Activité complète',
    activitesParticipants: 'Participants', activitesRapport: 'Rapport',
    activitesPresent: 'Présent', activitesMarquer: 'Marquer',
    activitesInscriptionConfirmee: 'Inscription confirmée !',
    activitesInscriptionAnnulee: 'Inscription annulée',
    activitesRapportGenere: 'Rapport généré avec succès',
    activitesPlaces: '{n} place{s} restante{s}',

    donsTitle: 'Faire un don', donsSubtitle: 'Soutenez les victimes de VBG',
    donsImpactTitle: 'Chaque franc compte',
    donsChoixMontant: 'Choisissez un montant (FCFA)',
    donsMobileMoney: 'Votre numéro Mobile Money',
    donsNomSection: 'Votre nom (optionnel)',
    donsMessageSection: 'Message (optionnel)',
    donsBtnPayer: 'Faire un don via NotchPay',
    donsMontantMin: 'Montant minimum : 100 FCFA', donsMinVal: 'Minimum 100 FCFA',
    donsNumInvalide: 'Numéro invalide (9 chiffres minimum)',
    donsAutre: 'Autre', donsMontantPersonnalise: 'Montant personnalisé',
    donsNomDonateur: 'Nom du donateur',
    donsAnonymeLabel: 'Anonyme si vide',
    donsMsgEncouragement: 'Un mot d\'encouragement…',
    donsSecurite: 'Paiement sécurisé · NotchPay · 100% de votre don soutient les victimes',
    donsConfirmTitle: 'Don initié', donsReferenceLabel: 'Référence :',
    donsReferenceCopied: 'Référence copiée',
    donsMerci: 'Votre paiement mobile money sera traité. Merci pour votre soutien !',
    donsCompris: 'Compris',
    donsImpossible: 'Impossible d\'ouvrir la page de paiement',
    donsRedirection: 'Redirection vers NotchPay…',
    donsSummaryPrefix: 'Vous allez donner', donsSummarySuffix: 'via Mobile Money. Merci !',

    parentaliteTitle: 'Parentalité Positive', parentaliteSubtitle: 'Guides · Quiz · Assistant',
    parentaliteTab1: 'Contenus', parentaliteTab2: 'Mon parcours', parentaliteTab3: 'Assistant IA',
    parentaliteEmpty: 'Aucun contenu disponible',
    parentaliteProgressEmpty: 'Commencez à lire pour voir votre parcours',
    parentaliteLus: 'Lus', parentaliteScoreMoyen: 'Score moyen',
    parentaliteAgentBanner: 'Agent spécialisé en parentalité positive — Posez vos questions',
    parentaliteAgentEmpty: 'Posez une question sur la parentalité',
    parentaliteHint: 'Question sur la parentalité…',
    parentaliteLu: 'Lu', parentaliteNonLu: 'Non lu',
    parentaliteDemarrerQuiz: 'Démarrer le quiz', parentaliteQuizTitle: 'Quiz',
    parentaliteSoumettre: 'Soumettre mes réponses',
    parentaliteRepondreToutes: 'Répondez à toutes les questions',
    parentaliteExcellent: 'Excellent !', parentaliteBien: 'Bien, continuez !',
    parentaliteReviser: 'Révisez ce contenu',

    planningTitle: 'Mes Rendez-vous', planningSubtitle: 'Planning personnel',
    planningTabAvenir: 'À venir', planningTabPasses: 'Passés',
    planningAucunAvenir: 'Aucun rendez-vous à venir',
    planningAucunPasse: 'Aucun rendez-vous passé',
    planningRejoindreVisio: 'Rejoindre la visio',
    planningSessionPrete: 'Session visio prête',
    planningSessionInfo: 'Utilisez ces informations pour rejoindre la session Agora :',
    planningCanal: 'Canal',
    planningCopierToken: 'Copier le token',
    planningTokenCopie: 'Token copié dans le presse-papier',
    planningFermer: 'Fermer',
    statutConfirme: 'Confirmé', statutEnAttente: 'En attente',
    statutAnnule: 'Annulé', statutTermine: 'Terminé', statutInconnu: 'Inconnu',
    canalVisio: 'Visioconférence', canalChat: 'Chat', canalPresentiel: 'Présentiel',

    temoignagesTitle: 'Témoignages', temoignagesSubtitle: 'Paroles de survivant·e·s',
    temoignagesEmpty: 'Aucun témoignage pour l\'instant',
    temoignagesEmptyDesc: 'Soyez le premier à partager votre expérience et aider d\'autres personnes.',
    temoignagesBtnTemoigner: 'Témoigner', temoignagesValide: 'Validé',
    temoignagesVoirMoins: 'Voir moins', temoignagesLireSuite: 'Lire la suite',
    temoignagesPartagerTitle: 'Partager votre témoignage',
    temoignagesPartagerDesc: 'Votre parole peut aider d\'autres personnes. Chaque témoignage est relu avant publication.',
    temoignagesHint: 'Racontez votre histoire en toute sécurité…',
    temoignagesAnonyme: 'Publier anonymement (recommandé)',
    temoignagesSoumettre: 'Soumettre le témoignage',
    temoignagesModeration: 'Témoignage soumis. Il sera visible après modération.',
    temoignagesAujourdhui: 'Aujourd\'hui', temoignagesHier: 'Hier',
    temoignagesJoursLabel: 'Il y a {n} j',
  );

  // ── ENGLISH ──────────────────────────────────────────────────────────────────

  static const _en = AppStrings._(
    appName: 'Justice Facile',
    splashTagline: 'JUSTICE AT YOUR FINGERTIPS',
    splashPill1: 'Rights', splashPill2: 'Report', splashPill3: 'Support',
    btnLogin: 'Sign in', btnRegister: 'Create an account',

    ob1Title: 'Your rights, simplified',
    ob1Desc: 'Access all Cameroonian laws and understand your rights in seconds.',
    ob2Title: 'Legal assistance',
    ob2Desc: 'Consult certified lawyers and psychologists to guide you through your procedures.',
    ob3Title: 'GBV Protection',
    ob3Desc: 'Anonymously and safely report gender-based violence.',
    btnNext: 'Next', btnStart: 'Get started', btnSkip: 'Skip',

    loginTitle: 'Welcome back', loginSubtitle: 'Sign in to your secure space',
    fieldEmail: 'Email address', fieldPassword: 'Password',
    loginForgot: 'Forgot password?',
    orSeparator: 'or', continueGoogle: 'Continue with Google',
    loginNoAccount: 'No account yet?', btnSignUp: 'Sign up',

    registerTitle: 'Create an account', registerSubtitle: 'Join Justice Facile',
    fieldFirstName: 'First name', fieldLastName: 'Last name',
    fieldConfirmPassword: 'Confirm password',
    fieldRole: 'You are',
    roleCitoyen: 'Citizen', roleJuriste: 'Lawyer',
    rolePsychologue: 'Psychologist', roleOng: 'NGO / Association',
    termsAccept: 'I accept the terms of use and privacy policy',
    registerHasAccount: 'Already registered? Sign in',

    verifyEmailTitle: 'Verify your email',
    verifyEmailDesc: 'Enter the 6-digit code sent to',
    verifyEmailBtn: 'Verify my account',
    codeIncomplete: 'Enter all 6 digits of the code.',
    codeInvalid: 'Invalid code. Please check and try again.',
    codeResent: 'A new code has been sent.',
    codeNotReceived: 'Did not receive the code?',
    resendCode: 'Resend', backToLogin: 'Back to login',
    goVerifyEmail: 'Verify my email address',

    homeGreeting: 'Hello,', homeSearch: 'Search a law, a right...',
    homeQuickActions: 'Quick actions', homeRecentDossiers: 'Recent files',
    homeVbgLabel: 'GBV MODULE', homeVbgTitle: 'Need urgent help?',
    homeVbgDesc: 'Safe and confidential reporting, available 24/7.',
    homeVbgBtn: 'Report now',
    homeQaDossier: 'My\nFiles', homeQaIa: 'AI\nAssistant',
    homeQaJuriste: 'Find\nLawyer', homeQaLois: 'Legal\nTexts',

    tipSearch: 'Search a law or ask a legal question here.',
    tipActions: 'Your shortcuts to the essential app features.',
    tipVbg: 'Direct access to the GBV emergency module — confidential reporting.',
    tipMessages: 'Your secure exchanges with lawyers and psychologists.',
    tipGotIt: 'Got it!', tipNext: 'Next',

    dossiersTitle: 'My Files', dossiersNewBtn: 'New request',
    dossiersSearch: 'Search by title, number, category...',
    filterAll: 'All', filterDemandes: 'Requests',
    filterInProgress: 'In progress', filterUrgent: 'Urgent', filterResolved: 'Resolved',
    demandeAwaitAssignment: 'A specialist will be assigned to you soon.',
    demandeBtnFollow: 'Track my request', dossierBtnView: 'View file',
    dossiersEmpty: 'No files', dossiersEmptyDesc: 'Submit your first legal assistance request.',
    statusUrgent: 'Urgent', statusInProgress: 'In progress',
    statusResolved: 'Resolved', statusPending: 'Pending', statusRejected: 'Rejected', statusApproved: 'Approved',
    statusProposition: 'Specialist proposed',
    specialistAssigned: 'Specialist assigned',

    newDossierTitle: 'New request',
    ndStep1: 'Category & Title', ndStep2: 'Description', ndStep3: 'Confirmation',
    ndSelectCategory: 'Select a category',
    ndSelectCategoryDesc: 'Choose the legal field that matches your situation.',
    ndTitleLabel: 'Title of your request',
    ndTitleDesc: 'Summarize your situation in a few words.',
    ndTitleHint: 'E.g.: Unfair dismissal without valid grounds',
    ndDescLabel: 'Describe your situation',
    ndDescDesc: 'Be specific so the specialist understands your case. Minimum 20 characters.',
    ndDescHint: 'Describe the facts, key dates, people involved...',
    ndMinChars: '{n} more characters required',
    ndRegionLabel: 'Your region',
    ndRegionDesc: 'Optional — helps direct your file to a local specialist.',
    ndReviewTitle: 'Summary',
    ndReviewBanner: 'Verify your request',
    ndReviewBannerDesc: 'Once submitted, your request will be reviewed by an administrator.',
    ndReviewCategory: 'Category', ndReviewTitleLabel: 'Title',
    ndReviewDesc: 'Description', ndReviewRegion: 'Region',
    ndAiTitle: 'Automatic handling',
ndAiDesc: 'Our AI analyses your situation, detects urgency and routes your case to the right specialist. You don\'t need to do anything else.',
ndAnonLabel: 'Stay anonymous',
ndAnonDesc: 'Your identity remains hidden from specialists — only the administrator can identify you.',
ndPrivacy: 'Your information is confidential and will only be shared with the specialist assigned to your file.',
    ndSuccess: 'Your request has been submitted successfully.',
    btnSubmit: 'Submit my request',

    juristesTitle: 'Lawyers & Experts', juristesSubtitle: 'SPECIALIST NETWORK',
    juristesSearch: 'Name, specialty, city...',
    juristesCertified: 'Certified', juristesContact: 'Contact',
    juristesNoDossierMsg: 'To communicate with this specialist, you must first open a file. They will be assigned to you automatically.',
    juristesNoDossierCreate: 'Create a file', juristesNoDossierView: 'View my files',
    juristesEmpty: 'No specialists found', juristesEmptyDesc: 'Modify your search filters.',

    loisTitle: 'Legal Texts', loisSubtitle: 'LEGAL LIBRARY',
    loisSearch: 'Search for a law, a right...',
    loisKeywords: 'Keywords',
    loisExcerpt: 'Text excerpt', loisReadMore: 'Read more', loisReduce: 'Reduce',
    loisEmpty: 'No texts available',
    loisEmptyDesc: 'No results for « {q} »',
    loisEmptyHint: 'Try another keyword or select another category.',

    messagerieTitle: 'Messages', messagerieSubtitle: 'Secure conversations',
    messagerieEmpty: 'No messages yet',
    messagerieEmptyDesc: 'Your conversations with specialists will appear here once a file is opened.',

    chatSecure: 'Secure channel',
    chatEncryptionBanner: 'End-to-end encrypted messages · Privacy guaranteed',
    chatEmpty: 'No messages. Start the conversation.',
    chatHint: 'Your message...',

    vbgModuleLabel: 'GBV MODULE', vbgTitle: 'Protection & Support',
    vbgConfidential: 'Confidential space · Anonymous reporting available',
    sosPressInstruction: 'Press to call National Police',
    sosCall: 'CALL', sosAlertRecorded: 'SOS Alert recorded',
    vbgNeedHelp: 'Need help?', vbgEmergency: 'Emergency numbers',
    vbgPolice: 'National Police', vbgFirefighters: 'Firefighters', vbgSamu: 'Ambulance',
    btnCall: 'Call',
    vbgRightsLabel: 'YOUR RIGHTS',
    vbgRightsText1: 'Law No. 2016/007 of July 12, 2016 — Cameroonian Criminal Code (arts. 292–297: domestic violence)',
    vbgRightsText2: 'Domestic violence is a crime punishable by imprisonment under Cameroonian law',
    vbgRightsText3: 'You can file a complaint anonymously via this module',
    vbgAllLaws: 'View all legal texts',
    vbgAnonymity: 'No personal information is required to report. Your identity remains protected.',
    vbgReportAnonymous: 'Anonymous\nReport',
    vbgConsultLawyer: 'Consult a\nLawyer',
    vbgPsySupport: 'Psychological\nSupport',
    vbgNgoPartners: 'Partner\nNGOs',
    vbgComingSoon: 'Coming soon',

    searchHint: 'Laws, FAQ, lawyers...',
    searchQuickAccess: 'Quick access',
    searchLaws: 'Legal texts', searchFaq: 'Legal FAQ',
    searchLawyers: 'Lawyers', searchAi: 'AI Assistant', searchFiles: 'My files',
    searchNoResultsHint: 'No results for « {q} »',
    searchAskAi: 'Ask the AI assistant',

    aiTitle: 'AI Assistant', aiSubtitle: 'Intelligent legal advice', aiOnline: 'Online',
    aiWelcome: 'Hello! I\'m JF·AI',
    aiSubhead: 'Your intelligent legal assistant.\nAsk me anything about your rights in Cameroon.',
    aiDisclaimer: 'Answers are informational. Consult a lawyer for professional advice.',
    aiQuestionsLabel: 'Frequently asked questions',
    aiInputHint: 'Ask your legal question...',
    aiListening: 'Listening… Speak now',

    profilTitle: 'My Profile',
    profilSectionPersonal: 'Personal information',
    profilSectionPreferences: 'Preferences',
    profilSectionSecurity: 'Security & Privacy',
    profilFullName: 'Full name', profilEmail: 'Email',
    profilPhone: 'Phone', profilPhoneEmpty: 'Not provided',
    profilRegion: 'Region', profilRegionEmpty: 'Not specified',
    profilNotifications: 'Notifications', profilLanguage: 'Language',
    profilVoiceAssistant: 'Voice assistant',
    profilVoiceInfo: 'When enabled, the voice assistant reads AI responses aloud and lets you dictate your questions by tapping the microphone icon in the AI chat.',
    profilTwoFactor: 'Two-factor authentication',
    profilPrivacy: 'Privacy policy',
    profilEnabled: 'Enabled', profilDisabled: 'Disabled',
    profilLogout: 'Sign out', profilDeleteAccount: 'Delete my account',
    profilVersion: 'Justice Facile · v1.0.0',
    profilUpdated: 'Profile updated.',
    twoFaInProgress: 'Two-factor authentication is being deployed.',
    profilEditTitle: 'Edit profile', profilSave: 'Save',
    logoutTitle: 'Sign out',
    logoutMsg: 'Are you sure you want to sign out of your account?',
    logoutBtn: 'Sign out',
    deleteTitle: 'Delete account',
    deleteMsg: 'This action is irreversible. All your data will be permanently deleted.',
    deleteBtn: 'Delete',

    adminTitle: 'Administration', adminBadge: 'ADMIN',
    adminOverview: 'Overview', adminActions: 'Admin actions',
    adminUsers: 'Users', adminFiles: 'Files',
    adminInProgress: 'In progress', adminResolved: 'Resolved',
    adminVbgReports: 'GBV Reports', adminSpecialists: 'Specialists',
    adminCertify: 'Certify specialists',
    adminModerate: 'Moderate testimonies',
    adminReports: 'Reports & exports',
    adminEscalate: 'Run escalation',
    adminEscalating: 'Escalation in progress…',
    adminAlertsRequired: 'Required actions',
    adminEscalateSuccess: 'Escalation executed successfully',

    notificationsTitle: 'Notifications',
    notificationsMarkAll: 'Mark all as read',
    notificationsEmpty: 'No notifications',
    notificationsEmptyDesc: 'Your alerts and updates will appear here.',

    btnRetry: 'Retry', btnCancel: 'Cancel', btnOk: 'OK', btnConsult: 'View',
    errRequired: 'This field is required',
    errEmail: 'Invalid email address',
    errPasswordMin: 'Minimum 8 characters',
    errPasswordMatch: 'Passwords do not match',
    errCredentials: 'Incorrect email or password',
    errGeneric: 'An error occurred. Please try again.',

    rapportsTitle: 'Reports & Exports', rapportsAuditLog: 'Audit log',
    rapportsEmpty: 'Empty log',
    rapportsCsvSuccess: 'CSV export generated successfully',
    rapportsPdfSuccess: 'PDF report generated successfully',

    detailMaDemande: 'My request', detailMonDossier: 'My file',
    detailInfoTitle: 'Information', detailCreeLe: 'Created on', detailMisAJour: 'Updated',
    detailDescription: 'Description', detailVoirPlus: 'See more', detailVoirMoins: 'See less',
    detailPendingTitle: 'Awaiting assignment',
    detailPendingDesc: 'A specialist will review your request and will be assigned to you shortly.',
    detailApprovedTitle: 'Request approved',
    detailApprovedDesc: 'Your request has been approved. A specialist will confirm their assignment and your file will be created shortly.',
    detailSpecialisteAssigne: 'Assigned specialist',
    detailComptesRendus: 'Reports',
    detailNoCr: 'No reports yet.',
    detailCrLoadError: 'Unable to load reports.',
    detailResolutionTitle: 'Closure proposal',
    detailResolutionDesc: 'Your specialist proposes to close this file. Please confirm if your situation is truly resolved.',
    detailBtnAccept: 'Accept closure',
    detailBtnRefuse: 'Refuse',
    detailResolutionAccepted: 'File closed successfully.',
    detailResolutionRefused: 'Proposal refused. The file remains active.',
    detailResolutionError: 'Unable to confirm at the moment.',
    detailConfirmRefuseTitle: 'Refuse the closure?',
    detailConfirmRefuseMsg: 'The file will stay active and your specialist will continue to support you.',
    propositionTitle: 'A specialist has been proposed',
    propositionSubtitle: 'Confirm to create your file',
    propositionBtnAccept: 'Accept proposal',
    propositionAccepted: 'Specialist accepted. Your file has been created.',
    propositionRefused: 'Proposal refused. Another specialist may propose themselves.',
    propositionError: 'Unable to confirm at the moment.',
    propositionConfirmRefuseTitle: 'Refuse this specialist?',
    propositionConfirmRefuseMsg: 'Your request will go back to pending and another specialist may propose themselves.',
    forgotTitle: 'Forgot password',
    forgotSubtitle: 'Enter your email. If an account exists, we will send you a reset code.',
    forgotEmailHint: 'Email address',
    forgotBtnSend: 'Send code',
    forgotError: 'Unable to send the code at the moment.',
    resetTitle: 'New password',
    resetCodeLabel: 'Reset code',
    resetResendCode: 'Resend code',
    resetNewPwdHint: 'New password',
    resetConfirmPwdHint: 'Confirm password',
    resetBtnConfirm: 'Reset',
    resetSuccessTitle: 'Password updated',
    resetSuccessDesc: 'Your password has been reset successfully. You can now sign in.',
    resetSuccessBackLogin: 'Sign in',
    resetErrExpired: 'This code expired or too many attempts. Request a new one from the sign-in screen.',
    resetErrInvalidCode: 'Invalid code. Check the code you received by email.',
    resetErrGeneric: 'Unable to reset at the moment.',
    rdvBookTitle: 'Book appointment',
    rdvBookBtn: 'Book appointment',
    rdvConfirmTitle: 'Confirm booking',
    rdvConfirmBtn: 'Book',
    rdvBookedSuccess: 'Appointment requested. Awaiting validation.',
    rdvBookedError: 'Unable to book this slot.',
    rdvNoSlotsTitle: 'No slots available',
    rdvNoSlotsDesc: 'Your specialist has not yet published any availabilities. Please try again later.',
    certTitle: 'My certification',
    certMenuLabel: 'My certification',
    certStatutNonSoumisTitle: 'Certification to submit',
    certStatutNonSoumisDesc: 'You must submit your documents to appear in the specialists directory and receive citizen requests.',
    certStatutEnAttenteTitle: 'Certification under review',
    certStatutEnAttenteDesc: 'Our administrators are reviewing your documents. You will be notified once validated.',
    certStatutValideTitle: 'Certification approved',
    certStatutValideDesc: 'You are now listed in the directory and can propose yourself on requests.',
    certStatutRejeteTitle: 'Certification rejected',
    certStatutRejeteDesc: 'Your file was rejected. Fix the points listed below then submit again.',
    certLabelNomStructure: 'Structure name',
    certLabelNumeroCarte: 'Professional card number',
    certDocsTitle: 'Required documents',
    certDocCartePro: 'Professional card',
    certDocAgrement: 'Approval / receipt',
    certDocDiplome: 'Diploma',
    certDocCni: 'ID card (both sides)',
    certDocPhotoOpt: 'Professional photo (optional)',
    certDocPick: 'Choose',
    certDocReplace: 'Replace',
    certDocPickHint: 'PDF, JPG or PNG — 10 MB max',
    certDocOptional: 'Optional',
    certDocUploaded: 'Uploaded',
    certBtnSubmit: 'Submit for validation',
    certFooterNote: 'Your documents are only visible to administrators. No other user has access to them.',
    certPickError: 'Unable to open the file picker.',
    certUploadError: 'File upload failed. Please try again.',
    certFileTooBig: 'File too large (10 MB maximum).',
    certMissingDocs: 'Please fill in all required fields.',
    certSubmittedSuccess: 'Documents submitted. You will be notified once validated.',
    certRecapTitle: 'Submitted file',
    certNotSpecialisteTitle: 'Reserved for specialists',
    certNotSpecialisteDesc: 'Certification is only for lawyers, psychologists and NGOs. As a citizen, no action is required.',
    homeSpecCasDispoLabel: 'Available cases',
    homeSpecMesDossiersLabel: 'My files',
    homeSpecActionsTitle: 'Quick actions',
    homeSpecPlanningLabel: 'My schedule',
    homeSpecPlanningDesc: 'Manage my availability and appointments',
    homeSpecMessagesLabel: 'Messages',
    homeSpecMessagesDesc: 'Secure exchanges with citizens',
    homeSpecProfileLabel: 'My profile',
    homeSpecProfileDesc: 'Information and settings',
    homeSpecCertifCta: 'Submit my documents',
    homeOngActivitesLabel: 'Organized activities',
    homeOngActivitesActionLabel: 'My field activities',
    homeOngActivitesActionDesc: 'Create and manage my NGO activities',
    homeOngDossiersActionDesc: 'GBV files assigned to my NGO',
    casTitle: 'Available cases',
    casSubtitle: 'Requests awaiting a specialist',
    casProposeBtn: 'Take this case',
    casProposeConfirmTitle: 'Take this case?',
    casProposeConfirmBtn: 'Confirm',
    casProposeSuccess: 'You have been proposed on this case. The citizen will be notified.',
    casProposeError: 'Unable to propose you at the moment.',
    casEmptyTitle: 'No cases available',
    casEmptyDesc: 'There are no new requests to handle at the moment. Please check back later.',

    politiqueTitle: 'Privacy Policy',
    politiqueLastUpdateLabel: 'Last updated:',
    politiqueContactTitle: 'Questions about your data?',
    politiqueContactDelay: 'Response time: 30 days maximum.',

    activitesTitle: 'NGO Activities', activitesSubtitle: 'Field & Support',
    activitesTab1: 'Activities', activitesTab2: 'My registrations',
    activitesEmpty: 'No activities available',
    activitesNoInscriptions: 'You are not registered for any activity',
    activitesInscrit: 'Registered', activitesComplet: 'Full',
    activitesSInscrire: 'Register',
    activitesAnnulerInscription: 'Cancel my registration',
    activitesInscriptionComplete: 'Activity full',
    activitesParticipants: 'Participants', activitesRapport: 'Report',
    activitesPresent: 'Present', activitesMarquer: 'Mark',
    activitesInscriptionConfirmee: 'Registration confirmed!',
    activitesInscriptionAnnulee: 'Registration cancelled',
    activitesRapportGenere: 'Report generated successfully',
    activitesPlaces: '{n} spot{s} left',

    donsTitle: 'Make a donation', donsSubtitle: 'Support GBV victims',
    donsImpactTitle: 'Every franc counts',
    donsChoixMontant: 'Choose an amount (XAF)',
    donsMobileMoney: 'Your Mobile Money number',
    donsNomSection: 'Your name (optional)',
    donsMessageSection: 'Message (optional)',
    donsBtnPayer: 'Donate via NotchPay',
    donsMontantMin: 'Minimum amount: 100 XAF', donsMinVal: 'Minimum 100 XAF',
    donsNumInvalide: 'Invalid number (minimum 9 digits)',
    donsAutre: 'Other', donsMontantPersonnalise: 'Custom amount',
    donsNomDonateur: 'Donor name',
    donsAnonymeLabel: 'Anonymous if empty',
    donsMsgEncouragement: 'A word of encouragement…',
    donsSecurite: 'Secure payment · NotchPay · 100% of your donation supports victims',
    donsConfirmTitle: 'Donation initiated', donsReferenceLabel: 'Reference:',
    donsReferenceCopied: 'Reference copied',
    donsMerci: 'Your mobile money payment will be processed. Thank you for your support!',
    donsCompris: 'Got it',
    donsImpossible: 'Unable to open the payment page',
    donsRedirection: 'Redirecting to NotchPay…',
    donsSummaryPrefix: 'You are about to donate', donsSummarySuffix: 'via Mobile Money. Thank you!',

    parentaliteTitle: 'Positive Parenting', parentaliteSubtitle: 'Guides · Quiz · Assistant',
    parentaliteTab1: 'Content', parentaliteTab2: 'My progress', parentaliteTab3: 'AI Assistant',
    parentaliteEmpty: 'No content available',
    parentaliteProgressEmpty: 'Start reading to see your progress',
    parentaliteLus: 'Read', parentaliteScoreMoyen: 'Average score',
    parentaliteAgentBanner: 'Specialist agent in positive parenting — Ask your questions',
    parentaliteAgentEmpty: 'Ask a question about parenting',
    parentaliteHint: 'Question about parenting…',
    parentaliteLu: 'Read', parentaliteNonLu: 'Unread',
    parentaliteDemarrerQuiz: 'Start quiz', parentaliteQuizTitle: 'Quiz',
    parentaliteSoumettre: 'Submit my answers',
    parentaliteRepondreToutes: 'Answer all questions',
    parentaliteExcellent: 'Excellent!', parentaliteBien: 'Good, keep going!',
    parentaliteReviser: 'Review this content',

    planningTitle: 'My Appointments', planningSubtitle: 'Personal schedule',
    planningTabAvenir: 'Upcoming', planningTabPasses: 'Past',
    planningAucunAvenir: 'No upcoming appointments',
    planningAucunPasse: 'No past appointments',
    planningRejoindreVisio: 'Join video call',
    planningSessionPrete: 'Video session ready',
    planningSessionInfo: 'Use these details to join the Agora session:',
    planningCanal: 'Channel',
    planningCopierToken: 'Copy token',
    planningTokenCopie: 'Token copied to clipboard',
    planningFermer: 'Close',
    statutConfirme: 'Confirmed', statutEnAttente: 'Pending',
    statutAnnule: 'Cancelled', statutTermine: 'Completed', statutInconnu: 'Unknown',
    canalVisio: 'Video call', canalChat: 'Chat', canalPresentiel: 'In person',

    temoignagesTitle: 'Testimonials', temoignagesSubtitle: 'Words from survivors',
    temoignagesEmpty: 'No testimonials yet',
    temoignagesEmptyDesc: 'Be the first to share your experience and help others.',
    temoignagesBtnTemoigner: 'Share', temoignagesValide: 'Validated',
    temoignagesVoirMoins: 'See less', temoignagesLireSuite: 'Read more',
    temoignagesPartagerTitle: 'Share your testimonial',
    temoignagesPartagerDesc: 'Your story can help others. Each testimonial is reviewed before publication.',
    temoignagesHint: 'Tell your story safely…',
    temoignagesAnonyme: 'Publish anonymously (recommended)',
    temoignagesSoumettre: 'Submit testimonial',
    temoignagesModeration: 'Testimonial submitted. It will be visible after moderation.',
    temoignagesAujourdhui: 'Today', temoignagesHier: 'Yesterday',
    temoignagesJoursLabel: '{n} days ago',
  );
}
