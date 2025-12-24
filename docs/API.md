# 📄 Documentation API - Stock QR SaaS

Cette documentation couvre tous les endpoints REST de l'API Stock QR SaaS.

## Base URL

```
https://api.stock-qr-saas.example.com/api/v1
```

## Authentication

Tous les endpoints (sauf login/register) nécessitent un JWT token.

### Header

```
Authorization: Bearer {access_token}
```

### Obtenir un Token

```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password",
  "totpCode": "123456"  // Si MFA activé
}

200 OK
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "e7f8d9c4a2b1e0f9...",
  "expiresIn": 900
}
```

## Categories de Endpoints

1. **Authentication** - Authentification et autorisations
2. **Articles** - Gestion des articles/boîtes
3. **QR Codes** - Génération et gestion de QR codes
4. **Movements** - Historique et enregistrement des mouvements
5. **Locations** - Gestion des emplacements
6. **Users** - Gestion des utilisateurs et rôles
7. **Reports** - Génération de rapports
8. **Organizations** - Paramétrages organisationnels

### Format de Response Standard

```json
{
  "success": true,
  "data": {
    "id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    // ... other fields
  },
  "errors": null,
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "total": 100,
    "totalPages": 5
  },
  "meta": {
    "timestamp": "2025-12-24T15:30:00Z",
    "requestId": "req-abc123",
    "version": "1.0"
  }
}
```

## Endpoints Clefs

### Articles

#### Créer un article

```http
POST /articles
Content-Type: application/json
Authorization: Bearer {token}

{
  "name": "Widget A",
  "description": "Description du widget",
  "sku": "SKU-001",
  "categoryId": "category-uuid",
  "supplierId": "supplier-uuid",
  "expirationDate": "2026-12-31"
}

201 Created
{
  "success": true,
  "data": {
    "id": "article-uuid",
    "qrCode": "QR-ABC123",
    "qrCodeUrl": "https://...",
    "createdAt": "2025-12-24T15:30:00Z"
  }
}
```

#### Lister les articles

```http
GET /articles?page=1&pageSize=20&categoryId=xxx&search=widget
Authorization: Bearer {token}

200 OK
{
  "success": true,
  "data": [
    { "id": "...", "name": "Widget A", ... },
    { "id": "...", "name": "Widget B", ... }
  ],
  "pagination": { ... }
}
```

#### Consulter un article

```http
GET /articles/{articleId}
Authorization: Bearer {token}

200 OK
{
  "success": true,
  "data": {
    "id": "article-uuid",
    "name": "Widget A",
    "qrCode": "QR-ABC123",
    "images": [
      { "id": "img1", "url": "https://..." }
    ],
    "movements": [
      { "id": "mov1", "type": "in", "date": "2025-12-24" }
    ]
  }
}
```

### QR Codes

#### Consulter via QR Code (Public)

```http
GET /box/{qrCode}

200 OK
{
  "success": true,
  "data": {
    "id": "article-uuid",
    "name": "Widget A",
    "description": "...",
    "images": [...],
    "currentLocation": "Zone A, Rayon 1",
    "lastMovement": { ... },
    "movements": [ ... ]  // Last 10
  }
}
```

#### Générer un QR code

```http
GET /articles/{articleId}/qr
Authorization: Bearer {token}

200 OK
{
  "success": true,
  "data": {
    "qrCode": "QR-ABC123",
    "url": "https://api.../qr/ABC123.png",
    "svgUrl": "https://api.../qr/ABC123.svg"
  }
}
```

### Movements

#### Créer un mouvement

```http
POST /movements
Content-Type: application/json
Authorization: Bearer {token}

{
  "articleId": "article-uuid",
  "fromLocationId": "location-uuid",
  "toLocationId": "location-uuid",
  "movementType": "transfer",
  "quantity": 5,
  "reason": "Customer order #123",
  "notes": "Optional notes"
}

201 Created
{
  "success": true,
  "data": {
    "id": "movement-uuid",
    "performedAt": "2025-12-24T15:30:00Z",
    "performedBy": "user-uuid"
  }
}
```

#### Historique d'un article

```http
GET /articles/{articleId}/history?limit=10
Authorization: Bearer {token}

200 OK
{
  "success": true,
  "data": [
    {
      "id": "mov1",
      "type": "in",
      "from": null,
      "to": "Zone A",
      "date": "2025-12-24T15:30:00Z",
      "performedBy": "user-name"
    }
  ]
}
```

### Reports

#### Rapport d'état du stock

```http
GET /reports/stock?startDate=2025-01-01&endDate=2025-12-31&categoryId=xxx
Authorization: Bearer {token}

200 OK
{
  "success": true,
  "data": {
    "generatedAt": "2025-12-24T15:30:00Z",
    "period": "2025-01-01 to 2025-12-31",
    "summary": {
      "totalArticles": 100,
      "totalValue": 50000.00,
      "articlesLowStock": 5,
      "articlesExpired": 2
    },
    "byCategory": [
      {
        "categoryName": "Electronics",
        "count": 45,
        "value": 30000
      }
    ]
  }
}
```

#### Exporter un rapport

```http
GET /reports/{reportId}/export?format=pdf
Authorization: Bearer {token}

200 OK (Content-Type: application/pdf)
[PDF binary content]
```

### Users & Roles

#### Lister les utilisateurs

```http
GET /users
Authorization: Bearer {token}

200 OK
{
  "success": true,
  "data": [
    {
      "id": "user-uuid",
      "email": "user@example.com",
      "firstName": "John",
      "lastName": "Doe",
      "roles": ["gestionnaire"],
      "status": "active"
    }
  ]
}
```

#### Inviter un utilisateur

```http
POST /users/invite
Content-Type: application/json
Authorization: Bearer {token}

{
  "email": "newuser@example.com",
  "roleId": "role-uuid",
  "firstName": "Jane",
  "lastName": "Smith"
}

201 Created
{
  "success": true,
  "data": {
    "id": "user-uuid",
    "invitationToken": "inv-token-abc",
    "invitationUrl": "https://app.../accept-invite?token=..."
  }
}
```

## Codes d'Erreur

| Code | Description |
|------|-------------|
| 400 | Bad Request - Paramètres invalides |
| 401 | Unauthorized - Token manquant ou invalide |
| 403 | Forbidden - Permissions insuffisantes |
| 404 | Not Found - Ressource non trouvée |
| 409 | Conflict - Conflit (ex: SKU dupliqué) |
| 422 | Unprocessable Entity - Validation échouée |
| 429 | Too Many Requests - Rate limit dépassé |
| 500 | Internal Server Error - Erreur serveur |

## Rate Limiting

- 1000 requêtes par 15 minutes par user
- Headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

## Webhooks

Les événements suivants peuvent déclencher des webhooks :

- `article.created`
- `article.updated`
- `article.archived`
- `movement.created`
- `stock.alert.triggered`

## SDK & Clients

- JavaScript/TypeScript (npm package)
- Python (pip package)
- OpenAPI/Swagger spec disponible

---

*Documentation complète: Voir endpoints endpoint par endpoint dans l'API OpenAPI*
