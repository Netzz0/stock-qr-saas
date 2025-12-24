# 🔐 Sécurité - Stock QR SaaS

## Overview

Stock QR SaaS implémente une stratégie de sécurité multi-niveaux couvrant authentication, authorization, data protection, et compliance.

## Authentication

### Stratégie

1. **Email/Password + MFA**
   - Bcrypt hashing (cost 12+)
   - TOTP (Time-based One-Time Password)
   - Backup codes

2. **JWT Tokens**
   - Access token : 15 minutes
   - Refresh token : 7 jours
   - Algorithm : HS256 (signature HMAC)
   - Stored in memory (XSS protection)

3. **SSO (Planned)**
   - Google OAuth 2.0
   - Microsoft OIDC
   - Generic OIDC provider

### Implementation

```csharp
// Password hashing
public string HashPassword(string password)
{
    return BCrypt.Net.BCrypt.HashPassword(password, 12);
}

// JWT Token generation
public string GenerateAccessToken(User user)
{
    var tokenHandler = new JwtSecurityTokenHandler();
    var key = Encoding.ASCII.GetBytes(JWT_SECRET);
    
    var tokenDescriptor = new SecurityTokenDescriptor
    {
        Subject = new ClaimsIdentity(new[]
        {
            new Claim("sub", user.Id.ToString()),
            new Claim("org_id", user.OrganizationId.ToString()),
            new Claim("email", user.Email),
            // ... permissions
        }),
        Expires = DateTime.UtcNow.AddMinutes(15),
        Issuer = "stock-qr-saas",
        Audience = "stock-qr-app",
        SigningCredentials = new SigningCredentials(
            new SymmetricSecurityKey(key), 
            SecurityAlgorithms.HmacSha256Signature)
    };
    
    var token = tokenHandler.CreateToken(tokenDescriptor);
    return tokenHandler.WriteToken(token);
}
```

## Authorization (RBAC)

### Roles Prédéfinis

| Rôle | Permissions |
|------|-------------|
| **Admin Org** | Gestion complète |
| **Gestionnaire** | Articles, mouvements, rapports |
| **Opérateur** | Scan, mouvements |
| **Auditeur** | Consultation, rapports |
| **Consultatif** | Lecture seule |

### Implémentation

```csharp
// Attribute-based
[Authorize(Roles = "admin,gestionnaire")]
public IActionResult CreateArticle([FromBody] CreateArticleDto dto)
{
    // ...
}

// Policy-based
public void ConfigureServices(IServiceCollection services)
{
    services.AddAuthorization(options =>
    {
        options.AddPolicy("CanManageArticles", policy =>
            policy.RequireClaim("permission", "articles:create", "articles:update"));
    });
}

[Authorize(Policy = "CanManageArticles")]
public IActionResult CreateArticle([FromBody] CreateArticleDto dto)
{
    // ...
}
```

## Data Protection

### Encryption at Rest

- **Database:** EBS encryption (AWS) ou TDE (SQL Server)
- **Sensitive fields:** AES-256-CBC
  - Passwords (bcrypt)
  - API keys
  - Tokens

```csharp
public class EncryptionService
{
    public string Encrypt(string plainText)
    {
        using (var aes = Aes.Create())
        {
            aes.Key = Convert.FromBase64String(ENCRYPTION_KEY);
            aes.IV = new byte[16];
            
            var cipher = aes.CreateEncryptor();
            using (var ms = new MemoryStream())
            {
                using (var cs = new CryptoStream(ms, cipher, CryptoStreamMode.Write))
                {
                    using (var sw = new StreamWriter(cs))
                    {
                        sw.Write(plainText);
                    }
                    return Convert.ToBase64String(ms.ToArray());
                }
            }
        }
    }
}
```

### Encryption in Transit

- **TLS 1.3** pour toutes les communications
- **HSTS** (HTTP Strict Transport Security)
- **Certificate pinning** sur clients mobiles

```csharp
public void Configure(IApplicationBuilder app)
{
    app.UseHsts(); // max-age=31536000; includeSubDomains
    app.UseHttpsRedirection();
    
    app.UseCors(options => options
        .WithOrigins("https://...") // HTTPS only
        .AllowAnyMethod()
        .AllowAnyHeader()
        .AllowCredentials());
}
```

## Multi-Tenant Isolation

### Row-Level Security (RLS)

```sql
-- Chaque table a org_id
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;

CREATE POLICY rls_articles ON articles
    USING (org_id = current_setting('app.current_org_id')::uuid);

-- Avant chaque requête
SET app.current_org_id = '{organizationId}';
```

### Validation at Application Level

```csharp
public async Task<Article> GetArticleAsync(Guid articleId)
{
    var article = await _context.Articles
        .Where(a => a.Id == articleId && 
                   a.OrganizationId == _currentUserService.OrganizationId)
        .FirstOrDefaultAsync();
    
    if (article == null)
        throw new UnauthorizedAccessException("Article not found");
    
    return article;
}
```

## OWASP Top 10 Mitigations

### 1. Broken Access Control
- ✅ RBAC with granular permissions
- ✅ RLS at database level
- ✅ Resource ownership verification

### 2. Cryptographic Failures
- ✅ TLS 1.3
- ✅ AES-256 at rest
- ✅ Bcrypt for passwords
- ✅ Secure key management (AWS Secrets Manager)

### 3. Injection
- ✅ Parameterized queries (EF Core)
- ✅ Input validation (FluentValidation)
- ✅ Output encoding
- ✅ SQL injection prevention

### 4. Insecure Design
- ✅ Threat modeling
- ✅ Security reviews
- ✅ SDLC security gates
- ✅ Secure defaults

### 5. Security Misconfiguration
- ✅ Infrastructure as Code (Terraform)
- ✅ Secrets management
- ✅ Security headers
- ✅ Dependency scanning

### 6. Vulnerable Components
- ✅ Dependency scanning (Snyk, OWASP Dependency-Check)
- ✅ Regular updates
- ✅ Vulnerability tracking
- ✅ Supply chain security

### 7. Authentication Failures
- ✅ MFA mandatory
- ✅ Strong password policy
- ✅ Session timeout
- ✅ Secure token management

### 8. Data Integrity Failures
- ✅ Audit trail
- ✅ Digital signatures
- ✅ Change tracking
- ✅ Data validation

### 9. Logging & Monitoring Failures
- ✅ Centralized logging (ELK, Splunk)
- ✅ Alert monitoring
- ✅ Incident response
- ✅ Log retention (7+ years)

### 10. SSRF
- ✅ URL validation
- ✅ Whitelist external URLs
- ✅ Network isolation

## Compliance

### RGPD (GDPR)

- ✅ Data minimization
- ✅ Purpose limitation
- ✅ Storage limitation
- ✅ Data subject rights:
  - Right to access
  - Right to rectification
  - Right to erasure ("right to be forgotten")
  - Data portability

### CCPA

- ✅ Privacy policy
- ✅ Do Not Sell My Personal Information
- ✅ Data access requests
- ✅ Deletion requests

### ISO 27001

Roadmap:
- Information security policies
- Access control
- Cryptography
- Physical security
- Incident management
- Business continuity

## Audit Trail

### What We Log

```sql
CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,
    org_id UUID NOT NULL,
    user_id UUID,
    resource_type VARCHAR(100),
    resource_id UUID,
    action VARCHAR(50),
    old_values JSONB,
    new_values JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    timestamp TIMESTAMP DEFAULT NOW()
);
```

### Actions Logged

- User login/logout
- Permission changes
- Article create/update/delete
- Movement creation
- Configuration changes
- Data access (compliance)
- Security events

## Vulnerability Management

### Discovery

- SAST : SonarQube
- DAST : OWASP ZAP
- Dependency scanning : Snyk
- Container scanning : Trivy

### Response

1. Report received → Severity assessment
2. Patch development → Testing
3. Staged rollout → Monitoring
4. Closure & lessons learned

### Penetration Testing

- Frequency : 2x/year
- Scope : Full application + infrastructure
- External assessor
- Remediation within 30 days

## Security Headers

```csharp
public void Configure(IApplicationBuilder app)
{
    app.Use(async (context, next) =>
    {
        context.Response.Headers.Add("X-Content-Type-Options", "nosniff");
        context.Response.Headers.Add("X-Frame-Options", "DENY");
        context.Response.Headers.Add("X-XSS-Protection", "1; mode=block");
        context.Response.Headers.Add("Strict-Transport-Security", 
            "max-age=31536000; includeSubDomains");
        context.Response.Headers.Add("Content-Security-Policy",
            "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'");
        await next();
    });
}
```

## Incident Response

### Plan

1. **Detect** - Monitoring alerts
2. **Respond** - Incident team activation
3. **Contain** - Limit impact
4. **Eradicate** - Fix root cause
5. **Recover** - Restore services
6. **Review** - Lessons learned

### Contact

- Security team : security@stock-qr-saas.com
- Incident hotline : [24/7 number]
- Escalation : [process]

---

*Rév. 1.0 | Dec 2025*
