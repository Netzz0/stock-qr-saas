# 💾 Base de Données - Stock QR SaaS

## Vue d'ensemble

La base de données utilise **PostgreSQL 14+** avec une stratégie **multi-tenant** utilisant **Row-Level Security (RLS)** pour l'isolation des données.

## Stratégie Multi-Tenant

### Approche : Shared Database + RLS

**Avantages:**
- Coûts opérationnels minimisés
- Maintenance simplifiée
- Isolation sécurisée au niveau BD
- Scalabilité horizontale

**Implémentation:**

1. Chaque table a une colonne `org_id` (organization ID)
2. Politiques RLS appliquées automatiquement
3. Avant chaque requête, définir l'org_id courant

```sql
-- Avant chaque requête
SET app.current_org_id = '{organizationId}';

-- Exemple de politique RLS
CREATE POLICY rls_articles_isolation ON articles
    USING (org_id = current_setting('app.current_org_id')::uuid)
    WITH CHECK (org_id = current_setting('app.current_org_id')::uuid);
```

## Schéma de Base de Données

### Tables Principales

#### 1. Organizations

Isolation au niveau organisation.

```sql
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    logo_url VARCHAR(500),
    primary_color VARCHAR(7),
    secondary_color VARCHAR(7),
    status VARCHAR(50) DEFAULT 'active',
    subscription_plan VARCHAR(50) DEFAULT 'free',
    max_boxes INTEGER DEFAULT 1000,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

#### 2. Users

Utilisateurs avec authentification.

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID NOT NULL REFERENCES organizations(id),
    email VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    password_hash VARCHAR(255),
    avatar_url VARCHAR(500),
    status VARCHAR(50) DEFAULT 'active',
    mfa_enabled BOOLEAN DEFAULT false,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(org_id, email)
);
```

#### 3. Articles/Boîtes

Articles avec génération de QR codes.

```sql
CREATE TABLE articles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID NOT NULL REFERENCES organizations(id),
    category_id UUID REFERENCES categories(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    sku VARCHAR(100) UNIQUE,
    qr_code VARCHAR(255) UNIQUE NOT NULL,
    supplier VARCHAR(200),
    status VARCHAR(50) DEFAULT 'active',
    expiration_date DATE,
    quantity INTEGER DEFAULT 1,
    unit_price DECIMAL(10, 2),
    image_urls TEXT[] DEFAULT '{}',
    attributes JSONB,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

#### 4. Categories

Catégorisation des articles.

```sql
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID NOT NULL REFERENCES organizations(id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    color VARCHAR(7),
    icon VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(org_id, name)
);
```

#### 5. Locations

Hiérarchie d'emplacements.

```sql
CREATE TABLE locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID NOT NULL REFERENCES organizations(id),
    parent_id UUID REFERENCES locations(id),
    name VARCHAR(100) NOT NULL,
    code VARCHAR(50),
    location_type VARCHAR(50), -- 'site', 'warehouse', 'zone', 'shelf', 'bin'
    capacity INTEGER,
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(org_id, code)
);
```

#### 6. Stock Movements

Historique des mouvements.

```sql
CREATE TABLE movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID NOT NULL REFERENCES organizations(id),
    article_id UUID NOT NULL REFERENCES articles(id),
    from_location_id UUID REFERENCES locations(id),
    to_location_id UUID NOT NULL REFERENCES locations(id),
    movement_type VARCHAR(50), -- 'in', 'out', 'transfer', 'sale', 'return'
    quantity INTEGER NOT NULL,
    reason TEXT,
    performed_by UUID NOT NULL REFERENCES users(id),
    performed_at TIMESTAMP DEFAULT NOW(),
    approved BOOLEAN DEFAULT false,
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

#### 7. Audit Logs

Traçabilité complète.

```sql
CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,
    org_id UUID NOT NULL REFERENCES organizations(id),
    user_id UUID REFERENCES users(id),
    resource_type VARCHAR(100),
    resource_id UUID,
    action VARCHAR(50), -- 'create', 'update', 'delete'
    old_values JSONB,
    new_values JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    timestamp TIMESTAMP DEFAULT NOW()
);
```

## Politiques Row-Level Security

### Application Automatique

```sql
-- Articles
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;
CREATE POLICY rls_articles_isolation ON articles
    USING (org_id = current_setting('app.current_org_id')::uuid)
    WITH CHECK (org_id = current_setting('app.current_org_id')::uuid);

-- Movements
ALTER TABLE movements ENABLE ROW LEVEL SECURITY;
CREATE POLICY rls_movements_isolation ON movements
    USING (org_id = current_setting('app.current_org_id')::uuid)
    WITH CHECK (org_id = current_setting('app.current_org_id')::uuid);

-- Audit Logs
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY rls_audit_logs_isolation ON audit_logs
    USING (org_id = current_setting('app.current_org_id')::uuid);

-- Appliquer pour toutes les tables multi-tenant
```

## Index pour Performance

### Indexes Critiques

```sql
-- Organizations
CREATE UNIQUE INDEX idx_organizations_slug ON organizations(slug);

-- Articles
CREATE INDEX idx_articles_org_id ON articles(org_id);
CREATE INDEX idx_articles_qr_code ON articles(qr_code);
CREATE INDEX idx_articles_sku ON articles(sku);
CREATE INDEX idx_articles_category_id ON articles(category_id);

-- Movements
CREATE INDEX idx_movements_org_id ON movements(org_id);
CREATE INDEX idx_movements_article_id ON movements(article_id);
CREATE INDEX idx_movements_location_id ON movements(to_location_id);
CREATE INDEX idx_movements_performed_at ON movements(performed_at DESC);
CREATE INDEX idx_movements_user_id ON movements(performed_by);

-- Users
CREATE UNIQUE INDEX idx_users_org_email ON users(org_id, email);
CREATE INDEX idx_users_status ON users(status);

-- Audit Logs
CREATE INDEX idx_audit_logs_org_id ON audit_logs(org_id);
CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp DESC);
CREATE INDEX idx_audit_logs_resource ON audit_logs(resource_type, resource_id);
```

## Migrations

### Framework : Entity Framework Core (EF)

Les migrations sont gérées via EF Core.

```bash
# Créer une nouvelle migration
dotnet ef migrations add AddArticleTable

# Appliquer les migrations
dotnet ef database update

# Générer le SQL
dotnet ef migrations script
```

### Script d'initialisation

```sql
-- Init.sql - Création de la structure et des politiques RLS

-- 1. Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. Create all tables (voir schéma ci-dessus)
-- ...

-- 3. Enable RLS and create policies
-- ...

-- 4. Create indexes
-- ...
```

## Backup & Recovery

### Backup Strategy

```bash
# Backup quotidien
pg_dump -U stock_qr_user -d stock_qr_db > backup-$(date +%Y%m%d).sql

# Backup compress
pg_dump -U stock_qr_user -d stock_qr_db | gzip > backup-$(date +%Y%m%d).sql.gz

# Backup avec custom format
pg_dump -U stock_qr_user -d stock_qr_db -F c -b > backup-$(date +%Y%m%d).dump
```

### Recovery

```bash
# Restore from SQL
psql -U stock_qr_user -d stock_qr_db < backup-20251224.sql

# Restore from dump
pg_restore -U stock_qr_user -d stock_qr_db backup-20251224.dump
```

## Connection String

```
Host=localhost;Port=5432;Database=stock_qr_db;Username=stock_qr_user;Password=XXXX
```

## Maintenance

### VACUUM & ANALYZE

```sql
-- Maintenance quotidienne
VACUUM ANALYZE;

-- Pour une table spécifique
VACUUM ANALYZE articles;

-- VACUUM FULL (lent, ne pas faire en production pendant heures de pointe)
VACUUM FULL;
```

### Monitoring

```sql
-- Taille de la base de données
SELECT pg_size_pretty(pg_database_size('stock_qr_db'));

-- Taille par table
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Statistiques de cache
SELECT 
    schemaname,
    tablename,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
```

---

*Pour plus de détails, consultez la documentation PostgreSQL officielle*
