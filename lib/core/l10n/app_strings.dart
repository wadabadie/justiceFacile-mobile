import 'package:flutter/material.dart';

class AppStrings {
  const AppStrings._({
    required this.appName,
    required this.splashTagline,
    required this.splashPill1,
    required this.splashPill2,
    required this.splashPill3,
    required this.btnLogin,
    required this.btnRegister,
    required this.ob1Title, required this.ob1Desc,
    required this.ob2Title, required this.ob2Desc,
    required this.ob3Title, required this.ob3Desc,
    required this.btnNext,
    required this.btnStart,
    required this.btnSkip,
    required this.loginTitle,
    required this.loginSubtitle,
    required this.fieldEmail,
    required this.fieldPassword,
    required this.loginForgot,
    required this.orSeparator,
    required this.continueGoogle,
    required this.loginNoAccount,
    required this.btnSignUp,
    required this.registerTitle,
    required this.registerSubtitle,
    required this.fieldFirstName,
    required this.fieldLastName,
    required this.fieldConfirmPassword,
    required this.fieldRole,
    required this.roleCitoyen,
    required this.roleJuriste,
    required this.rolePsychologue,
    required this.roleOng,
    required this.termsAccept,
    required this.registerHasAccount,
    required this.homeGreeting,
    required this.homeSearch,
    required this.homeQuickActions,
    required this.homeRecentDossiers,
    required this.homeVbgLabel,
    required this.homeVbgTitle,
    required this.homeVbgDesc,
    required this.homeVbgBtn,
    required this.homeQaDossier,
    required this.homeQaIa,
    required this.homeQaJuriste,
    required this.homeQaLois,
    required this.tipSearch,
    required this.tipActions,
    required this.tipVbg,
    required this.tipMessages,
    required this.tipGotIt,
    required this.tipNext,
    required this.errRequired,
    required this.errEmail,
    required this.errPasswordMin,
    required this.errPasswordMatch,
    required this.errCredentials,
    required this.errGeneric,
  });

  final String appName;
  final String splashTagline;
  final String splashPill1, splashPill2, splashPill3;
  final String btnLogin, btnRegister;
  final String ob1Title, ob1Desc, ob2Title, ob2Desc, ob3Title, ob3Desc;
  final String btnNext, btnStart, btnSkip;
  final String loginTitle, loginSubtitle;
  final String fieldEmail, fieldPassword;
  final String loginForgot, orSeparator, continueGoogle;
  final String loginNoAccount, btnSignUp;
  final String registerTitle, registerSubtitle;
  final String fieldFirstName, fieldLastName, fieldConfirmPassword, fieldRole;
  final String roleCitoyen, roleJuriste, rolePsychologue, roleOng;
  final String termsAccept, registerHasAccount;
  final String homeGreeting, homeSearch;
  final String homeQuickActions, homeRecentDossiers;
  final String homeVbgLabel, homeVbgTitle, homeVbgDesc, homeVbgBtn;
  final String homeQaDossier, homeQaIa, homeQaJuriste, homeQaLois;
  final String tipSearch, tipActions, tipVbg, tipMessages, tipGotIt, tipNext;
  final String errRequired, errEmail, errPasswordMin, errPasswordMatch, errCredentials, errGeneric;

  static AppStrings of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return code == 'en' ? _en : _fr;
  }

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
    errRequired: 'Ce champ est obligatoire',
    errEmail: 'Adresse email invalide',
    errPasswordMin: '8 caractères minimum',
    errPasswordMatch: 'Les mots de passe ne correspondent pas',
    errCredentials: 'Email ou mot de passe incorrect',
    errGeneric: 'Une erreur est survenue. Réessayez.',
  );

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
    errRequired: 'This field is required',
    errEmail: 'Invalid email address',
    errPasswordMin: 'Minimum 8 characters',
    errPasswordMatch: 'Passwords do not match',
    errCredentials: 'Incorrect email or password',
    errGeneric: 'An error occurred. Please try again.',
  );
}
