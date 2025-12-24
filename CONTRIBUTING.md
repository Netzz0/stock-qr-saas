# 🤝 Guide de Contribution

Merci d'intéresser au projet Stock QR SaaS ! Ce guide vous aide à contribuer efficacement.

## Code de Conduite

Ce projet adhère au [Contributor Covenant](https://www.contributor-covenant.org/). En participant, vous acceptez de respecter ce code de conduite.

## Comment Contribuer

### 1. Issues

Avant de démarrer, vérifiez si une issue similaire existe. Si c'est un nouveau bug/feature :

```markdown
**Pour un bug:**
- Titre clair et descriptif
- Étapes pour reproduire
- Comportement actuel vs attendu
- Screenshots/logs si applicable
- Environnement (OS, navigateur, versions)

**Pour une feature:**
- Cas d'usage clair
- Bénéfices attendus
- Implémentation suggérée (optionnel)
```

### 2. Fork & Branch

```bash
# Fork le repo
git clone https://github.com/YOUR_USERNAME/stock-qr-saas.git
cd stock-qr-saas

# Create feature branch
git checkout -b feature/amazing-feature
# ou
git checkout -b fix/bug-description
```

**Convention de nommage:**
- `feature/` - Nouvelle fonctionnalité
- `fix/` - Correction de bug
- `docs/` - Documentation
- `refactor/` - Refactorisation
- `perf/` - Optimisation performance
- `test/` - Ajout de tests

### 3. Développement

#### Setup

```bash
# Backend
cd backend
dotnet restore
dotnet ef database update

# Frontend
cd frontend
npm install
```

#### Code Standards

**C# / ASP.NET Core:**
- Suivre les [Microsoft C# Coding Conventions](https://docs.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions)
- PascalCase pour classes/méthodes publiques
- camelCase pour variables locales
- Utiliser `var` quand le type est évident
- XML comments pour les méthodes publiques

```csharp
/// <summary>
/// Creates a new article with QR code generation.
/// </summary>
/// <param name="createArticleDto">Article creation DTO</param>
/// <returns>Created article with QR code</returns>
public async Task<ArticleDto> CreateArticleAsync(CreateArticleDto createArticleDto)
{
    // Implementation
}
```

**Vue.js / JavaScript:**
- Suivre [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- camelCase pour variables/fonctions
- PascalCase pour composants Vue
- 2 espaces d'indentation
- Semi-colons obligatoires
- Single quotes pour strings

```javascript
// composables/useArticles.js
export function useArticles() {
  const articles = ref([]);
  
  const fetchArticles = async () => {
    const { data } = await api.get('/articles');
    articles.value = data;
  };
  
  return {
    articles: readonly(articles),
    fetchArticles
  };
}
```

### 4. Testing

Tout nouveau code doit avoir des tests :

```bash
# Backend tests
cd backend
dotnet test

# Frontend tests
cd frontend
npm run test
npm run test:e2e
```

**Coverage Minimum:**
- Nouvelles features : 80%+
- Bug fixes : test pour reproduire le bug

### 5. Commit Messages

Suivre [Conventional Commits](https://www.conventionalcommits.org/) :

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat:` Nouvelle fonctionnalité
- `fix:` Correction de bug
- `docs:` Documentation
- `style:` Formatage, linting
- `refactor:` Refactorisation code
- `perf:` Optimisation performance
- `test:` Ajout/modification tests
- `chore:` Dépendances, config

**Exemples:**

```
feat(articles): add QR code generation API

- Implement QR code generation using ZXing.Net
- Add batch generation endpoint
- Cache QR codes in S3

Closes #123

fix(auth): prevent MFA bypass vulnerability

Validate TOTP token before session creation.

RELATED-TO: #456
```

### 6. Push & Pull Request

```bash
# Push votre branche
git push origin feature/amazing-feature

# Ouvrir une Pull Request sur GitHub
```

**Template PR:**

```markdown
## Description

Brève description des changements

## Type de Changement

- [ ] Bug fix
- [ ] Nouvelle fonctionnalité
- [ ] Breaking change
- [ ] Documentation

## Changes

- Change 1
- Change 2

## Testing

- [ ] Tests unitaires ajoutés
- [ ] Tests manuels effectués
- [ ] Pas de régressions détectées

## Checklist

- [ ] Mon code suit les style guidelines du projet
- [ ] J'ai effectué une self-review de mon code
- [ ] J'ai ajouté des commentaires si nécessaire
- [ ] J'ai mis à jour la documentation
- [ ] Mes changements ne créent pas de warnings
- [ ] J'ai ajouté des tests
- [ ] Les tests existants passent

Closes #ISSUE_NUMBER
```

## Process de Review

1. **Automated Checks:**
   - Tests passent (GitHub Actions)
   - Code coverage acceptable
   - Linting réussit
   - Build réussit

2. **Code Review:**
   - Au minimum 2 approvals
   - Tech lead approval requis pour changes majeurs
   - Feedback addressé et discuté

3. **Merge:**
   - Squash commits si nécessaire
   - Delete branch after merge
   - Reference issues fermées

## Documentation

- Mettez à jour le README si nécessaire
- Ajoutez des exemples pour nouvelles features
- Documentez les breaking changes
- Mettez à jour CHANGELOG.md

## Reporting Bugs

**Avant de créer une issue:**

1. Vérifiez que le bug existe sur `main`
2. Recherchez les issues existantes
3. Rassemblez les informations:
   - Version du logiciel
   - Système d'exploitation
   - Navigateur/client
   - Étapes pour reproduire
   - Logs/screenshots

## Demander une Feature

1. Décrivez clairement le use case
2. Expliquez le bénéfice
3. Proposez une solution (optionnel)
4. Attendez le feedback avant de coder

## Questions?

- Lisez la [documentation](docs/)
- Posez une question dans [Discussions](https://github.com/Netzz0/stock-qr-saas/discussions)
- Rejoignez notre communauté

## License

En contribuant, vous acceptez que vos contributions soient licenciées sous la MIT License.

---

Merci de contribuer ! 🙏
