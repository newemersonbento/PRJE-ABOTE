-- Script SQL para criar as tabelas no SQL Server
-- Execute este script no seu banco de dados

-- Tabela de Categorias
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='categories' AND xtype='U')
CREATE TABLE categories (
  id INT PRIMARY KEY IDENTITY(1,1),
  name NVARCHAR(255) NOT NULL,
  description NVARCHAR(MAX),
  icon NVARCHAR(50),
  color NVARCHAR(20),
  created_at DATETIME DEFAULT GETDATE()
);

-- Tabela de Indicadores
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='indicators' AND xtype='U')
CREATE TABLE indicators (
  id INT PRIMARY KEY IDENTITY(1,1),
  category_id INT NOT NULL,
  name NVARCHAR(255) NOT NULL,
  description NVARCHAR(MAX),
  unit NVARCHAR(50),
  target_value DECIMAL(18,2),
  current_value DECIMAL(18,2),
  status NVARCHAR(20) DEFAULT 'active',
  frequency NVARCHAR(20) DEFAULT 'monthly',
  last_updated DATETIME DEFAULT GETDATE(),
  created_at DATETIME DEFAULT GETDATE(),
  FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- Tabela de Histórico de Indicadores
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='indicator_history' AND xtype='U')
CREATE TABLE indicator_history (
  id INT PRIMARY KEY IDENTITY(1,1),
  indicator_id INT NOT NULL,
  value DECIMAL(18,2) NOT NULL,
  period_date DATE NOT NULL,
  notes NVARCHAR(MAX),
  created_by NVARCHAR(100),
  created_at DATETIME DEFAULT GETDATE(),
  FOREIGN KEY (indicator_id) REFERENCES indicators(id)
);

-- Tabela de Ativos de TI
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='it_assets' AND xtype='U')
CREATE TABLE it_assets (
  id INT PRIMARY KEY IDENTITY(1,1),
  asset_type NVARCHAR(50) NOT NULL,
  name NVARCHAR(255) NOT NULL,
  description NVARCHAR(MAX),
  serial_number NVARCHAR(100),
  location NVARCHAR(255),
  status NVARCHAR(20) DEFAULT 'active',
  purchase_date DATE,
  warranty_expiry DATE,
  responsible_person NVARCHAR(100),
  created_at DATETIME DEFAULT GETDATE(),
  updated_at DATETIME DEFAULT GETDATE()
);

-- Tabela de Chamados
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='tickets' AND xtype='U')
CREATE TABLE tickets (
  id INT PRIMARY KEY IDENTITY(1,1),
  ticket_number NVARCHAR(50) UNIQUE NOT NULL,
  category NVARCHAR(100) NOT NULL,
  title NVARCHAR(255) NOT NULL,
  description NVARCHAR(MAX),
  priority NVARCHAR(20) DEFAULT 'medium',
  status NVARCHAR(20) DEFAULT 'open',
  requester_name NVARCHAR(100),
  requester_email NVARCHAR(100),
  assigned_to NVARCHAR(100),
  created_at DATETIME DEFAULT GETDATE(),
  updated_at DATETIME DEFAULT GETDATE(),
  resolved_at DATETIME,
  closed_at DATETIME
);

-- Tabela de Projetos
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='projects' AND xtype='U')
CREATE TABLE projects (
  id INT PRIMARY KEY IDENTITY(1,1),
  name NVARCHAR(255) NOT NULL,
  description NVARCHAR(MAX),
  status NVARCHAR(20) DEFAULT 'planning',
  start_date DATE,
  end_date DATE,
  progress_percentage INT DEFAULT 0,
  responsible_person NVARCHAR(100),
  created_at DATETIME DEFAULT GETDATE(),
  updated_at DATETIME DEFAULT GETDATE()
);

-- Tabela de Backups
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='backups' AND xtype='U')
CREATE TABLE backups (
  id INT PRIMARY KEY IDENTITY(1,1),
  system_name NVARCHAR(255) NOT NULL,
  backup_type NVARCHAR(50) NOT NULL,
  status NVARCHAR(20) NOT NULL,
  backup_date DATETIME NOT NULL,
  size_mb DECIMAL(18,2),
  location NVARCHAR(500),
  notes NVARCHAR(MAX),
  created_at DATETIME DEFAULT GETDATE()
);

-- Tabela de Links de Rede
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='network_links' AND xtype='U')
CREATE TABLE network_links (
  id INT PRIMARY KEY IDENTITY(1,1),
  link_name NVARCHAR(255) NOT NULL,
  link_type NVARCHAR(50) NOT NULL,
  location NVARCHAR(255),
  status NVARCHAR(20) DEFAULT 'active',
  bandwidth_mbps INT,
  latency_ms INT,
  uptime_percentage DECIMAL(5,2),
  last_check DATETIME,
  created_at DATETIME DEFAULT GETDATE()
);

-- Tabela de Recursos
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='resources' AND xtype='U')
CREATE TABLE resources (
  id INT PRIMARY KEY IDENTITY(1,1),
  resource_type NVARCHAR(50) NOT NULL,
  name NVARCHAR(255) NOT NULL,
  quantity INT DEFAULT 0,
  unit NVARCHAR(20),
  location NVARCHAR(255),
  min_stock INT,
  created_at DATETIME DEFAULT GETDATE(),
  updated_at DATETIME DEFAULT GETDATE()
);

-- Tabela de Movimentação de Estoque
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='stock_movements' AND xtype='U')
CREATE TABLE stock_movements (
  id INT PRIMARY KEY IDENTITY(1,1),
  resource_id INT NOT NULL,
  movement_type NVARCHAR(10) NOT NULL,
  quantity INT NOT NULL,
  reason NVARCHAR(MAX),
  responsible_person NVARCHAR(100),
  movement_date DATETIME DEFAULT GETDATE(),
  created_at DATETIME DEFAULT GETDATE(),
  FOREIGN KEY (resource_id) REFERENCES resources(id)
);

-- Tabela de Usuários
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='users' AND xtype='U')
CREATE TABLE users (
  id INT PRIMARY KEY IDENTITY(1,1),
  username NVARCHAR(100) UNIQUE NOT NULL,
  email NVARCHAR(100) UNIQUE NOT NULL,
  full_name NVARCHAR(255) NOT NULL,
  role NVARCHAR(20) DEFAULT 'viewer',
  password_hash NVARCHAR(255) NOT NULL,
  active BIT DEFAULT 1,
  created_at DATETIME DEFAULT GETDATE(),
  last_login DATETIME
);

-- Índices
CREATE NONCLUSTERED INDEX idx_indicators_category ON indicators(category_id);
CREATE NONCLUSTERED INDEX idx_indicator_history_indicator ON indicator_history(indicator_id);
CREATE NONCLUSTERED INDEX idx_indicator_history_date ON indicator_history(period_date);
CREATE NONCLUSTERED INDEX idx_tickets_status ON tickets(status);
CREATE NONCLUSTERED INDEX idx_projects_status ON projects(status);
CREATE NONCLUSTERED INDEX idx_assets_status ON it_assets(status);
CREATE NONCLUSTERED INDEX idx_users_email ON users(email);

PRINT 'Tabelas criadas com sucesso!';
