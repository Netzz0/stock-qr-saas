# 📦 Stock QR SaaS - Gestion de Stock Multi-Tenant avec Codes QR

> **Une plateforme SaaS complète pour la gestion efficace et traçable des stocks via codes QR**

![Status](https://img.shields.io/badge/Status-Active%20Development-blue)
![Version](https://img.shields.io/badge/Version-1.0-brightgreen)
![License](https://img.shields.io/badge/License-MIT-green)

## 📋 Vue d'ensemble

**Stock QR SaaS** est une solution digitale complète permettant la gestion de stock optimisée pour les environnements professionnels multi-sites. La plateforme offre une traçabilité complète des boîtes/conteneurs via des codes QR, avec historique détaillé des mouvements et des contenus.

### 🎯 Objectifs Clés

✅ **Génération et impression de codes QR uniques** par boîte  
✅ **Scan de QR codes via application mobile/web**  
✅ **Pages web dynamiques** consultables en scannant le QR  
✅ **Gestion multi-tenant** (plusieurs organisations)  
✅ **Contrôle d'accès par rôles** (RBAC)  
✅ **Sécurité renforcée** des données  
✅ **Rapports et analyses avancées** de stock  

## 🏗️ Architecture Technique

### Stack Technology

| Composant | Technologie | Version |
|-----------|------------|---------|
| **Frontend** | Vue.js | 3.x |
| **Backend** | ASP.NET Core | 8.0+ |
| **Base de Données** | PostgreSQL | 14+ |
| **Conteneurisation** | Docker | 20.10+ |
| **Orchestration** | Kubernetes | 1.26+ |
| **Cloud** | AWS/Azure | Flexible |

### Architecture Générale

```
┌─────────────────────────────────────────────────────────────┐
│                        Frontend (Vue 3)                      │
│              Web App + QR Scanning Interface                 │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    API Gateway / CDN                         │
│                    (CloudFront + ALB)                        │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────┐
│           Backend API (ASP.NET Core 8.0)                     │
│  ├─ Controllers (REST Endpoints)                             │
│  ├─ Services (Business Logic)                                │
│  ├─ Data Access (Entity Framework)                           │
│  └─ Background Workers (Hangfire)                            │
└──────────────────────────────────────────────────────────────┘
                    ↙           ↓           ↖
        ┌─────────────────┐  ┌──────────────┐  ┌────────────┐
        │  PostgreSQL     │  │  Redis Cache │  │  S3/Blobs  │
        │  (Multi-AZ)     │  │  (Sessions)  │  │  (Images)  │
        └─────────────────┘  └──────────────┘  └────────────┘
```

## 📂 Structure du Projet

```
stock-qr-saas/
├── 📁 backend/                    # API ASP.NET Core
│   ├── src/
│   │   ├── Presentation/         # Controllers, DTOs
│   │   ├── Application/          # Services, Business Logic
│   │   ├── Domain/               # Entities, Interfaces
│   │   └── Infrastructure/       # Data Access, External Services
│   ├── tests/
│   ├── Dockerfile
│   └── appsettings.json
│
├── 📁 frontend/                   # Application Vue.js
│   ├── src/
│   │   ├── components/           # Atomic Design Components
│   │   ├── features/             # Feature-based modules
│   │   ├── stores/               # Pinia State Management
│   │   ├── router/               # Vue Router Configuration
│   │   ├── services/             # API Client, Utils
│   │   ├── assets/               # Images, Styles, Icons
│   │   └── App.vue
│   ├── public/
│   ├── tests/
│   ├── Dockerfile
│   ├── vite.config.js
│   └── package.json
│
├── 📁 infrastructure/             # IaC & Deployment
│   ├── terraform/                # AWS/Azure provisioning
│   ├── docker-compose.yml        # Local development
│   ├── k8s/                      # Kubernetes manifests
│   └── monitoring/               # Prometheus, Grafana configs
│
├── 📁 docs/                       # Documentation
│   ├── ARCHITECTURE.md
│   ├── API.md
│   ├── DATABASE.md
│   ├── SECURITY.md
│   ├── DEPLOYMENT.md
│   └── USER_GUIDE.md
│
├── 📁 .github/                    # GitHub Configuration
│   ├── workflows/                # CI/CD Pipelines
│   ├── ISSUE_TEMPLATE/
│   └── PULL_REQUEST_TEMPLATE.md
│
├── 📄 CAHIER_DES_CHARGES.md      # Spécifications Complètes
├── 📄 README.md                   # This file
├── 📄 LICENSE                     # MIT License
├── 📄 .gitignore
└── 📄 ROADMAP.md                  # Product Roadmap

```

## 🚀 Démarrage Rapide

### Prérequis

- Docker & Docker Compose
- Node.js 18+
- .NET 8.0 SDK
- PostgreSQL 14+ (ou via Docker)
- Git

### Installation Locale (Docker Compose)

```bash
# Cloner le repository
git clone https://github.com/Netzz0/stock-qr-saas.git
cd stock-qr-saas

# Démarrer l'environnement complet
docker-compose up -d

# Initialiser la base de données
docker exec stock-qr-api dotnet ef database update

# Accéder à l'application
# Frontend  : http://localhost:3000
# API Docs  : http://localhost:5000/swagger
# PgAdmin   : http://localhost:5050 (user: admin@example.com / password: admin)
```

### Configuration Développement (Mode Natif)

**Backend (ASP.NET Core)**
```bash
cd backend
dotnet restore
dotnet ef database update
dotnet run
# API disponible: http://localhost:5000
```

**Frontend (Vue.js)**
```bash
cd frontend
npm install
npm run dev
# App disponible: http://localhost:3000
```

## 📚 Documentation

Consultez les fichiers de documentation dans le dossier `docs/` :

- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Architecture détaillée et patterns
- **[API.md](docs/API.md)** - Documentation complète des endpoints REST
- **[DATABASE.md](docs/DATABASE.md)** - Schéma DB et migrations
- **[SECURITY.md](docs/SECURITY.md)** - Mesures de sécurité et conformité
- **[DEPLOYMENT.md](docs/DEPLOYMENT.md)** - Guide de déploiement en production
- **[USER_GUIDE.md](docs/USER_GUIDE.md)** - Guide utilisateur détaillé

## 🛣️ Roadmap

### Phase 1 : Fondations (M1 - Janvier 2026)
- ✅ Architecture technique validée
- ✅ Infrastructure cloud provisionnée
- ✅ CI/CD pipeline établi
- ✅ Design system défini
- **Deadline :** 31 janvier 2026

### Phase 2 : MVP Core (M2-M3 - Février-Mars 2026)
- 🔨 Authentication & RBAC
- 🔨 Gestion des articles (CRUD)
- 🔨 QR code generation & printing
- 🔨 Stock movements tracking
- 🔨 Basic dashboard
- **Deadline :** 31 mars 2026

### Phase 3 : Fonctionnalités Avancées (M4 - Avril-Mai 2026)
- ⏳ Advanced reporting & dashboards
- ⏳ Email notifications
- ⏳ Full audit trail
- ⏳ Stock alerts
- ⏳ PDF/Excel exports
- **Deadline :** 31 mai 2026

### Phase 4 : Go-Live (M5-M6 - Juin 2026)
- ⏳ User acceptance testing (UAT)
- ⏳ User training & documentation
- ⏳ Data migration support
- ⏳ Production deployment
- **Deadline :** 30 juin 2026

*Status Legend: ✅ Complete | 🔨 In Progress | ⏳ Planned*

## 👥 Rôles & Permissions (RBAC)

| Rôle | Permissions Clés |
|------|------------------|
| **Admin Organisationnel** | Gestion complète de l'organisation, utilisateurs, paramètres |
| **Gestionnaire de Stock** | CRUD articles, scan QR, mouvements, rapports |
| **Opérateur Logistique** | Scan et déplacement des boîtes |
| **Responsable Qualité** | Consultation, rapports, audits |
| **Utilisateur Consultatif** | Lecture seule |

## 🔐 Sécurité

- **Authentification** : Email/Password + MFA (TOTP)
- **SSO** : Google, Microsoft, OIDC
- **Encryption** : TLS 1.3 en transit, AES-256 au repos
- **Isolation des données** : Row-Level Security (PostgreSQL)
- **RBAC** : Contrôle d'accès basé sur les rôles
- **Audit Trail** : Logging complet de toutes les actions
- **Conformité** : RGPD, CCPA, ISO 27001 (roadmap)

## 📊 Performance Targets

| Métrique | Cible | Status |
|----------|-------|--------|
| Temps de chargement page | < 2s | ⏳ À valider |
| Temps de scan QR | < 1s | ⏳ À valider |
| API response time (p95) | < 200ms | ⏳ À valider |
| Uptime SLA | 99.9% | ⏳ À déployer |
| Concurrent users | 1000+ | ⏳ À tester |

## 🧪 Tests

```bash
# Backend tests
cd backend
dotnet test

# Frontend tests
cd frontend
npm run test
npm run test:e2e
```

## 📦 Déploiement

```bash
# Build Docker images
docker build -t stock-qr-api:latest ./backend
docker build -t stock-qr-frontend:latest ./frontend

# Push to registry
docker push stock-qr-api:latest
docker push stock-qr-frontend:latest

# Deploy to Kubernetes
kubectl apply -f infrastructure/k8s/
```

Voir [DEPLOYMENT.md](docs/DEPLOYMENT.md) pour les instructions détaillées.

## 🤝 Contribution

Les contributions sont bienvenues ! Veuillez :

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/amazing-feature`)
3. Commit vos changements (`git commit -m 'Add amazing feature'`)
4. Push vers la branche (`git push origin feature/amazing-feature`)
5. Ouvrir une Pull Request

Consultez [CONTRIBUTING.md](CONTRIBUTING.md) pour les directives complètes.

## 📄 Licence

Ce projet est licencié sous la Licence MIT - voir le fichier [LICENSE](LICENSE) pour les détails.

## 📞 Support & Contact

- **Issues & Bugs** : [GitHub Issues](https://github.com/Netzz0/stock-qr-saas/issues)
- **Discussions** : [GitHub Discussions](https://github.com/Netzz0/stock-qr-saas/discussions)
- **Email** : support@stock-qr-saas.example.com
- **Documentation** : [https://docs.stock-qr-saas.example.com](https://docs.stock-qr-saas.example.com)

## 🙏 Remerciements

- Équipe de conception du projet
- Communauté open-source (Vue.js, ASP.NET Core, PostgreSQL)
- Tous les contributeurs et testeurs

---

**Made with ❤️ by the Stock QR SaaS Team**

Last updated: December 24, 2025 | Version: 1.0
