const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const db = require('./database');

const app = express();
const PORT = process.env.PORT || 3001;

// ==================== MIDDLEWARES ====================

// Security headers
app.use(helmet());

// CORS
const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'];
app.use(cors({
  origin: function(origin, callback) {
    if (!origin || allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true
}));

// Body parser
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 100, // limite de 100 requisições por IP
  message: 'Muitas requisições, tente novamente mais tarde.'
});
app.use('/api/', limiter);

// Middleware de autenticação simples
const authenticate = (req, res, next) => {
  const apiKey = req.headers['x-api-key'];
  
  if (process.env.NODE_ENV === 'production' && apiKey !== process.env.API_KEY) {
    return res.status(401).json({ error: 'API Key inválida' });
  }
  
  next();
};

// ==================== HEALTH CHECK ====================

app.get('/health', async (req, res) => {
  try {
    await db.query('SELECT 1 as test');
    res.json({ 
      status: 'ok', 
      database: 'connected',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ 
      status: 'error', 
      database: 'disconnected',
      message: error.message 
    });
  }
});

// ==================== UNIDADES (org_units) ====================

app.get('/api/units', authenticate, async (req, res) => {
  try {
    const units = await db.query(`
      SELECT * FROM org_units 
      WHERE is_active = 1 
      ORDER BY code
    `);
    res.json(units);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/units/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const unit = await db.query('SELECT * FROM org_units WHERE id = @id', { id });
    
    if (unit.length === 0) {
      return res.status(404).json({ error: 'Unidade não encontrada' });
    }
    
    res.json(unit[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== CATEGORIAS ====================

app.get('/api/categories', authenticate, async (req, res) => {
  try {
    const categories = await db.query(`
      SELECT * FROM categories 
      WHERE is_active = 1 
      ORDER BY sort_order
    `);
    res.json(categories);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/categories/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const category = await db.query('SELECT * FROM categories WHERE id = @id', { id });
    
    if (category.length === 0) {
      return res.status(404).json({ error: 'Categoria não encontrada' });
    }
    
    res.json(category[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== INDICADORES ====================

app.get('/api/indicators', authenticate, async (req, res) => {
  try {
    const { org_unit_id, category_id, status } = req.query;
    
    let query = `
      SELECT 
        i.*,
        c.name as category_name,
        c.color as category_color,
        c.icon as category_icon,
        u.code as unit_code,
        u.name as unit_name,
        usr.name as owner_name
      FROM indicators i
      JOIN categories c ON i.category_id = c.id
      JOIN org_units u ON i.org_unit_id = u.id
      LEFT JOIN users usr ON i.owner_user_id = usr.id
      WHERE i.is_active = 1
    `;
    
    const params = {};
    
    if (org_unit_id) {
      query += ' AND i.org_unit_id = @org_unit_id';
      params.org_unit_id = org_unit_id;
    }
    
    if (category_id) {
      query += ' AND i.category_id = @category_id';
      params.category_id = category_id;
    }
    
    if (status) {
      query += ' AND i.status = @status';
      params.status = status;
    }
    
    query += ' ORDER BY c.sort_order, i.name';
    
    const indicators = await db.query(query, params);
    res.json(indicators);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/indicators/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    
    const indicator = await db.query(`
      SELECT 
        i.*,
        c.name as category_name,
        c.color as category_color,
        u.code as unit_code,
        u.name as unit_name,
        usr.name as owner_name
      FROM indicators i
      JOIN categories c ON i.category_id = c.id
      JOIN org_units u ON i.org_unit_id = u.id
      LEFT JOIN users usr ON i.owner_user_id = usr.id
      WHERE i.id = @id
    `, { id });
    
    if (indicator.length === 0) {
      return res.status(404).json({ error: 'Indicador não encontrado' });
    }
    
    // Buscar histórico
    const history = await db.query(`
      SELECT * FROM indicator_history 
      WHERE indicator_id = @id 
      ORDER BY ref_date DESC
    `, { id });
    
    res.json({ 
      indicator: indicator[0], 
      history 
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/indicators/:id/update', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const { value, note, user_id } = req.body;
    
    if (value === undefined || value === null) {
      return res.status(400).json({ error: 'Valor é obrigatório' });
    }
    
    // Buscar indicador
    const indicator = await db.query('SELECT * FROM indicators WHERE id = @id', { id });
    
    if (indicator.length === 0) {
      return res.status(404).json({ error: 'Indicador não encontrado' });
    }
    
    const ind = indicator[0];
    
    // Calcular percentual e status
    let percent_value = 0;
    let status = 'warning';
    
    if (ind.target_value && ind.target_value > 0) {
      percent_value = (value / ind.target_value) * 100;
      
      if (percent_value >= ind.min_good_percent) {
        status = 'success';
      } else if (percent_value >= ind.min_warn_percent) {
        status = 'warning';
      } else {
        status = 'critical';
      }
    }
    
    // Atualizar indicador
    await db.query(`
      UPDATE indicators 
      SET current_value = @value, 
          current_percent = @percent_value,
          status = @status,
          last_updated_at = GETDATE()
      WHERE id = @id
    `, { id, value, percent_value, status });
    
    // Inserir histórico
    await db.query(`
      INSERT INTO indicator_history 
        (indicator_id, org_unit_id, ref_date, value, target_value, percent_value, status, note, created_by)
      VALUES 
        (@indicator_id, @org_unit_id, CAST(GETDATE() AS DATE), @value, @target_value, @percent_value, @status, @note, @created_by)
    `, { 
      indicator_id: id,
      org_unit_id: ind.org_unit_id,
      value,
      target_value: ind.target_value,
      percent_value,
      status,
      note: note || '',
      created_by: user_id || null
    });
    
    res.json({ 
      success: true, 
      message: 'Indicador atualizado com sucesso',
      value,
      percent_value,
      status
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== DASHBOARD ====================

app.get('/api/dashboard/summary', authenticate, async (req, res) => {
  try {
    const { org_unit_id } = req.query;
    
    let unitFilter = '';
    const params = {};
    
    if (org_unit_id) {
      unitFilter = 'WHERE org_unit_id = @org_unit_id';
      params.org_unit_id = org_unit_id;
    }
    
    const categoriesCount = await db.query('SELECT COUNT(*) as count FROM categories WHERE is_active = 1');
    
    const indicatorsCount = await db.query(`
      SELECT COUNT(*) as count FROM indicators 
      WHERE is_active = 1 ${org_unit_id ? 'AND org_unit_id = @org_unit_id' : ''}
    `, params);
    
    const ticketsCount = await db.query(`
      SELECT COUNT(*) as count FROM tickets 
      WHERE status IN ('open', 'in_progress') ${org_unit_id ? 'AND org_unit_id = @org_unit_id' : ''}
    `, params);
    
    const projectsCount = await db.query(`
      SELECT COUNT(*) as count FROM projects 
      WHERE status = 'in_progress' ${org_unit_id ? 'AND org_unit_id = @org_unit_id' : ''}
    `, params);
    
    res.json({
      categories: categoriesCount[0].count,
      activeIndicators: indicatorsCount[0].count,
      openTickets: ticketsCount[0].count,
      activeProjects: projectsCount[0].count
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== CHAMADOS ====================

app.get('/api/tickets', authenticate, async (req, res) => {
  try {
    const { org_unit_id, status, priority } = req.query;
    
    let query = `
      SELECT t.*, u.code as unit_code, u.name as unit_name
      FROM tickets t
      JOIN org_units u ON t.org_unit_id = u.id
      WHERE 1=1
    `;
    
    const params = {};
    
    if (org_unit_id) {
      query += ' AND t.org_unit_id = @org_unit_id';
      params.org_unit_id = org_unit_id;
    }
    
    if (status) {
      query += ' AND t.status = @status';
      params.status = status;
    }
    
    if (priority) {
      query += ' AND t.priority = @priority';
      params.priority = priority;
    }
    
    query += ' ORDER BY t.opened_at DESC';
    
    const tickets = await db.query(query, params);
    res.json(tickets);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== PROJETOS ====================

app.get('/api/projects', authenticate, async (req, res) => {
  try {
    const { org_unit_id, status } = req.query;
    
    let query = `
      SELECT p.*, u.code as unit_code, u.name as unit_name
      FROM projects p
      JOIN org_units u ON p.org_unit_id = u.id
      WHERE 1=1
    `;
    
    const params = {};
    
    if (org_unit_id) {
      query += ' AND p.org_unit_id = @org_unit_id';
      params.org_unit_id = org_unit_id;
    }
    
    if (status) {
      query += ' AND p.status = @status';
      params.status = status;
    }
    
    query += ' ORDER BY p.created_at DESC';
    
    const projects = await db.query(query, params);
    res.json(projects);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== ATIVOS ====================

app.get('/api/assets', authenticate, async (req, res) => {
  try {
    const { org_unit_id, type, status } = req.query;
    
    let query = `
      SELECT a.*, u.code as unit_code, u.name as unit_name
      FROM it_assets a
      JOIN org_units u ON a.org_unit_id = u.id
      WHERE 1=1
    `;
    
    const params = {};
    
    if (org_unit_id) {
      query += ' AND a.org_unit_id = @org_unit_id';
      params.org_unit_id = org_unit_id;
    }
    
    if (type) {
      query += ' AND a.type = @type';
      params.type = type;
    }
    
    if (status) {
      query += ' AND a.status = @status';
      params.status = status;
    }
    
    query += ' ORDER BY a.created_at DESC';
    
    const assets = await db.query(query, params);
    res.json(assets);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== BACKUPS ====================

app.get('/api/backups', authenticate, async (req, res) => {
  try {
    const { org_unit_id } = req.query;
    
    let query = `
      SELECT b.*, u.code as unit_code, u.name as unit_name
      FROM backups b
      JOIN org_units u ON b.org_unit_id = u.id
      WHERE 1=1
    `;
    
    const params = {};
    
    if (org_unit_id) {
      query += ' AND b.org_unit_id = @org_unit_id';
      params.org_unit_id = org_unit_id;
    }
    
    query += ' ORDER BY b.executed_at DESC';
    
    const backups = await db.query(query, params);
    res.json(backups);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== REDE ====================

app.get('/api/network-links', authenticate, async (req, res) => {
  try {
    const { org_unit_id, status, type } = req.query;
    
    let query = `
      SELECT n.*, u.code as unit_code, u.name as unit_name
      FROM network_links n
      JOIN org_units u ON n.org_unit_id = u.id
      WHERE 1=1
    `;
    
    const params = {};
    
    if (org_unit_id) {
      query += ' AND n.org_unit_id = @org_unit_id';
      params.org_unit_id = org_unit_id;
    }
    
    if (status) {
      query += ' AND n.status = @status';
      params.status = status;
    }
    
    if (type) {
      query += ' AND n.type = @type';
      params.type = type;
    }
    
    query += ' ORDER BY n.name';
    
    const links = await db.query(query, params);
    res.json(links);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== RECURSOS ====================

app.get('/api/resources', authenticate, async (req, res) => {
  try {
    const { org_unit_id, type, low_stock } = req.query;
    
    let query = `
      SELECT r.*, u.code as unit_code, u.name as unit_name,
        CASE WHEN r.current_stock < r.min_stock THEN 1 ELSE 0 END as is_low_stock
      FROM resources r
      JOIN org_units u ON r.org_unit_id = u.id
      WHERE 1=1
    `;
    
    const params = {};
    
    if (org_unit_id) {
      query += ' AND r.org_unit_id = @org_unit_id';
      params.org_unit_id = org_unit_id;
    }
    
    if (type) {
      query += ' AND r.type = @type';
      params.type = type;
    }
    
    if (low_stock === 'true') {
      query += ' AND r.current_stock < r.min_stock';
    }
    
    query += ' ORDER BY r.name';
    
    const resources = await db.query(query, params);
    res.json(resources);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== MOVIMENTAÇÃO DE ESTOQUE ====================

app.get('/api/stock-movements', authenticate, async (req, res) => {
  try {
    const { resource_id, org_unit_id, movement_type } = req.query;
    
    let query = `
      SELECT sm.*, r.name as resource_name, u.code as unit_code, u.name as unit_name
      FROM stock_movements sm
      JOIN resources r ON sm.resource_id = r.id
      JOIN org_units u ON sm.org_unit_id = u.id
      WHERE 1=1
    `;
    
    const params = {};
    
    if (resource_id) {
      query += ' AND sm.resource_id = @resource_id';
      params.resource_id = resource_id;
    }
    
    if (org_unit_id) {
      query += ' AND sm.org_unit_id = @org_unit_id';
      params.org_unit_id = org_unit_id;
    }
    
    if (movement_type) {
      query += ' AND sm.movement_type = @movement_type';
      params.movement_type = movement_type;
    }
    
    query += ' ORDER BY sm.movement_date DESC, sm.created_at DESC';
    
    const movements = await db.query(query, params);
    res.json(movements);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== USUÁRIOS (Admin) ====================

app.get('/api/users', authenticate, async (req, res) => {
  try {
    const users = await db.query(`
      SELECT id, name, email, role, is_active, created_at, last_login
      FROM users
      ORDER BY name
    `);
    res.json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== ERROR HANDLER ====================

app.use((error, req, res, next) => {
  console.error('❌ Erro:', error);
  res.status(500).json({ 
    error: 'Erro interno do servidor',
    message: process.env.NODE_ENV === 'development' ? error.message : undefined
  });
});

// ==================== INICIAR SERVIDOR ====================

async function start() {
  try {
    // Testar conexão com banco
    await db.connect();
    
    // Iniciar servidor
    app.listen(PORT, () => {
      console.log('');
      console.log('============================================================================');
      console.log('🚀 API Portal de Indicadores - Way Brasil');
      console.log('============================================================================');
      console.log(`🔗 Porta: ${PORT}`);
      console.log(`🏥 Health check: http://localhost:${PORT}/health`);
      console.log(`📊 Endpoints: http://localhost:${PORT}/api/`);
      console.log('');
      console.log('📌 Endpoints disponíveis:');
      console.log('   • GET  /api/units                - Unidades');
      console.log('   • GET  /api/categories           - Categorias');
      console.log('   • GET  /api/indicators           - Indicadores (com filtros)');
      console.log('   • GET  /api/indicators/:id       - Detalhes + histórico');
      console.log('   • POST /api/indicators/:id/update - Atualizar valor');
      console.log('   • GET  /api/dashboard/summary    - Resumo dashboard');
      console.log('   • GET  /api/tickets              - Chamados');
      console.log('   • GET  /api/projects             - Projetos');
      console.log('   • GET  /api/assets               - Ativos de TI');
      console.log('   • GET  /api/backups              - Backups');
      console.log('   • GET  /api/network-links        - Links de rede');
      console.log('   • GET  /api/resources            - Recursos/Estoque');
      console.log('   • GET  /api/stock-movements      - Movimentações');
      console.log('   • GET  /api/users                - Usuários');
      console.log('');
      console.log('🔐 Autenticação: Header "X-API-Key: ' + process.env.API_KEY + '"');
      console.log('============================================================================');
      console.log('');
    });
  } catch (error) {
    console.error('❌ Erro ao iniciar servidor:', error);
    process.exit(1);
  }
}

start();

module.exports = app;
