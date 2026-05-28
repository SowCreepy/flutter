# Mona

**Mona** est une application mobile de matchmaking gaming développée avec Flutter. Elle permet aux joueurs de trouver des coéquipiers, de suivre leurs performances et de communiquer en temps réel.

---

## Fonctionnalités

- **Authentification** — Inscription, connexion et reconnexion automatique sécurisée via token persistant.
- **Profil joueur** — Affiche le rang, le niveau, l'ELO, le statut de disponibilité et l'historique des derniers matchs.
- **Matchmaking** — Active ou désactive sa disponibilité et reçoit des invitations en temps réel pour jouer.
- **Messagerie instantanée** — Conversations en temps réel avec les autres joueurs via WebSocket.
- **Recherche de joueurs** — Parcourir et rechercher les joueurs de la communauté.
- **Ajout de match** — Enregistrer manuellement les résultats de ses parties (victoire/défaite, map, kills, deaths).
- **Édition de profil** — Modifier son pseudo, son lien Steam et sa photo de profil.

---

## Stack technique

| Technologie                                                               | Usage                                            |
| ------------------------------------------------------------------------- | ------------------------------------------------ |
| [Flutter](https://flutter.dev)                                            | Framework UI cross-platform                      |
| [http](https://pub.dev/packages/http)                                     | Appels REST vers l'API backend                   |
| [socket_io_client](https://pub.dev/packages/socket_io_client)             | Communication temps réel (invitations, messages) |
| [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) | Stockage sécurisé du token d'authentification    |
| [image_picker](https://pub.dev/packages/image_picker)                     | Sélection de photo de profil                     |
| [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)                 | Gestion des variables d'environnement            |

---

## Structure du projet

```
lib/
├── main.dart               # Point d'entrée, routing et splash screen
├── main_shell.dart         # Navigation principale (bottom nav bar)
├── models/                 # Modèles de données (Player, MatchResult, etc.)
├── pages/                  # Écrans de l'application
│   ├── home.dart           # Page d'accueil (landing)
│   ├── login.dart          # Connexion
│   ├── register.dart       # Inscription
│   ├── profile.dart        # Profil du joueur connecté
│   ├── matchmaking.dart    # File de matchmaking
│   ├── messages.dart       # Liste des conversations
│   ├── chat.dart           # Conversation individuelle
│   ├── users.dart          # Annuaire des joueurs
│   ├── search_last.dart    # Recherche de joueurs
│   ├── add_match.dart      # Ajout d'un match
│   └── edit_profile.dart   # Édition du profil
├── services/               # Logique métier et accès réseau
│   ├── api_client.dart     # Client HTTP centralisé
│   ├── auth_service.dart   # Gestion de l'authentification
│   ├── socket_service.dart # Connexion WebSocket
│   └── invitation_store.dart # Gestion des invitations
└── components/             # Widgets réutilisables
```

---

## Installation

### Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) >= 3.11
- Un émulateur Android/iOS ou un appareil physique

### Lancer l'application

1. Cloner le dépôt :

   ```bash
   git clone <url-du-repo>
   cd mon_app
   ```

2. Créer un fichier `.env` à la racine du projet :

   ```env
   API_URL=http://10.0.2.2:3000/api
   NOM de l'api : api_mona
   ```

3. Installer les dépendances :

   ```bash
   flutter pub get
   ```

4. Démarrer l'application :
   ```bash
   flutter run
   ```

---

## Plateformes supportées

Android · iOS · Web · Windows · macOS · Linux
