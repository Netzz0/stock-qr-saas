# 🚀 Getting Started - Stock QR SaaS

Bienvenue sur le projet Stock QR SaaS ! Ce guide vous aide à démarrer rapidement le développement.

## 📋 Prérequis

### Requis
- **Git** : Pour cloner le repository
- **Docker & Docker Compose** : Pour l'environnement de développement
- **.NET 8.0 SDK** : Pour développer le backend
- **Node.js 18+** : Pour développer le frontend
- **PostgreSQL 14+** : Si vous exécutez localement (ou via Docker)

### Optionnel
- **VS Code** ou **Visual Studio** : Éditeur de code
- **Postman** ou **Insomnia** : API testing
- **DBeaver** ou **pgAdmin** : Database management
- **GitHub CLI** : Pour les opérations Git

## 📦 Installation Initiale

### 1. Cloner le Repository

```bash
git clone https://github.com/Netzz0/stock-qr-saas.git
cd stock-qr-saas
```

### 2. Installer les Dépendances Globales

```bash
# .NET
dotnet --version  # Should be 8.0+

# Node.js
node --version    # Should be 18+
npm --version     # Should be 9+

# Docker
docker --version  # Should be 20.10+
docker-compose --version
```

## 🐳 Démarrage Rapide avec Docker Compose

### Option A : Démarrage Complet (Recommandé)

```bash
# Démarrer tous les services
docker-compose up -d

# Vérifier le statut
docker-compose ps

# Attendre que tout soit prêt (30-60 secondes)
sleep 30

# Appliquer les migrations BD
docker exec stock-qr-api dotnet ef database update

# Accéder à l'application
# Frontend  : http://localhost:3000
# API       : http://localhost:5000
# Swagger   : http://localhost:5000/swagger
# pgAdmin   : http://localhost:5050 (admin@example.com / admin)
```

### Option B : Développement Mode (Frontend & Backend Séparés)

Utile si vous modifiez le code fréquemment.

```bash
# Terminal 1 : Infrastructure seulement
docker-compose up postgres redis mailhog

# Terminal 2 : Backend
cd backend
dotnet restore
dotnet ef database update
dotnet run
# API disponible : http://localhost:5000

# Terminal 3 : Frontend
cd frontend
npm install
npm run dev
# App disponible : http://localhost:3000
```

## 🛠️ Configuration de Développement

### Backend (.NET)

#### Setup Initial

```bash
cd backend

# Restaurer les dépendances
dotnet restore

# Appliquer les migrations
dotnet ef database update

# (Optionnel) Mettre à jour une migration
dotnet ef migrations add MigrationName

# (Optionnel) Supprimer la dernière migration
dotnet ef migrations remove
```

#### Lancer le Server

```bash
# Mode développement
dotnet run

# Ou avec watch (reload automatique)
dotnet watch run
```

#### Tester

```bash
# Tous les tests
dotnet test

# Filtre sur un test spécifique
dotnet test --filter ClassName.MethodName

# Avec code coverage
dotnet test /p:CollectCoverageMetrics=true
```

### Frontend (Vue.js)

#### Setup Initial

```bash
cd frontend

# Installer les dépendances
npm install

# Ou avec pnpm
pnpm install
```

#### Lancer le Dev Server

```bash
npm run dev
# Accédez à http://localhost:3000
```

#### Tester

```bash
# Tests unitaires
npm run test

# Watch mode
npm run test:watch

# Avec UI
npm run test:ui

# E2E tests
npm run test:e2e

# Coverage
npm run test:coverage
```

#### Linter & Formatter

```bash
# Linter
npm run lint

# Format
npm run format
```

## 🗄️ Base de Données

### Accéder à PostgreSQL

```bash
# Via pgAdmin (Web UI)
# URL: http://localhost:5050
# Email: admin@example.com
# Password: admin

# Via psql (CLI)
psql -h localhost -U stock_qr_user -d stock_qr_db
# Password: stock_qr_password_dev
```

### Réinitialiser la BD (ATTENTION: supprime les données)

```bash
make db-reset
# ou
docker-compose down -v
docker-compose up postgres redis
sleep 5
cd backend && dotnet ef database update
```

## 📚 Accéder à la Documentation

### En ligne

- **API Swagger** : http://localhost:5000/swagger
- **Architecture** : [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- **API complète** : [docs/API.md](docs/API.md)
- **Database** : [docs/DATABASE.md](docs/DATABASE.md)
- **Sécurité** : [docs/SECURITY.md](docs/SECURITY.md)
- **Déploiement** : [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)

### Format Local

```bash
# Lire un document Markdown
cat docs/ARCHITECTURE.md

# Ou ouvrir dans votre éditeur
code docs/
```

## 🔑 Variables d'Environnement

### Backend (backend/appsettings.Development.json)

Déjà configuré pour le développement local. À personnaliser si nécessaire.

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=stock_qr_db;Username=stock_qr_user;Password=stock_qr_password_dev"
  },
  "Jwt": {
    "Secret": "development-secret-key",
    "Issuer": "stock-qr-saas",
    "Audience": "stock-qr-app"
  }
}
```

### Frontend (frontend/.env.local)

Créer un fichier `.env.local` :

```bash
VITE_API_URL=http://localhost:5000
VITE_APP_NAME=Stock QR SaaS
VITE_ENABLE_ANALYTICS=false
```

## 🧪 Exemples de Test

### Tester l'API

#### Via cURL

```bash
# Register
curl -X POST http://localhost:5000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Password123!",
    "firstName": "John",
    "lastName": "Doe"
  }'

# Login
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Password123!"
  }'

# Get articles
BEARER_TOKEN="eyJhbGciOiJIUzI1NiIs..."
curl -H "Authorization: Bearer $BEARER_TOKEN" \
  http://localhost:5000/api/v1/articles
```

#### Via Postman

1. Ouvrir Postman
2. Importer la collection : [docs/postman-collection.json](docs/postman-collection.json) (à créer)
3. Configurer l'environnement : `http://localhost:5000`
4. Tester les endpoints

### Tester le Frontend

```bash
cd frontend

# Lancer les tests
npm run test

# Lancer les E2E tests
npm run test:e2e

# Ouvrir le navigateur E2E
npm run test:e2e -- --ui
```

## 📝 Workflow de Développement

### 1. Créer une Branche

```bash
git checkout -b feature/amazing-feature
# ou
git checkout -b fix/bug-description
```

### 2. Faire vos Changements

```bash
# Modifier le code
code .

# Tester localement
npm run test
dotnet test
```

### 3. Commit

```bash
# Commit avec message conventionnel
git add .
git commit -m "feat(articles): add QR code generation"

# Ou
git commit -m "fix(auth): prevent MFA bypass"
```

### 4. Push et PR

```bash
git push origin feature/amazing-feature

# Créer une Pull Request sur GitHub
```

Voir [CONTRIBUTING.md](CONTRIBUTING.md) pour plus de détails.

## 🐛 Troubleshooting

### Port déjà en utilisation

```bash
# Trouver le process utilisant le port
lsof -i :3000      # Frontend
lsof -i :5000      # Backend
lsof -i :5432      # Database

# Tuer le process
kill -9 <PID>

# Ou changer le port dans docker-compose.yml
```

### Docker issues

```bash
# Voir les logs
docker-compose logs <service_name>

# Redémarrer un service
docker-compose restart <service_name>

# Complètement nettoyer et recommencer
docker-compose down -v
docker system prune -a
docker-compose up -d
```

### Database connection issues

```bash
# Vérifier que PostgreSQL fonctionne
docker-compose ps postgres

# Se connecter directement
psql -h localhost -U stock_qr_user -d stock_qr_db

# Vérifier les logs
docker-compose logs postgres
```

### Frontend issues

```bash
# Nettoyer node_modules
rm -rf node_modules package-lock.json
npm install

# Vider le cache Vite
rm -rf .vite

# Redémarrer le dev server
npm run dev
```

### Backend issues

```bash
# Nettoyer les builds
dotnet clean
dotnet build

# Restaurer les dépendances
dotnet restore

# Vérifier les migrations
dotnet ef migrations list
```

## 📚 Resources Utiles

- **Vue 3** : https://vuejs.org/
- **ASP.NET Core** : https://docs.microsoft.com/en-us/aspnet/core/
- **PostgreSQL** : https://www.postgresql.org/docs/
- **Docker** : https://docs.docker.com/
- **Git** : https://git-scm.com/doc

## 🤝 Besoin d'Aide ?

- Consultez les [docs/](docs/)
- Ouvrez une [issue](https://github.com/Netzz0/stock-qr-saas/issues)
- Rejoignez les [discussions](https://github.com/Netzz0/stock-qr-saas/discussions)
- Contactez le team : dev@stock-qr-saas.example.com

## ✅ Checklist - Prêt à développer ?

- [ ] Repository cloné
- [ ] Docker & Docker Compose installés
- [ ] `docker-compose up -d` a fonctionné
- [ ] Frontend accessible sur http://localhost:3000
- [ ] API accessible sur http://localhost:5000
- [ ] Tests passent localement
- [ ] Documentation lue
- [ ] Branche de feature créée

**Bienvenue sur le projet ! Happy coding! 🎉**

---

*Last updated: December 24, 2025*
