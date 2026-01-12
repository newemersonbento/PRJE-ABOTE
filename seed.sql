-- ============================================================================
-- DADOS DE EXEMPLO - PORTAL DE INDICADORES WAY BRASIL
-- ============================================================================
-- Este script popula o banco com dados de exemplo para teste
-- Execute após o schema.sql
-- ============================================================================

-- ============================================================================
-- 1) UNIDADES (org_units)
-- ============================================================================
SET IDENTITY_INSERT org_units ON;

INSERT INTO org_units (id, code, name, description, is_active, created_at) VALUES
(1, 'WAY262', 'Way 262', 'Unidade Way 262 - São Paulo', 1, GETDATE()),
(2, 'WAY153', 'Way 153', 'Unidade Way 153 - Rio de Janeiro', 1, GETDATE()),
(3, 'WAY364', 'Way 364', 'Unidade Way 364 - Minas Gerais', 1, GETDATE()),
(4, 'WAYHO', 'Way Head Office', 'Sede Administrativa', 1, GETDATE());

SET IDENTITY_INSERT org_units OFF;

PRINT '✓ 4 Unidades criadas';

-- ============================================================================
-- 2) USUÁRIOS (users)
-- ============================================================================
SET IDENTITY_INSERT users ON;

INSERT INTO users (id, name, email, role, is_active, created_at) VALUES
(1, 'Administrador', 'admin@waybrasil.com.br', 'admin', 1, GETDATE()),
(2, 'Gerente TI', 'gerente.ti@waybrasil.com.br', 'manager', 1, GETDATE()),
(3, 'Analista TI', 'analista.ti@waybrasil.com.br', 'editor', 1, GETDATE()),
(4, 'Coordenador', 'coordenador@waybrasil.com.br', 'editor', 1, GETDATE()),
(5, 'Visualizador', 'visualizador@waybrasil.com.br', 'viewer', 1, GETDATE());

SET IDENTITY_INSERT users OFF;

PRINT '✓ 5 Usuários criados';

-- ============================================================================
-- 3) CATEGORIAS (categories)
-- ============================================================================
SET IDENTITY_INSERT categories ON;

INSERT INTO categories (id, name, description, icon, color, sort_order, is_active) VALUES
(1, 'Inventário e Controle de Ativos', 'Gestão de equipamentos e ativos de TI', 'fa-boxes', '#3b82f6', 1, 1),
(2, 'Gestão de Chamados e Service Desk', 'Atendimento e suporte técnico', 'fa-headset', '#10b981', 2, 1),
(3, 'Segurança da Informação', 'Backups, antivírus, firewall e controles de acesso', 'fa-shield', '#ef4444', 3, 1),
(4, 'Indicadores e Controles de Gestão', 'KPIs de qualidade e controles operacionais', 'fa-chart-line', '#f59e0b', 4, 1),
(5, 'Monitoramento de Sistemas', 'Disponibilidade, performance e versões', 'fa-server', '#8b5cf6', 5, 1),
(6, 'Projetos e Melhorias', 'PMO e projetos em andamento', 'fa-tasks', '#ec4899', 6, 1),
(7, 'Gestão de Recursos', 'Chips, consumíveis e estoque', 'fa-warehouse', '#06b6d4', 7, 1),
(8, 'Corporativo e ERP', 'Sistemas corporativos e integrações', 'fa-building', '#6366f1', 8, 1);

SET IDENTITY_INSERT categories OFF;

PRINT '✓ 8 Categorias criadas';

-- ============================================================================
-- 4) INDICADORES (indicators)
-- ============================================================================
SET IDENTITY_INSERT indicators ON;

-- Categoria 1: Inventário
INSERT INTO indicators (id, org_unit_id, category_id, name, description, unit, target_value, current_value, min_good_percent, min_warn_percent, status, owner_user_id, is_active) VALUES
(1, 1, 1, 'Inventário Atualizado', 'Percentual de ativos inventariados', '%', 100, 95, 95, 85, 'success', 3, 1),
(2, 1, 1, 'Ativos em Manutenção', 'Quantidade de ativos em manutenção', 'qtd', 5, 3, 90, 70, 'success', 3, 1),
(3, 1, 1, 'Taxa de Descarte Controlado', 'Descarte com documentação completa', '%', 100, 88, 95, 85, 'warning', 3, 1);

-- Categoria 2: Chamados
INSERT INTO indicators (id, org_unit_id, category_id, name, description, unit, target_value, current_value, min_good_percent, min_warn_percent, status, owner_user_id, is_active) VALUES
(4, 1, 2, 'SLA de Atendimento', 'Chamados atendidos dentro do SLA', '%', 95, 92, 95, 85, 'warning', 2, 1),
(5, 1, 2, 'Tempo Médio de Resolução', 'Tempo médio para resolver chamados', 'horas', 4, 3.5, 90, 70, 'success', 2, 1),
(6, 1, 2, 'Satisfação do Usuário', 'Nota média de satisfação', 'nota', 4.5, 4.2, 90, 75, 'warning', 2, 1),
(7, 1, 2, 'Taxa de Reincidência', 'Chamados reabertos', '%', 5, 7, 90, 70, 'warning', 2, 1);

-- Categoria 3: Segurança
INSERT INTO indicators (id, org_unit_id, category_id, name, description, unit, target_value, current_value, min_good_percent, min_warn_percent, status, owner_user_id, is_active) VALUES
(8, 1, 3, 'Sucesso de Backups', 'Backups executados com sucesso', '%', 100, 98, 98, 90, 'success', 3, 1),
(9, 1, 3, 'Teste de Restore', 'Restores testados no mês', 'qtd', 4, 4, 95, 80, 'success', 3, 1),
(10, 1, 3, 'Cobertura Antivírus', 'Estações com antivírus atualizado', '%', 100, 97, 98, 90, 'warning', 3, 1),
(11, 1, 3, 'Firewall Atualizado', 'Regras de firewall revisadas', '%', 100, 100, 100, 95, 'success', 3, 1),
(12, 1, 3, 'Acessos Controlados', 'Usuários com perfil adequado', '%', 100, 95, 98, 90, 'warning', 2, 1);

-- Categoria 4: Controles de Gestão
INSERT INTO indicators (id, org_unit_id, category_id, name, description, unit, target_value, current_value, min_good_percent, min_warn_percent, status, owner_user_id, is_active) VALUES
(13, 1, 4, 'Controle de Requisições', 'Requisições atendidas no prazo', '%', 95, 91, 95, 85, 'warning', 2, 1),
(14, 1, 4, 'Pedidos Pendentes', 'Pedidos aguardando aprovação', 'qtd', 10, 8, 90, 70, 'success', 2, 1),
(15, 1, 4, 'Produção de Energia', 'MWh produzidos vs. meta', '%', 100, 103, 95, 85, 'success', 4, 1);

-- Categoria 5: Monitoramento
INSERT INTO indicators (id, org_unit_id, category_id, name, description, unit, target_value, current_value, min_good_percent, min_warn_percent, status, owner_user_id, is_active) VALUES
(16, 1, 5, 'Disponibilidade de Sistemas', 'Uptime dos sistemas críticos', '%', 99.5, 99.8, 99, 95, 'success', 3, 1),
(17, 1, 5, 'Links Ativos', 'Links de rede operacionais', '%', 100, 95, 98, 90, 'warning', 3, 1),
(18, 1, 5, 'Latência Média', 'Latência média dos enlaces', 'ms', 50, 35, 90, 70, 'success', 3, 1),
(19, 1, 5, 'Sistemas Atualizados', 'Sistemas com versão atual', '%', 100, 87, 95, 80, 'warning', 3, 1);

-- Categoria 6: Projetos
INSERT INTO indicators (id, org_unit_id, category_id, name, description, unit, target_value, current_value, min_good_percent, min_warn_percent, status, owner_user_id, is_active) VALUES
(20, 1, 6, 'Projetos no Prazo', 'Projetos dentro do cronograma', '%', 90, 75, 90, 70, 'warning', 2, 1),
(21, 1, 6, 'Taxa de Conclusão', 'Projetos concluídos vs. planejados', '%', 100, 85, 95, 80, 'warning', 2, 1);

-- Categoria 7: Recursos
INSERT INTO indicators (id, org_unit_id, category_id, name, description, unit, target_value, current_value, min_good_percent, min_warn_percent, status, owner_user_id, is_active) VALUES
(22, 1, 7, 'Estoque de Chips', 'Chips M2M disponíveis', 'qtd', 100, 87, 90, 70, 'warning', 3, 1),
(23, 1, 7, 'Controle de Consumíveis', 'Itens com estoque mínimo', '%', 100, 92, 95, 85, 'warning', 3, 1);

-- Categoria 8: Corporativo
INSERT INTO indicators (id, org_unit_id, category_id, name, description, unit, target_value, current_value, min_good_percent, min_warn_percent, status, owner_user_id, is_active) VALUES
(24, 1, 8, 'Integração ERP', 'Processos integrados', '%', 100, 90, 95, 85, 'warning', 2, 1),
(25, 1, 8, 'Qualidade de Dados', 'Dados sem inconsistência', '%', 100, 96, 98, 90, 'warning', 2, 1);

SET IDENTITY_INSERT indicators OFF;

PRINT '✓ 25 Indicadores criados';

-- ============================================================================
-- 5) HISTÓRICO DE INDICADORES (indicator_history)
-- ============================================================================
SET IDENTITY_INSERT indicator_history ON;

-- Histórico do indicador 1 (Inventário Atualizado) - últimos 6 meses
INSERT INTO indicator_history (id, indicator_id, org_unit_id, ref_date, value, target_value, percent_value, status, note, created_by) VALUES
(1, 1, 1, DATEADD(month, -5, GETDATE()), 88, 100, 88, 'warning', 'Início do projeto de inventário', 3),
(2, 1, 1, DATEADD(month, -4, GETDATE()), 90, 100, 90, 'warning', 'Inventário em andamento', 3),
(3, 1, 1, DATEADD(month, -3, GETDATE()), 92, 100, 92, 'warning', 'Melhoria contínua', 3),
(4, 1, 1, DATEADD(month, -2, GETDATE()), 94, 100, 94, 'warning', 'Quase na meta', 3),
(5, 1, 1, DATEADD(month, -1, GETDATE()), 95, 100, 95, 'success', 'Meta atingida!', 3),
(6, 1, 1, CAST(GETDATE() AS DATE), 95, 100, 95, 'success', 'Mantendo o padrão', 3);

-- Histórico do indicador 4 (SLA de Atendimento)
INSERT INTO indicator_history (id, indicator_id, org_unit_id, ref_date, value, target_value, percent_value, status, note, created_by) VALUES
(7, 4, 1, DATEADD(month, -5, GETDATE()), 85, 95, 89.5, 'warning', 'Demanda alta', 2),
(8, 4, 1, DATEADD(month, -4, GETDATE()), 88, 95, 92.6, 'warning', 'Melhorando processos', 2),
(9, 4, 1, DATEADD(month, -3, GETDATE()), 90, 95, 94.7, 'warning', 'Treinamento da equipe', 2),
(10, 4, 1, DATEADD(month, -2, GETDATE()), 91, 95, 95.8, 'success', 'Meta atingida', 2),
(11, 4, 1, DATEADD(month, -1, GETDATE()), 92, 95, 96.8, 'success', 'Acima da meta', 2),
(12, 4, 1, CAST(GETDATE() AS DATE), 92, 95, 96.8, 'success', 'Mantendo performance', 2);

-- Histórico do indicador 8 (Sucesso de Backups)
INSERT INTO indicator_history (id, indicator_id, org_unit_id, ref_date, value, target_value, percent_value, status, note, created_by) VALUES
(13, 8, 1, DATEADD(month, -5, GETDATE()), 96, 100, 96, 'warning', 'Falhas pontuais', 3),
(14, 8, 1, DATEADD(month, -4, GETDATE()), 97, 100, 97, 'warning', 'Melhorias implementadas', 3),
(15, 8, 1, DATEADD(month, -3, GETDATE()), 98, 100, 98, 'success', 'Processo estabilizado', 3),
(16, 8, 1, DATEADD(month, -2, GETDATE()), 98, 100, 98, 'success', 'Sem falhas', 3),
(17, 8, 1, DATEADD(month, -1, GETDATE()), 98, 100, 98, 'success', 'Excelente resultado', 3),
(18, 8, 1, CAST(GETDATE() AS DATE), 98, 100, 98, 'success', 'Padrão mantido', 3);

SET IDENTITY_INSERT indicator_history OFF;

PRINT '✓ 18 Registros de histórico criados';

-- ============================================================================
-- 6) ATIVOS DE TI (it_assets)
-- ============================================================================
SET IDENTITY_INSERT it_assets ON;

INSERT INTO it_assets (id, org_unit_id, type, name, serial, brand, model, status, location, responsible, acquisition_date) VALUES
(1, 1, 'hardware', 'Servidor Principal', 'SRV-001-2023', 'Dell', 'PowerEdge R740', 'active', 'Data Center - Rack A1', 'João Silva', '2023-01-15'),
(2, 1, 'hardware', 'Switch Core', 'SWT-001-2023', 'Cisco', 'Catalyst 9300', 'active', 'Data Center - Rack A2', 'João Silva', '2023-02-20'),
(3, 1, 'hardware', 'Firewall', 'FW-001-2022', 'Fortinet', 'FortiGate 200E', 'active', 'Data Center - Rack A3', 'João Silva', '2022-11-10'),
(4, 1, 'hardware', 'Notebook - Gerente TI', 'NB-045-2023', 'Lenovo', 'ThinkPad X1', 'active', 'Sala TI', 'Maria Santos', '2023-03-05'),
(5, 1, 'hardware', 'Desktop - Analista', 'DK-123-2022', 'HP', 'EliteDesk 800', 'active', 'Estação 12', 'Carlos Oliveira', '2022-08-15'),
(6, 1, 'software', 'Microsoft Office 365', 'LIC-O365-2024', 'Microsoft', 'E3', 'active', 'Cloud', 'TI', '2024-01-01'),
(7, 1, 'software', 'Antivírus Kaspersky', 'LIC-KAS-2024', 'Kaspersky', 'Endpoint Security', 'active', 'Cloud', 'TI', '2024-01-01'),
(8, 1, 'license', 'Windows Server 2022', 'LIC-WS2022-001', 'Microsoft', 'Standard', 'active', 'Servidor Principal', 'TI', '2023-01-15');

SET IDENTITY_INSERT it_assets OFF;

PRINT '✓ 8 Ativos de TI criados';

-- ============================================================================
-- 7) CHAMADOS (tickets)
-- ============================================================================
SET IDENTITY_INSERT tickets ON;

INSERT INTO tickets (id, org_unit_id, code, title, category, priority, status, requester, assignee, opened_at, satisfaction) VALUES
(1, 1, 'GLPI-2024-001', 'Instalação de software', 'Software', 'medium', 'resolved', 'Ana Costa', 'Carlos Oliveira', DATEADD(day, -5, GETDATE()), 5),
(2, 1, 'GLPI-2024-002', 'Problema de rede', 'Rede', 'high', 'in_progress', 'Pedro Santos', 'João Silva', DATEADD(day, -2, GETDATE()), NULL),
(3, 1, 'GLPI-2024-003', 'Solicitação de acesso', 'Segurança', 'low', 'open', 'Julia Ferreira', NULL, DATEADD(day, -1, GETDATE()), NULL),
(4, 1, 'GLPI-2024-004', 'Impressora não funciona', 'Hardware', 'medium', 'open', 'Roberto Lima', 'Carlos Oliveira', GETDATE(), NULL),
(5, 1, 'GLPI-2024-005', 'Email não recebe anexos', 'Email', 'medium', 'resolved', 'Fernanda Souza', 'João Silva', DATEADD(day, -7, GETDATE()), 4);

SET IDENTITY_INSERT tickets OFF;

PRINT '✓ 5 Chamados criados';

-- ============================================================================
-- 8) PROJETOS (projects)
-- ============================================================================
SET IDENTITY_INSERT projects ON;

INSERT INTO projects (id, org_unit_id, name, description, status, progress, start_date, end_date, owner, sponsor) VALUES
(1, 1, 'Migração para Cloud', 'Migração de servidores locais para Azure', 'in_progress', 65, '2024-01-01', '2024-06-30', 'João Silva', 'Diretor TI'),
(2, 1, 'Implantação GLPI', 'Sistema de gestão de chamados', 'completed', 100, '2023-10-01', '2023-12-31', 'Maria Santos', 'Gerente TI'),
(3, 1, 'Upgrade de Rede', 'Troca de switches e cabeamento', 'in_progress', 40, '2024-02-01', '2024-05-31', 'Carlos Oliveira', 'Gerente TI'),
(4, 1, 'Projeto Way Brasil 100% Integrado', 'Integração total dos sistemas corporativos', 'in_progress', 55, '2023-11-01', '2024-12-31', 'João Silva', 'CEO');

SET IDENTITY_INSERT projects OFF;

PRINT '✓ 4 Projetos criados';

-- ============================================================================
-- 9) BACKUPS (backups)
-- ============================================================================
SET IDENTITY_INSERT backups ON;

INSERT INTO backups (id, org_unit_id, system_name, type, status, size_mb, location, executed_at, restore_tested) VALUES
(1, 1, 'SQL Server - ABOT', 'full', 'success', 2560.50, '\\\\backup-srv\\abot', DATEADD(day, -1, GETDATE()), 1),
(2, 1, 'SQL Server - ABOT', 'differential', 'success', 512.30, '\\\\backup-srv\\abot', GETDATE(), 0),
(3, 1, 'Servidor de Arquivos', 'full', 'success', 15360.75, '\\\\backup-srv\\files', DATEADD(day, -1, GETDATE()), 1),
(4, 1, 'Active Directory', 'full', 'success', 128.40, '\\\\backup-srv\\ad', DATEADD(day, -1, GETDATE()), 1),
(5, 1, 'Exchange Server', 'incremental', 'success', 1024.20, '\\\\backup-srv\\exchange', GETDATE(), 0);

SET IDENTITY_INSERT backups OFF;

PRINT '✓ 5 Backups registrados';

-- ============================================================================
-- 10) LINKS DE REDE (network_links)
-- ============================================================================
SET IDENTITY_INSERT network_links ON;

INSERT INTO network_links (id, org_unit_id, name, type, status, uptime_percent, bandwidth_mbps, latency_ms, provider, location) VALUES
(1, 1, 'Link Principal - Fibra', 'fibra', 'up', 99.8, 500, 5, 'Vivo Empresas', 'São Paulo - Sede'),
(2, 1, 'Link Backup - 4G', '4g', 'up', 98.5, 100, 45, 'Claro', 'São Paulo - Sede'),
(3, 2, 'Link Rádio - Usina A', 'radio', 'up', 97.2, 50, 25, 'Provedor Local', 'Usina Solar A'),
(4, 3, 'Link Fibra - Filial MG', 'fibra', 'up', 99.5, 300, 8, 'Oi Empresas', 'Belo Horizonte'),
(5, 1, 'VPN Site-to-Site', 'vpn', 'up', 99.9, 100, 12, 'Interno', 'Matriz <-> Filiais');

SET IDENTITY_INSERT network_links OFF;

PRINT '✓ 5 Links de rede criados';

-- ============================================================================
-- 11) RECURSOS / ESTOQUE (resources)
-- ============================================================================
SET IDENTITY_INSERT resources ON;

INSERT INTO resources (id, org_unit_id, type, name, sku, location, min_stock, current_stock, unit) VALUES
(1, 1, 'chip', 'Chip M2M - Monitoramento', 'CHIP-M2M-001', 'Almoxarifado TI', 20, 87, 'un'),
(2, 1, 'chip', 'Chip 4G - Backup', 'CHIP-4G-001', 'Almoxarifado TI', 10, 15, 'un'),
(3, 1, 'consumable', 'Toner HP LaserJet', 'TNR-HP-05A', 'Almoxarifado', 5, 12, 'un'),
(4, 1, 'consumable', 'Cabo de Rede Cat6', 'CAB-CAT6-001', 'Almoxarifado TI', 50, 120, 'm'),
(5, 1, 'other', 'HD Externo 1TB', 'HD-EXT-1TB', 'Almoxarifado TI', 5, 8, 'un');

SET IDENTITY_INSERT resources OFF;

PRINT '✓ 5 Recursos cadastrados';

-- ============================================================================
-- 12) MOVIMENTAÇÃO DE ESTOQUE (stock_movements)
-- ============================================================================
SET IDENTITY_INSERT stock_movements ON;

INSERT INTO stock_movements (id, resource_id, org_unit_id, movement_type, quantity, movement_date, reference, requested_by) VALUES
(1, 1, 1, 'in', 100, DATEADD(day, -30, GETDATE()), 'COMPRA-2024-001', 'TI'),
(2, 1, 1, 'out', 13, DATEADD(day, -15, GETDATE()), 'OS-2024-045', 'João Silva'),
(3, 2, 1, 'in', 20, DATEADD(day, -20, GETDATE()), 'COMPRA-2024-002', 'TI'),
(4, 2, 1, 'out', 5, DATEADD(day, -10, GETDATE()), 'PROJETO-REDE', 'Carlos Oliveira'),
(5, 3, 1, 'in', 15, DATEADD(day, -25, GETDATE()), 'COMPRA-2024-003', 'Compras'),
(6, 3, 1, 'out', 3, DATEADD(day, -5, GETDATE()), 'REPOSICAO-IMPRESSORA', 'TI');

SET IDENTITY_INSERT stock_movements OFF;

PRINT '✓ 6 Movimentações de estoque registradas';

-- ============================================================================
-- ATUALIZAR VALORES ATUAIS DOS INDICADORES
-- ============================================================================

-- Atualizar last_updated_at de todos os indicadores
UPDATE indicators SET last_updated_at = GETDATE();

PRINT '';
PRINT '============================================================================';
PRINT 'DADOS DE EXEMPLO INSERIDOS COM SUCESSO!';
PRINT '============================================================================';
PRINT 'Resumo:';
PRINT '  • 4 Unidades (WAY262, WAY153, WAY364, WAYHO)';
PRINT '  • 5 Usuários (1 admin, 1 manager, 2 editors, 1 viewer)';
PRINT '  • 8 Categorias de indicadores';
PRINT '  • 25 Indicadores distribuídos nas categorias';
PRINT '  • 18 Registros de histórico (últimos 6 meses)';
PRINT '  • 8 Ativos de TI (hardware, software, licenças)';
PRINT '  • 5 Chamados (diferentes status)';
PRINT '  • 4 Projetos em andamento';
PRINT '  • 5 Backups registrados';
PRINT '  • 5 Links de rede monitorados';
PRINT '  • 5 Recursos em estoque';
PRINT '  • 6 Movimentações de estoque';
PRINT '';
PRINT 'O portal está pronto para uso!';
PRINT '============================================================================';
