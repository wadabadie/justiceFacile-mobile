# JusticeFacile — Application Mobile

> Plateforme citoyenne d'assistance juridique avec dispositif spécial de soutien aux victimes de violences basées sur le genre (VBG) en contexte camerounais.

---

## Présentation

**JusticeFacile** est une application mobile développée avec Flutter, conçue pour rapprocher la justice de chaque citoyen camerounais. Elle s'adresse aussi bien aux citoyens ordinaires qui veulent comprendre leurs droits, qu'aux victimes de violences basées sur le genre (VBG) qui ont besoin d'écoute, de protection et d'accompagnement.

> *"Trop de personnes souffrent en silence par manque d'informations ou par peur de démarches compliquées. JusticeFacile veut changer cela : offrir une justice plus proche, plus simple, et plus humaine."*

---

## Fonctionnalités

### Information juridique
- Consultation et téléchargement des textes de loi camerounais
- FAQ juridique simplifiée, accessible à tous les niveaux d'instruction
- Moteur de recherche dans les textes juridiques
- Résumés automatiques des lois via intelligence artificielle

### Mise en relation avec des experts
- Répertoire des juristes, avocats et psychologues partenaires
- Prise de rendez-vous en ligne (présentiel ou à distance)
- Messagerie sécurisée et chiffrée avec les professionnels
- Consultation par tchat ou appel vidéo

### Module VBG — Soutien aux victimes de violences basées sur le genre
- Signalement anonyme et sécurisé d'un incident de violence
- Journal multimédia sécurisé (texte, photo, audio) comme outil de preuve discrète
- Espace de suivi de dossier personnel, confidentiel
- Accompagnement juridique, psychologique ET social intégré
- Mise en relation rapide avec des psychologues partenaires formés
- Système de rappels automatiques pour assurer le suivi post-agression
- Aucun frais pour les victimes (inscription et prise en charge gratuites)

### Module ONG & Institutions
- Interface dédiée aux ONG (IOM, MINPROFF, UNFPA, associations locales)
- Suivi à distance des cas signalés
- Gestion des calendriers d'actions sur le terrain
- Promulgation de plans d'intervention

### Accessibilité
- **Assistant vocal** : piloter toute l'application à la voix, pour les malvoyants et les personnes peu à l'aise avec le numérique
- **Entrée vocale** : formuler ses questions ou signalements par la parole
- Interface disponible en **français et en anglais**
- Conçu pour les zones à faible connexion internet (mode hors-ligne partiel)

### Sécurité & Confidentialité
- Authentification sécurisée par token JWT
- Données VBG chiffrées en base et en transit
- Signalement anonyme : aucun lien entre l'identité de la victime et son rapport
- Aucun log de données personnelles ou médicales côté serveur

---

## Fonctionnalités innovantes

| Fonctionnalité | Description |
|---|---|
| Assistant IA juridique | Chatbot capable de répondre aux questions juridiques en langage naturel, accessible même aux personnes peu instruites |
| Signalement anonyme avec escrow | Les signalements VBG peuvent être activés uniquement lorsqu'un deuxième signalement correspond (identification des récidivistes) |
| Journal de preuves sécurisé | Enregistrement discret de preuves multimédias non stockées localement, envoyées vers un espace sécurisé |
| Assistant vocal intégral | Navigation complète de l'application à la voix — unique pour l'inclusion des malvoyants et illettrés |
| Suivi post-agression automatisé | Rappels programmés pour vérifier l'état de la victime et prévenir l'abandon de procédure |
| Répertoire géolocalisé | Carte des services d'urgence, centres d'écoute et ONG à proximité |
| Mode hors-ligne | Accès aux textes de loi téléchargés et formulaires de signalement en cache, même sans connexion |
| Multilingue & vocal | Prise en charge du français, de l'anglais et potentiellement des langues locales via synthèse vocale |

---

## Stack technique

- **Framework** : Flutter (Dart SDK ^3.10.7)
- **Backend** : API REST Django 6 — dépôt [`justiceFacile-backend`](https://github.com/wadabadie/justiceFacile-backend)
- **Authentification** : JWT (djangorestframework-simplejwt)
- **État** : Flutter Riverpod
- **Navigation** : go_router
- **HTTP** : Dio
- **Stockage sécurisé** : flutter_secure_storage
- **Vocal** : flutter_tts + speech_to_text
- **Internationalisation** : intl

---

## Installation

```bash
# Cloner le dépôt
git clone https://github.com/wadabadie/justiceFacile-mobile.git
cd justiceFacile-mobile

# Installer les dépendances
flutter pub get

# Lancer sur émulateur ou appareil
flutter run
```

> Assurez-vous que le backend Django tourne sur `http://10.0.2.2:8000` (émulateur Android) ou `http://localhost:8000` (iOS simulator).

---

## Contexte & Motivation

Au Cameroun :
- **58%** des femmes victimes de VBG n'ont pas accès à une assistance juridique appropriée *(MINPROFF & ONU Femmes, 2024)*
- **72%** des camerounais en zone rurale ne connaissent pas les mécanismes d'aide juridique *(Ministère de la Justice & PNUD, 2025)*
- La saturation des juridictions et la faible vulgarisation du droit aggravent l'exclusion judiciaire

JusticeFacile répond à ces trois obstacles :
1. **Distance** — mise en relation citoyens/experts sans contrainte géographique
2. **Information** — vulgarisation des textes de loi et simplification des démarches
3. **Vulnérabilité** — dispositif spécifique, confidentiel et gratuit pour les victimes de VBG

---

## Auteure

**BADIE PEMBOURA WADA**  
Étudiante en Génie Logiciel — GL3B, IAI-CAMEROUN
