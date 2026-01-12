-- ============================================================================
-- PORTAL DE INDICADORES - WAY BRASIL
-- Schema SQL Server - Versão Completa com Unidades
-- ============================================================================
-- Banco: ABOT
-- Servidor: 192.168.100.14
-- Criado: 2024-01-12
-- ============================================================================

-- ============================================================================
-- 1) UNIDADES ORGANIZACIONAIS (org_units)
-- Objetivo: Filtro global obrigatório para todo o portal
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='org_units' AND xtype='U')
CREATE TABLE org_units (
  id INT PRIMARY KEY IDENTITY(1,1),
  code NVARCHAR(50) NOT NULL UNIQUE,              -- Ex.: WAY262, WAY153
  name NVARCHAR(255) NOT NULL UNIQUE,             -- Ex.: Way 262, Way 153
  description NVARCHAR(MAX),
  is_active BIT NOT NULL DEFAULT 1,
  created_at DATETIME DEFAULT GETDATE(),
  updated_at DATETIME DEFAULT GETDATE()
);

-- ============================================================================
-- 2) USUÁRIOS (users)
-- Objetivo: Autenticação, perfis e auditoria
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='users' AND xtype='U')
CREATE TABLE users (
  id INT PRIMARY KEY IDENTITY(1,1),
  name NVARCHAR(255) NOT NULL,
  email NVARCHAR(255) UNIQUE,
  role NVARCHAR(20) NOT NULL DEFAULT 'viewer',    -- admin | manager | editor | viewer
  password_hash NVARCHAR(500),                    -- bcrypt hash
  is_active BIT NOT NULL DEFAULT 1,
  created_at DATETIME DEFAULT GETDATE(),
  updated_at DATETIME DEFAULT GETDATE(),
  last_login DATETIME
);

-- ============================================================================
-- 3) CATEGORIAS DE INDICADORES (categories)
-- Objetivo: Agrupar indicadores nas 8 categorias (Inventário, Chamados, etc.)
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='categories' AND xtype='U')
CREATE TABLE categories (
  id INT PRIMARY KEY IDENTITY(1,1),
  name NVARCHAR(255) NOT NULL UNIQUE,             -- Ex.: "Gestão de Chamados"
  description NVARCHAR(MAX),
  icon NVARCHAR(50),                              -- Nome do ícone Font Awesome
  color NVARCHAR(20),                             -- Ex.: "#3b82f6"
  sort_order INT NOT NULL DEFAULT 0,              -- Ordem de exibição
  is_active BIT NOT NULL DEFAULT 1,
  created_at DATETIME DEFAULT GETDATE(),
  updated_at DATETIME DEFAULT GETDATE()
);

-- ============================================================================
-- 4) INDICADORES (indicators)
-- Objetivo: Catálogo do indicador + valor atual para dashboard
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='indicators' AND xtype='U')
CREATE TABLE indicators (
  id INT PRIMARY KEY IDENTITY(1,1),
  org_unit_id INT NOT NULL,                       -- OBRIGATÓRIO: Unidade do indicador
  category_id INT NOT NULL,                       -- OBRIGATÓRIO: Categoria
  name NVARCHAR(255) NOT NULL,                    -- Nome do KPI
  description NVARCHAR(MAX),
  unit NVARCHAR(50),                              -- "%", "qtd", "horas", "R$"
  target_value DECIMAL(18,2),                     -- Meta numérica
  min_good_percent DECIMAL(5,2) NOT NULL DEFAULT 90,  -- Verde >= 90%
  min_warn_percent DECIMAL(5,2) NOT NULL DEFAULT 70,  -- Amarelo >= 70%
  status NVARCHAR(20) NOT NULL DEFAULT 'warning', -- success | warning | critical
  current_value DECIMAL(18,2),                    -- Último valor lançado
  current_percent DECIMAL(5,2),                   -- Atingimento atual
  last_updated_at DATETIME,                       -- Última atualização
  owner_user_id INT,                              -- Responsável pelo indicador
  is_active BIT NOT NULL DEFAULT 1,
  created_at DATETIME DEFAULT GETDATE(),
  updated_at DATETIME DEFAULT GETDATE(),
  
  FOREIGN KEY (org_unit_id) REFERENCES org_units(id),
  FOREIGN KEY (category_id) REFERENCES categories(id),
  FOREIGN KEY (owner_user_id) REFERENCES users(id)
);

-- ============================================================================
-- 5) HISTÓRICO DE INDICADORES (indicator_history)
-- Objetivo: Timeline para gráficos e auditoria
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='indicator_history' AND xtype='U')
CREATE TABLE indicator_history (
  id INT PRIMARY KEY IDENTITY(1,1),
  indicator_id INT NOT NULL,                      -- OBRIGATÓRIO: Indicador
  org_unit_id INT NOT NULL,                       -- OBRIGATÓRIO: Unidade (herda do indicador)
  ref_date DATE NOT NULL,                         -- Data de referência (mês/dia)
  value DECIMAL(18,2) NOT NULL,                   -- Valor do período
  target_value DECIMAL(18,2),                     -- Snapshot da meta no momento
  percent_value DECIMAL(5,2),                     -- Atingimento do período
  status NVARCHAR(20) NOT NULL DEFAULT 'warning', -- success | warning | critical
  note NVARCHAR(MAX),                             -- Observação do lançamento
  created_by INT,                                 -- Quem lançou
  created_at DATETIME DEFAULT GETDATE(),
  
  FOREIGN KEY (indicator_id) REFERENCES indicators(id),
  FOREIGN KEY (org_unit_id) REFERENCES org_units(id),
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- ============================================================================
-- 6) ATIVOS DE TI (it_assets)
-- Objetivo: Inventário de hardware, software e licenças
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='it_assets' AND xtype='U')
CREATE TABLE it_assets (
  id INT PRIMARY KEY IDENTITY(1,1),
  org_unit_id INT NOT NULL,                       -- OBRIGATÓRIO: Unidade
  type NVARCHAR(50) NOT NULL,                     -- hardware | software | license
  name NVARCHAR(255) NOT NULL,                    -- Nome do ativo
  serial NVARCHAR(100),                           -- Número de série
  brand NVARCHAR(100),                            -- Marca
  model NVARCHAR(100),                            -- Modelo
  status NVARCHAR(20) NOT NULL DEFAULT 'active',  -- active | maintenance | discarded
  location NVARCHAR(255),                         -- Localização física
  responsible NVARCHAR(255),                      -- Responsável
  acquisition_date DATE,                          -- Data de aquisição
  notes NVARCHAR(MAX),                            -- Observações
  created_at DATETIME DEFAULT GETDATE(),
  updated_at DATETIME DEFAULT GETDATE(),
  
  FOREIGN KEY (org_unit_id) REFERENCES org_units(id)
);

-- ============================================================================
-- 7) CHAMADOS (tickets)
-- Objetivo: Gestão de chamados (GLPI ou interno)
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='tickets' AND xtype='U')
CREATE TABLE tickets (
  id INT PRIMARY KEY IDENTITY(1,1),
  org_unit_id INT NOT NULL,                       -- OBRIGATÓRIO: Unidade
  code NVARCHAR(50),                              -- ID externo (GLPI)
  title NVARCHAR(500) NOT NULL,                   -- Título do chamado
  category NVARCHAR(100),                         -- Categoria
  priority NVARCHAR(20) NOT NULL DEFAULT 'medium',-- low | medium | high | critical
  status NVARCHAR(20) NOT NULL DEFAULT 'open',    -- open | in_progress | resolved | closed
  requester NVARCHAR(255),                        -- Solicitante
  assignee NVARCHAR(255),                         -- Responsável
  opened_at DATETIME,                             -- Data de abertura
  resolved_at DATETIME,                           -- Data de resolução
  satisfaction INT,                               -- Nota 1 a 5
  notes NVARCHAR(MAX),                            -- Observações
  created_at DATETIME DEFAULT GETDATE(),
  updated_at DATETIME DEFAULT GETDATE(),
  
  FOREIGN KEY (org_unit_id) REFERENCES org_units(id)
);

-- ============================================================================
-- 8) PROJETOS (projects)
-- Objetivo: Controle de projetos e melhorias (PMO)
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='projects' AND xtype='U')
CREATE TABLE projects (
  id INT PRIMARY KEY IDENTITY(1,1),
  org_unit_id INT NOT NULL,                       -- OBRIGATÓRIO: Unidade
  name NVARCHAR(255) NOT NULL,                    -- Nome do projeto
  description NVARCHAR(MAX),                      -- Descrição
  status NVARCHAR(20) NOT NULL DEFAULT 'planning',-- planning | in_progress | completed | paused
  progress INT NOT NULL DEFAULT 0,                -- 0 a 100
  start_date DATE,                                -- Data de início
  end_date DATE,                                  -- Data de término
  owner NVARCHAR(255),                            -- Gerente do projeto
  sponsor NVARCHAR(255),                          -- Patrocinador
  notes NVARCHAR(MAX),                            -- Observações
  created_at DATETIME DEFAULT GETDATE(),
  updated_at DATETIME DEFAULT GETDATE(),
  
  FOREIGN KEY (org_unit_id) REFERENCES org_units(id)
);

-- ============================================================================
-- 9) BACKUPS (backups)
-- Objetivo: Evidências de backup/restore e sucesso
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='backups' AND xtype='U')
CREATE TABLE backups (
  id INT PRIMARY KEY IDENTITY(1,1),
  org_unit_id INT NOT NULL,                       -- OBRIGATÓRIO: Unidade
  system_name NVARCHAR(255) NOT NULL,             -- Nome do sistema
  type NVARCHAR(50) NOT NULL,                     -- full | incremental | differential
  status NVARCHAR(20) NOT NULL,                   -- success | failed | warning
  size_mb DECIMAL(18,2),                          -- Tamanho em MB
  location NVARCHAR(500),                         -- Local do backup
  executed_at DATETIME NOT NULL,                  -- Data de execução
  restore_tested BIT NOT NULL DEFAULT 0,          -- Teste de restore (sim/não)
  notes NVARCHAR(MAX),                            -- Observações
  created_at DATETIME DEFAULT GETDATE(),
  
  FOREIGN KEY (org_unit_id) REFERENCES org_units(id)
);

-- ============================================================================
-- 10) LINKS DE REDE (network_links)
-- Objetivo: Monitorar links e disponibilidade
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='network_links' AND xtype='U')
CREATE TABLE network_links (
  id INT PRIMARY KEY IDENTITY(1,1),
  org_unit_id INT NOT NULL,                       -- OBRIGATÓRIO: Unidade
  name NVARCHAR(255) NOT NULL,                    -- Nome do link
  type NVARCHAR(50) NOT NULL,                     -- fibra | radio | 4g | vpn
  status NVARCHAR(20) NOT NULL DEFAULT 'up',      -- up | down | degraded
  uptime_percent DECIMAL(5,2),                    -- Uptime %
  bandwidth_mbps INT,                             -- Banda em Mbps
  latency_ms INT,                                 -- Latência em ms
  provider NVARCHAR(255),                         -- Provedor
  location NVARCHAR(255),                         -- Localização
  last_check_at DATETIME,                         -- Última verificação
  notes NVARCHAR(MAX),                            -- Observações
  created_at DATETIME DEFAULT GETDATE(),
  updated_at DATETIME DEFAULT GETDATE(),
  
  FOREIGN KEY (org_unit_id) REFERENCES org_units(id)
);

-- ============================================================================
-- 11) RECURSOS / ESTOQUE (resources)
-- Objetivo: Itens controlados (chips M2M, consumíveis)
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='resources' AND xtype='U')
CREATE TABLE resources (
  id INT PRIMARY KEY IDENTITY(1,1),
  org_unit_id INT NOT NULL,                       -- OBRIGATÓRIO: Unidade
  type NVARCHAR(50) NOT NULL,                     -- chip | consumable | other
  name NVARCHAR(255) NOT NULL,                    -- Nome do recurso
  sku NVARCHAR(100),                              -- Código SKU
  location NVARCHAR(255),                         -- Localização
  min_stock INT NOT NULL DEFAULT 0,               -- Estoque mínimo
  current_stock INT NOT NULL DEFAULT 0,           -- Estoque atual
  unit NVARCHAR(20),                              -- "un", "cx", "pct"
  notes NVARCHAR(MAX),                            -- Observações
  created_at DATETIME DEFAULT GETDATE(),
  updated_at DATETIME DEFAULT GETDATE(),
  
  FOREIGN KEY (org_unit_id) REFERENCES org_units(id)
);

-- ============================================================================
-- 12) MOVIMENTAÇÃO DE ESTOQUE (stock_movements)
-- Objetivo: Registrar entradas/saídas e histórico do saldo
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='stock_movements' AND xtype='U')
CREATE TABLE stock_movements (
  id INT PRIMARY KEY IDENTITY(1,1),
  resource_id INT NOT NULL,                       -- OBRIGATÓRIO: Recurso
  org_unit_id INT NOT NULL,                       -- OBRIGATÓRIO: Unidade
  movement_type NVARCHAR(10) NOT NULL,            -- in | out
  quantity INT NOT NULL,                          -- Quantidade
  movement_date DATE NOT NULL,                    -- Data da movimentação
  reference NVARCHAR(255),                        -- OS/Chamado/Projeto
  requested_by NVARCHAR(255),                     -- Solicitante
  notes NVARCHAR(MAX),                            -- Observações
  created_at DATETIME DEFAULT GETDATE(),
  
  FOREIGN KEY (resource_id) REFERENCES resources(id),
  FOREIGN KEY (org_unit_id) REFERENCES org_units(id)
);

-- ============================================================================
-- 13) LOG DE ATIVIDADES (activity_log)
-- Objetivo: Auditoria de alterações (quem fez o quê e quando)
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='activity_log' AND xtype='U')
CREATE TABLE activity_log (
  id INT PRIMARY KEY IDENTITY(1,1),
  user_id INT,                                    -- Quem fez
  org_unit_id INT,                                -- Unidade relacionada
  table_name NVARCHAR(100) NOT NULL,              -- Tabela afetada
  record_id INT,                                  -- ID do registro
  action NVARCHAR(20) NOT NULL,                   -- insert | update | delete
  changes NVARCHAR(MAX),                          -- JSON com alterações
  ip_address NVARCHAR(50),                        -- IP do usuário
  created_at DATETIME DEFAULT GETDATE(),
  
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (org_unit_id) REFERENCES org_units(id)
);

-- ============================================================================
-- ÍNDICES PARA PERFORMANCE
-- ============================================================================

-- Unidades
CREATE NONCLUSTERED INDEX idx_org_units_code ON org_units(code);
CREATE NONCLUSTERED INDEX idx_org_units_active ON org_units(is_active);

-- Usuários
CREATE NONCLUSTERED INDEX idx_users_email ON users(email);
CREATE NONCLUSTERED INDEX idx_users_role ON users(role);
CREATE NONCLUSTERED INDEX idx_users_active ON users(is_active);

-- Categorias
CREATE NONCLUSTERED INDEX idx_categories_order ON categories(sort_order);
CREATE NONCLUSTERED INDEX idx_categories_active ON categories(is_active);

-- Indicadores
CREATE NONCLUSTERED INDEX idx_indicators_org_unit ON indicators(org_unit_id);
CREATE NONCLUSTERED INDEX idx_indicators_category ON indicators(category_id);
CREATE NONCLUSTERED INDEX idx_indicators_status ON indicators(status);
CREATE NONCLUSTERED INDEX idx_indicators_active ON indicators(is_active);

-- Histórico de Indicadores
CREATE NONCLUSTERED INDEX idx_indicator_history_indicator ON indicator_history(indicator_id);
CREATE NONCLUSTERED INDEX idx_indicator_history_org_unit ON indicator_history(org_unit_id);
CREATE NONCLUSTERED INDEX idx_indicator_history_date ON indicator_history(ref_date);

-- Ativos de TI
CREATE NONCLUSTERED INDEX idx_it_assets_org_unit ON it_assets(org_unit_id);
CREATE NONCLUSTERED INDEX idx_it_assets_type ON it_assets(type);
CREATE NONCLUSTERED INDEX idx_it_assets_status ON it_assets(status);

-- Chamados
CREATE NONCLUSTERED INDEX idx_tickets_org_unit ON tickets(org_unit_id);
CREATE NONCLUSTERED INDEX idx_tickets_status ON tickets(status);
CREATE NONCLUSTERED INDEX idx_tickets_priority ON tickets(priority);
CREATE NONCLUSTERED INDEX idx_tickets_code ON tickets(code);

-- Projetos
CREATE NONCLUSTERED INDEX idx_projects_org_unit ON projects(org_unit_id);
CREATE NONCLUSTERED INDEX idx_projects_status ON projects(status);

-- Backups
CREATE NONCLUSTERED INDEX idx_backups_org_unit ON backups(org_unit_id);
CREATE NONCLUSTERED INDEX idx_backups_executed ON backups(executed_at);
CREATE NONCLUSTERED INDEX idx_backups_status ON backups(status);

-- Links de Rede
CREATE NONCLUSTERED INDEX idx_network_links_org_unit ON network_links(org_unit_id);
CREATE NONCLUSTERED INDEX idx_network_links_status ON network_links(status);
CREATE NONCLUSTERED INDEX idx_network_links_type ON network_links(type);

-- Recursos
CREATE NONCLUSTERED INDEX idx_resources_org_unit ON resources(org_unit_id);
CREATE NONCLUSTERED INDEX idx_resources_type ON resources(type);
CREATE NONCLUSTERED INDEX idx_resources_low_stock ON resources(current_stock, min_stock);

-- Movimentação de Estoque
CREATE NONCLUSTERED INDEX idx_stock_movements_resource ON stock_movements(resource_id);
CREATE NONCLUSTERED INDEX idx_stock_movements_org_unit ON stock_movements(org_unit_id);
CREATE NONCLUSTERED INDEX idx_stock_movements_date ON stock_movements(movement_date);

-- Log de Atividades
CREATE NONCLUSTERED INDEX idx_activity_log_user ON activity_log(user_id);
CREATE NONCLUSTERED INDEX idx_activity_log_table ON activity_log(table_name, record_id);
CREATE NONCLUSTERED INDEX idx_activity_log_created ON activity_log(created_at);

-- ============================================================================
-- TRIGGERS PARA UPDATED_AT AUTOMÁTICO
-- ============================================================================

-- Trigger para org_units
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_org_units_updated')
EXEC('
CREATE TRIGGER trg_org_units_updated ON org_units
AFTER UPDATE AS
BEGIN
  UPDATE org_units SET updated_at = GETDATE()
  WHERE id IN (SELECT DISTINCT id FROM inserted)
END
');

-- Trigger para users
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_users_updated')
EXEC('
CREATE TRIGGER trg_users_updated ON users
AFTER UPDATE AS
BEGIN
  UPDATE users SET updated_at = GETDATE()
  WHERE id IN (SELECT DISTINCT id FROM inserted)
END
');

-- Trigger para categories
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_categories_updated')
EXEC('
CREATE TRIGGER trg_categories_updated ON categories
AFTER UPDATE AS
BEGIN
  UPDATE categories SET updated_at = GETDATE()
  WHERE id IN (SELECT DISTINCT id FROM inserted)
END
');

-- Trigger para indicators
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_indicators_updated')
EXEC('
CREATE TRIGGER trg_indicators_updated ON indicators
AFTER UPDATE AS
BEGIN
  UPDATE indicators SET updated_at = GETDATE()
  WHERE id IN (SELECT DISTINCT id FROM inserted)
END
');

-- Trigger para it_assets
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_it_assets_updated')
EXEC('
CREATE TRIGGER trg_it_assets_updated ON it_assets
AFTER UPDATE AS
BEGIN
  UPDATE it_assets SET updated_at = GETDATE()
  WHERE id IN (SELECT DISTINCT id FROM inserted)
END
');

-- Trigger para tickets
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_tickets_updated')
EXEC('
CREATE TRIGGER trg_tickets_updated ON tickets
AFTER UPDATE AS
BEGIN
  UPDATE tickets SET updated_at = GETDATE()
  WHERE id IN (SELECT DISTINCT id FROM inserted)
END
');

-- Trigger para projects
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_projects_updated')
EXEC('
CREATE TRIGGER trg_projects_updated ON projects
AFTER UPDATE AS
BEGIN
  UPDATE projects SET updated_at = GETDATE()
  WHERE id IN (SELECT DISTINCT id FROM inserted)
END
');

-- Trigger para network_links
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_network_links_updated')
EXEC('
CREATE TRIGGER trg_network_links_updated ON network_links
AFTER UPDATE AS
BEGIN
  UPDATE network_links SET updated_at = GETDATE()
  WHERE id IN (SELECT DISTINCT id FROM inserted)
END
');

-- Trigger para resources
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_resources_updated')
EXEC('
CREATE TRIGGER trg_resources_updated ON resources
AFTER UPDATE AS
BEGIN
  UPDATE resources SET updated_at = GETDATE()
  WHERE id IN (SELECT DISTINCT id FROM inserted)
END
');

-- ============================================================================
-- VALIDAÇÕES E CONSTRAINTS
-- ============================================================================

-- Garantir que min_warn_percent <= min_good_percent
ALTER TABLE indicators ADD CONSTRAINT chk_indicators_percent_range 
  CHECK (min_warn_percent <= min_good_percent);

-- Garantir que progress está entre 0 e 100
ALTER TABLE projects ADD CONSTRAINT chk_projects_progress_range 
  CHECK (progress >= 0 AND progress <= 100);

-- Garantir que satisfaction está entre 1 e 5
ALTER TABLE tickets ADD CONSTRAINT chk_tickets_satisfaction_range 
  CHECK (satisfaction IS NULL OR (satisfaction >= 1 AND satisfaction <= 5));

-- Garantir que quantity de movimentação é positiva
ALTER TABLE stock_movements ADD CONSTRAINT chk_stock_movements_quantity 
  CHECK (quantity > 0);

PRINT '';
PRINT '============================================================================';
PRINT 'SCHEMA CRIADO COM SUCESSO!';
PRINT '============================================================================';
PRINT 'Tabelas criadas:';
PRINT '  1) org_units (Unidades Organizacionais)';
PRINT '  2) users (Usuários)';
PRINT '  3) categories (Categorias de Indicadores)';
PRINT '  4) indicators (Indicadores)';
PRINT '  5) indicator_history (Histórico de Indicadores)';
PRINT '  6) it_assets (Ativos de TI)';
PRINT '  7) tickets (Chamados)';
PRINT '  8) projects (Projetos)';
PRINT '  9) backups (Backups)';
PRINT ' 10) network_links (Links de Rede)';
PRINT ' 11) resources (Recursos/Estoque)';
PRINT ' 12) stock_movements (Movimentação de Estoque)';
PRINT ' 13) activity_log (Log de Atividades)';
PRINT '';
PRINT 'Índices criados: 35';
PRINT 'Triggers criados: 9 (para updated_at automático)';
PRINT 'Constraints criados: 4 (validações de negócio)';
PRINT '';
PRINT 'Próximo passo: Executar seed.sql para dados de exemplo';
PRINT '============================================================================';
