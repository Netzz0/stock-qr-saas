# 🎯 Architecture - Stock QR SaaS

## Vue d'ensemble

Stock QR SaaS est construit selon une **Clean Architecture** avec **Domain-Driven Design** (DDD), séparant clairement les préoccupations et les dépendances.

## Architecture Globale

```
┌──────────────────────────────────┐
│          Frontend (Vue.js 3)           │
│      SPA with Atomic Design             │
└──────────────────────────────────┘
             ↓ REST API / WebSocket
┌──────────────────────────────────┐
│      Backend (ASP.NET Core 8)         │
│    Clean Architecture Layers          │
└──────────────────────────────────┘
             ↓ Entity Framework
┌──────────────────────────────────┐
│   PostgreSQL + Redis Cache           │
│   (Multi-Tenant with RLS)            │
└──────────────────────────────────┘
```

## Backend Architecture (Clean Architecture)

### Layers

```
backend/
├── src/
│   ├── StockQR.Api/              # Presentation Layer
│   │   ├── Controllers/        # HTTP endpoints
│   │   ├── Filters/            # Auth, logging filters
│   │   ├── Middleware/         # CORS, error handling
│   │   └── Startup.cs          # DI configuration
│   │
│   ├── StockQR.Application/     # Application Layer
│   │   ├── Commands/           # Command handlers
│   │   ├── Queries/            # Query handlers
│   │   ├── Services/           # Business logic
│   │   ├── DTOs/               # Data transfer objects
│   │   ├── Validators/         # FluentValidation
│   │   └── Mappings/           # AutoMapper profiles
│   │
│   ├── StockQR.Domain/         # Domain Layer (Core)
│   │   ├── Entities/           # Domain models
│   │   ├── ValueObjects/       # Value objects
│   │   ├── Interfaces/         # Domain interfaces
│   │   ├── Events/             # Domain events
│   │   └── Specifications/     # Business rules
│   │
│   ├── StockQR.Infrastructure/ # Infrastructure Layer
│   │   ├── Data/               # DbContext, migrations
│   │   ├── Repositories/       # Repository pattern
│   │   ├── Services/           # External services (S3, Email)
│   │   └── Identity/           # Auth service
│   │
│   └── StockQR.Tests/
```

### Layer Responsibilities

#### 1. Presentation Layer (API)

**Responsabilités:**
- Exposer les endpoints REST
- Valider les requêtes HTTP
- Transformer les DTOs en domain entities
- Retourner les responses formatées

**Ne doit pas:**
- Contenir de la logique métier
- Accéder directement à la BD
- Connaître les détails d'implémentation

```csharp
// Example controller
[ApiController]
[Route("api/v1/[controller]")]
public class ArticlesController : ControllerBase
{
    private readonly IArticleService _articleService;
    
    public ArticlesController(IArticleService articleService)
    {
        _articleService = articleService;
    }
    
    [HttpPost]
    public async Task<ActionResult<ArticleDto>> Create(
        CreateArticleDto dto)
    {
        var article = await _articleService.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), 
            new { id = article.Id }, article);
    }
}
```

#### 2. Application Layer

**Responsabilités:**
- Orchestrer la logique métier
- Valider les commandes/queries
- Implémenter les use cases
- Gérer les transactions
- Appeler les services d'infrastructure

**Pattern: CQRS (Command Query Responsibility Segregation)**

```csharp
// Command
public record CreateArticleCommand(
    string Name,
    string Description,
    string? Sku) : IRequest<ArticleDto>;

// Handler
public class CreateArticleCommandHandler 
    : IRequestHandler<CreateArticleCommand, ArticleDto>
{
    public async Task<ArticleDto> Handle(
        CreateArticleCommand request,
        CancellationToken cancellationToken)
    {
        // Business logic
    }
}

// Query
public record GetArticleQuery(Guid Id) 
    : IRequest<ArticleDto>;

// Handler
public class GetArticleQueryHandler 
    : IRequestHandler<GetArticleQuery, ArticleDto>
{
    public async Task<ArticleDto> Handle(
        GetArticleQuery request,
        CancellationToken cancellationToken)
    {
        // Query logic
    }
}
```

#### 3. Domain Layer

**Responsabilités:**
- Définir les entités du domaine
- Implémenter les règles métier
- Définir les interfaces
- Émettre les domain events
- Pas de dépendances externes

```csharp
// Domain Entity
public class Article
{
    public Guid Id { get; private set; }
    public Guid OrganizationId { get; private set; }
    public string Name { get; private set; }
    public string? Description { get; private set; }
    public string QrCode { get; private set; }
    
    // Business logic encapsulation
    public void UpdateName(string newName)
    {
        if (string.IsNullOrWhiteSpace(newName))
            throw new DomainException("Name is required");
        
        Name = newName;
        RaiseDomainEvent(new ArticleNameChangedEvent(Id, newName));
    }
    
    public void Archive()
    {
        if (Status == ArticleStatus.Archived)
            throw new DomainException("Already archived");
        
        Status = ArticleStatus.Archived;
        RaiseDomainEvent(new ArticleArchivedEvent(Id));
    }
}

// Domain Interface
public interface IArticleRepository
{
    Task<Article?> GetByIdAsync(Guid id, Guid organizationId);
    Task AddAsync(Article article);
    Task UpdateAsync(Article article);
}
```

#### 4. Infrastructure Layer

**Responsabilités:**
- Implémenter les repositories
- Gérer les connexions BD
- S'intégrer avec services externes (S3, Email)
- Gérer l'authentification
- Logging et monitoring

```csharp
// Repository Implementation
public class ArticleRepository : IArticleRepository
{
    private readonly ApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;
    
    public async Task<Article?> GetByIdAsync(
        Guid id, Guid organizationId)
    {
        return await _context.Articles
            .Where(a => a.Id == id && 
                   a.OrganizationId == organizationId)
            .FirstOrDefaultAsync();
    }
}

// External Service
public class S3StorageService : IStorageService
{
    private readonly IAmazonS3 _s3Client;
    
    public async Task<string> UploadAsync(
        Stream stream, string fileName)
    {
        var request = new PutObjectRequest
        {
            BucketName = _bucket,
            Key = fileName,
            InputStream = stream
        };
        
        await _s3Client.PutObjectAsync(request);
        return $"{_s3Endpoint}/{fileName}";
    }
}
```

## Frontend Architecture (Feature-Based)

### Structure

```
src/
├── components/               # Shared components
│   ├── ui/                # Atomic Design
│   │   ├── atoms/
│   │   ├── molecules/
│   │   └── organisms/
│   └── layouts/          # Layout components
│
├── features/               # Feature modules
│   ├── articles/
│   │   ├── components/   # Feature components
│   │   ├── pages/        # Page components
│   │   ├── store.js      # Pinia store
│   │   ├── api.js        # API calls
│   │   ├── types.ts      # TypeScript types
│   │   └── routes.js
│   │
│   ├── auth/
│   ├── movements/
│   └── reporting/
│
├── stores/                # Global Pinia stores
│   ├── auth.js
│   ├── organization.js
│   └── notifications.js
│
├── router/                # Vue Router
│   ├── index.js
│   ├── guards.js
│   └── routes.js
│
├── services/              # Shared services
│   ├── api-client.js      # Axios instance
│   ├── auth-service.js
│   └── storage-service.js
│
├── composables/           # Reusable logic
│   ├── useFetch.js
│   ├── useAuth.js
│   ├── usePagination.js
│   └── usePermissions.js
│
├── utils/                 # Utilities
│   ├── formatters.js
│   ├── validators.js
│   ├── constants.js
│   └── helpers.js
│
├── assets/                # Static assets
│   ├── icons/
│   ├── images/
│   └── styles/
│
├── App.vue
└── main.js
```

### State Management (Pinia)

```javascript
// stores/articles.js
import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import * as api from '@/features/articles/api';

export const useArticlesStore = defineStore('articles', () => {
  // State
  const articles = ref([]);
  const selectedArticle = ref(null);
  const loading = ref(false);
  const filters = ref({ category: null, search: '' });
  
  // Computed
  const filteredArticles = computed(() => {
    return articles.value.filter(a => {
      if (filters.value.search && 
          !a.name.toLowerCase().includes(filters.value.search)) {
        return false;
      }
      if (filters.value.category && a.categoryId !== filters.value.category) {
        return false;
      }
      return true;
    });
  });
  
  // Actions
  const fetchArticles = async () => {
    loading.value = true;
    try {
      articles.value = await api.getArticles();
    } finally {
      loading.value = false;
    }
  };
  
  const createArticle = async (data) => {
    const article = await api.createArticle(data);
    articles.value.push(article);
    return article;
  };
  
  return {
    articles,
    selectedArticle,
    loading,
    filters,
    filteredArticles,
    fetchArticles,
    createArticle
  };
});
```

## Database Design

### Multi-Tenant Strategy: Shared Database + RLS

**Avantages:**
- Coûts minimisés
- Maintenance simplifiée
- Isolation sécurisée au niveau BD
- Scalabilité

**Implémentation:**

```sql
-- Row-Level Security Policies
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;

CREATE POLICY rls_articles_isolation ON articles
    USING (org_id = current_setting('app.current_org_id')::uuid)
    WITH CHECK (org_id = current_setting('app.current_org_id')::uuid);

-- Before each request:
SET app.current_org_id = '{organizationId}';
```

**Tables Principales:**
- organizations
- users (org_id FK)
- articles (org_id FK)
- movements (org_id FK)
- stock_alerts (org_id FK)
- audit_logs (org_id FK)

Tous les accès vérifient l'org_id via RLS.

## Patterns & Best Practices

### 1. Dependency Injection

Utilisé systématiquement pour découpler les composants.

```csharp
public void ConfigureServices(IServiceCollection services)
{
    // Domain services
    services.AddScoped<IArticleService, ArticleService>();
    
    // Infrastructure
    services.AddScoped<IArticleRepository, ArticleRepository>();
    services.AddScoped<IStorageService, S3StorageService>();
    
    // Application
    services.AddMediatR(typeof(Program).Assembly);
}
```

### 2. Repository Pattern

Abstraction de la BD pour faciliter les tests.

```csharp
public interface IRepository<T> where T : BaseEntity
{
    Task<T?> GetByIdAsync(Guid id);
    Task<IEnumerable<T>> GetAllAsync();
    Task AddAsync(T entity);
    Task UpdateAsync(T entity);
    Task DeleteAsync(Guid id);
}
```

### 3. CQRS Pattern

Séparation commands (write) et queries (read).

### 4. Domain Events

Événements métier pour découpler les agrégats.

### 5. Specification Pattern

Réutilisable queries complexes.

### 6. Composables (Vue)

Logique réutilisable en composition API.

## Sécurité

### Backend

- **JWT Tokens:** Access (15min) + Refresh (7j)
- **RBAC:** Permissions granulaires
- **RLS:** Isolation au niveau BD
- **Input Validation:** FluentValidation
- **CORS:** Whitelist d'origins
- **HTTPS:** TLS 1.3
- **OWASP:** Top 10 adressé

### Frontend

- **XSS Protection:** Content Security Policy
- **CSRF:** CSRF tokens on state-changing requests
- **Secure Storage:** Tokens en memory (ou secure cookies)
- **HTTPS Only:** Secure flag on cookies
- **Dependency Scanning:** npm audit

## Performance

### Backend Optimization

- **Caching:** Redis pour sessions, queries
- **Database:** Indexes optimisés, query optimization
- **Async/Await:** I/O non-bloquant
- **Compression:** Gzip responses
- **Pagination:** Limit/offset

### Frontend Optimization

- **Code Splitting:** Lazy loading routes
- **Tree Shaking:** Unused code removal
- **Minification:** Production builds
- **CDN:** Asset delivery
- **Caching:** Service workers

## Monitoring & Logging

- **Structured Logging:** Serilog (backend), Console (frontend)
- **Distributed Tracing:** Application Insights / Jaeger
- **Metrics:** Prometheus
- **Uptime:** CloudWatch / Azure Monitor
- **Error Tracking:** Sentry

---

*Document complet : Voir les détails d'implémentation dans le code*
