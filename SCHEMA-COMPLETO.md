# ✅ SCHEMA COMPLETO - PORTAL DE INDICADORES WAY BRASIL

## 🎉 SCHEMA ATUALIZADO COM SUCESSO!

Baseado na sua especificação detalhada, criei o **schema completo** com **13 tabelas**, **filtro obrigatório por unidade (org_units)** e todos os relacionamentos necessários.

---

## 📊 TABELAS CRIADAS

### 1. **org_units** (Unidades Organizacionais)
**Objetivo**: Filtro global obrigatório para todo o portal

- `id` (PK)
- `code` (único) — WAY262, WAY153, WAY364, etc.
- `name` (único) — Way 262, Way 153, etc.
- `description`
- `is_active`
- `created_at`, `updated_at`

**Telas**: Lista de unidades, Cadastro/edição
**Uso**: Filtro em todo o portal

---

### 2. **users** (Usuários)
**Objetivo**: Autenticação, perfis e auditoria

- `id` (PK)
- `name` (obrigatório)
- `email` (único, opcional)
- `role` (obrigatório) — admin | manager | editor | viewer
- `password_hash`
- `is_active`
- `created_at`, `updated_at`, `last_login`

**Telas**: Administração → Usuários (lista + editar)

---

### 3. **categories** (Categorias de Indicadores)
**Objetivo**: Agrupar indicadores nas 8 categorias

- `id` (PK)
- `name` (único, obrigatório)
- `description`
- `icon` (Font Awesome)
- `color` (hex)
- `sort_order` (ordem de exibição)
- `is_active`
- `created_at`, `updated_at`

**Telas**: Lista (grid), Cadastro/edição (admin/editor)

---

### 4. **indicators** (Indicadores)
**Objetivo**: Catálogo do indicador + valor atual

- `id` (PK)
- `org_unit_id` (FK, obrigatório) → org_units
- `category_id` (FK, obrigatório) → categories
- `name` (obrigatório)
- `description`
- `unit` (%, qtd, horas, R$)
- `target_value` (meta numérica)
- `min_good_percent` (verde >= 90%)
- `min_warn_percent` (amarelo >= 70%)
- `status` — success | warning | critical
- `current_value` (último valor)
- `current_percent` (atingimento)
- `last_updated_at`
- `owner_user_id` (FK) → users
- `is_active`
- `created_at`, `updated_at`

**Regras/Validações**:
- `min_warn_percent <= min_good_percent` (constraint)
- Status calculado automaticamente pelo percent

**Telas**: 
- Lista com filtros (unidade, categoria, status, busca)
- Cadastro/edição
- Detalhe (histórico + gráfico)

---

### 5. **indicator_history** (Histórico de Indicadores)
**Objetivo**: Timeline para gráficos e auditoria

- `id` (PK)
- `indicator_id` (FK, obrigatório) → indicators
- `org_unit_id` (FK, obrigatório) → org_units
- `ref_date` (data referência)
- `value` (obrigatório)
- `target_value` (snapshot da meta)
- `percent_value` (atingimento)
- `status` — success | warning | critical
- `note` (observação)
- `created_by` (FK) → users
- `created_at`

**Telas**:
- Modal "Histórico" (timeline)
- Novo lançamento (ref_date, value, note)

---

### 6. **it_assets** (Ativos de TI)
**Objetivo**: Inventário (hardware, software, licenças)

- `id` (PK)
- `org_unit_id` (FK, obrigatório) → org_units
- `type` — hardware | software | license
- `name` (obrigatório)
- `serial`
- `brand`, `model`
- `status` — active | maintenance | discarded
- `location`
- `responsible`
- `acquisition_date`
- `notes`
- `created_at`, `updated_at`

**Telas**:
- Lista (filtros: unidade, tipo, status, busca)
- Cadastro/edição
- Detalhe

---

### 7. **tickets** (Chamados)
**Objetivo**: Gestão de chamados (GLPI ou interno)

- `id` (PK)
- `org_unit_id` (FK, obrigatório) → org_units
- `code` (ID externo GLPI)
- `title` (obrigatório)
- `category`
- `priority` — low | medium | high | critical
- `status` — open | in_progress | resolved | closed
- `requester`
- `assignee`
- `opened_at`, `resolved_at`
- `satisfaction` (1 a 5)
- `notes`
- `created_at`, `updated_at`

**Telas**:
- Lista (filtros: unidade, status, prioridade, período)
- Cadastro/edição
- Detalhe (timeline)

---

### 8. **projects** (Projetos)
**Objetivo**: Controle de projetos e melhorias (PMO)

- `id` (PK)
- `org_unit_id` (FK, obrigatório) → org_units
- `name` (obrigatório)
- `description`
- `status` — planning | in_progress | completed | paused
- `progress` (0 a 100) — constraint
- `start_date`, `end_date`
- `owner`, `sponsor`
- `notes`
- `created_at`, `updated_at`

**Telas**:
- Lista (filtros: unidade, status, prazo)
- Cadastro/edição
- Detalhe (progresso + datas)

---

### 9. **backups** (Backups)
**Objetivo**: Evidências de backup/restore

- `id` (PK)
- `org_unit_id` (FK, obrigatório) → org_units
- `system_name` (obrigatório)
- `type` — full | incremental | differential
- `status` — success | failed | warning
- `size_mb`
- `location`
- `executed_at` (obrigatório)
- `restore_tested` (sim/não)
- `notes`
- `created_at`

**Telas**:
- Lista (filtros: unidade, sistema, status, período)
- Cadastro rápido

---

### 10. **network_links** (Links de Rede)
**Objetivo**: Monitorar links e disponibilidade

- `id` (PK)
- `org_unit_id` (FK, obrigatório) → org_units
- `name` (obrigatório)
- `type` — fibra | radio | 4g | vpn
- `status` — up | down | degraded
- `uptime_percent`
- `bandwidth_mbps`
- `latency_ms`
- `provider`
- `location`
- `last_check_at`
- `notes`
- `created_at`, `updated_at`

**Telas**:
- Lista (filtros: unidade, status, tipo)
- Detalhe (última checagem)

---

### 11. **resources** (Recursos / Estoque)
**Objetivo**: Itens controlados (chips M2M, consumíveis)

- `id` (PK)
- `org_unit_id` (FK, obrigatório) → org_units
- `type` — chip | consumable | other
- `name` (obrigatório)
- `sku`
- `location`
- `min_stock` (obrigatório)
- `current_stock` (obrigatório)
- `unit` (un, cx, pct)
- `notes`
- `created_at`, `updated_at`

**Telas**:
- Lista (filtros: unidade, tipo, estoque baixo)
- Cadastro/edição

---

### 12. **stock_movements** (Movimentação de Estoque)
**Objetivo**: Registrar entradas/saídas

- `id` (PK)
- `resource_id` (FK, obrigatório) → resources
- `org_unit_id` (FK, obrigatório) → org_units
- `movement_type` — in | out
- `quantity` (obrigatório) — constraint > 0
- `movement_date` (obrigatório)
- `reference` (OS/chamado/projeto)
- `requested_by`
- `notes`
- `created_at`

**Telas**:
- Lista por recurso (extrato)
- Lançar entrada/saída

---

### 13. **activity_log** (Log de Atividades)
**Objetivo**: Auditoria de alterações

- `id` (PK)
- `user_id` (FK) → users
- `org_unit_id` (FK) → org_units
- `table_name`
- `record_id`
- `action` — insert | update | delete
- `changes` (JSON)
- `ip_address`
- `created_at`

**Uso**: Auditoria automática de alterações

---

## 🔧 RECURSOS ADICIONAIS

### Índices (35 índices criados)
- Performance otimizada para todas as consultas
- Índices em FKs, campos de filtro e ordenação

### Triggers (9 triggers)
- `updated_at` atualizado automaticamente
- Para todas as tabelas que precisam

### Constraints (4 validações)
- `min_warn_percent <= min_good_percent`
- `progress` entre 0 e 100
- `satisfaction` entre 1 e 5
- `quantity` de movimentação > 0

---

## 🔌 API ENDPOINTS

### Unidades
- `GET /api/units` - Listar todas ativas
- `GET /api/units/:id` - Buscar por ID

### Categorias
- `GET /api/categories` - Listar todas ativas (ordenadas)
- `GET /api/categories/:id` - Buscar por ID

### Indicadores
- `GET /api/indicators` - Listar com filtros (org_unit_id, category_id, status)
- `GET /api/indicators/:id` - Detalhes + histórico
- `POST /api/indicators/:id/update` - Atualizar valor (calcula % e status)

### Dashboard
- `GET /api/dashboard/summary` - Resumo (com filtro por unidade)

### Chamados
- `GET /api/tickets` - Listar com filtros (org_unit_id, status, priority)

### Projetos
- `GET /api/projects` - Listar com filtros (org_unit_id, status)

### Ativos
- `GET /api/assets` - Listar com filtros (org_unit_id, type, status)

### Backups
- `GET /api/backups` - Listar com filtro (org_unit_id)

### Links de Rede
- `GET /api/network-links` - Listar com filtros (org_unit_id, status, type)

### Recursos
- `GET /api/resources` - Listar com filtros (org_unit_id, type, low_stock)

### Movimentações
- `GET /api/stock-movements` - Listar com filtros (resource_id, org_unit_id, type)

### Usuários (Admin)
- `GET /api/users` - Listar todos

**Total**: 15 endpoints REST

---

## 📦 DADOS DE EXEMPLO

O arquivo `seed.sql` cria:
- ✅ **4 Unidades**: WAY262, WAY153, WAY364, WAYHO
- ✅ **5 Usuários**: 1 admin, 1 manager, 2 editors, 1 viewer
- ✅ **8 Categorias**: Todas as 8 categorias especificadas
- ✅ **25 Indicadores**: Distribuídos nas categorias
- ✅ **18 Históricos**: Últimos 6 meses de 3 indicadores
- ✅ **8 Ativos**: Hardware, software, licenças
- ✅ **5 Chamados**: Diferentes status
- ✅ **4 Projetos**: Em diferentes fases
- ✅ **5 Backups**: Registros recentes
- ✅ **5 Links de Rede**: Diferentes tipos
- ✅ **5 Recursos**: Chips e consumíveis
- ✅ **6 Movimentações**: Entradas e saídas

---

## 🎯 PRÓXIMOS PASSOS

### 1. Você Faz (na sua máquina):

```bash
# 1. Baixar e extrair
tar -xzf webapp-api-completo.tar.gz
cd webapp-api

# 2. Instalar dependências
npm install

# 3. Executar schema no SQL Server
# Abra o SSMS, conecte ao servidor 192.168.100.14
# Selecione banco ABOT
# Execute schema.sql

# 4. Executar seed (dados de exemplo)
# Execute seed.sql no SSMS

# 5. Testar conexão
node test-connection.js

# 6. Iniciar API
npm start
```

### 2. Resultado Esperado:

```
============================================================================
🚀 API Portal de Indicadores - Way Brasil
============================================================================
🔗 Porta: 3001
🏥 Health check: http://localhost:3001/health
📊 Endpoints: http://localhost:3001/api/

📌 Endpoints disponíveis:
   • GET  /api/units                - Unidades
   • GET  /api/categories           - Categorias
   • GET  /api/indicators           - Indicadores (com filtros)
   • GET  /api/indicators/:id       - Detalhes + histórico
   • POST /api/indicators/:id/update - Atualizar valor
   • GET  /api/dashboard/summary    - Resumo dashboard
   • GET  /api/tickets              - Chamados
   • GET  /api/projects             - Projetos
   • GET  /api/assets               - Ativos de TI
   • GET  /api/backups              - Backups
   • GET  /api/network-links        - Links de rede
   • GET  /api/resources            - Recursos/Estoque
   • GET  /api/stock-movements      - Movimentações
   • GET  /api/users                - Usuários

🔐 Autenticação: Header "X-API-Key: webapp-api-key-2024-secure-change-in-production"
============================================================================
```

### 3. Testar Endpoints:

```bash
# Health check
curl http://localhost:3001/health

# Unidades
curl -H "X-API-Key: webapp-api-key-2024-secure-change-in-production" \
     http://localhost:3001/api/units

# Categorias
curl -H "X-API-Key: webapp-api-key-2024-secure-change-in-production" \
     http://localhost:3001/api/categories

# Indicadores (todos)
curl -H "X-API-Key: webapp-api-key-2024-secure-change-in-production" \
     http://localhost:3001/api/indicators

# Indicadores (filtrado por unidade WAY262 = id 1)
curl -H "X-API-Key: webapp-api-key-2024-secure-change-in-production" \
     http://localhost:3001/api/indicators?org_unit_id=1

# Dashboard (resumo geral)
curl -H "X-API-Key: webapp-api-key-2024-secure-change-in-production" \
     http://localhost:3001/api/dashboard/summary

# Dashboard (filtrado por unidade)
curl -H "X-API-Key: webapp-api-key-2024-secure-change-in-production" \
     http://localhost:3001/api/dashboard/summary?org_unit_id=1
```

---

## 📁 ARQUIVOS ATUALIZADOS

```
webapp-api/
├── schema.sql          ✅ ATUALIZADO (23 KB)
│   • 13 tabelas com org_units
│   • 35 índices
│   • 9 triggers
│   • 4 constraints
│
├── seed.sql            ✅ NOVO (18 KB)
│   • 4 unidades
│   • 25 indicadores
│   • Dados completos
│
├── server.js           ✅ ATUALIZADO (18 KB)
│   • 15 endpoints
│   • Filtro por org_unit_id
│   • Joins com unidades
│
├── .env                ✅ Suas credenciais
└── [docs]              ✅ Documentação completa
```

---

## 📥 DOWNLOAD

**Arquivo**: `webapp-api-completo.tar.gz` (54 KB)
**Localização**: `/home/user/webapp-api-completo.tar.gz`

**Contém**:
- ✅ Schema completo (13 tabelas)
- ✅ Seed com dados de exemplo
- ✅ API com 15 endpoints
- ✅ Suas credenciais configuradas
- ✅ Documentação completa

---

## 🎉 RESUMO FINAL

| Item | Status | Descrição |
|------|--------|-----------|
| 📊 Schema | ✅ 100% | 13 tabelas + org_units |
| 🔗 Relacionamentos | ✅ 100% | Todas FKs configuradas |
| 📝 Constraints | ✅ 100% | 4 validações de negócio |
| 🔧 Triggers | ✅ 100% | 9 triggers para updated_at |
| 📈 Índices | ✅ 100% | 35 índices de performance |
| 🔌 API | ✅ 100% | 15 endpoints REST |
| 📦 Dados | ✅ 100% | Seed completo |
| 📚 Docs | ✅ 100% | 5 documentos |
| ⚙️ Config | ✅ 100% | Credenciais configuradas |

---

## ✨ PRÓXIMO PASSO: EXECUTAR NA SUA MÁQUINA

1. Baixe o arquivo `webapp-api-completo.tar.gz`
2. Extraia na sua máquina
3. Execute `npm install`
4. Execute `schema.sql` no SSMS (banco ABOT)
5. Execute `seed.sql` no SSMS
6. Execute `node test-connection.js`
7. Execute `npm start`

**Pronto! API rodando e conectada ao SQL Server! 🚀**

---

**Alguma dúvida ou ajuste necessário?**
