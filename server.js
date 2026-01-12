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

// ==================== CATEGORIAS ====================

app.get('/api/categories', authenticate, async (req, res) => {
  try {
    const categories = await db.query('SELECT * FROM categories ORDER BY id');
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
    const query = `
      SELECT 
        i.*,
        c.name as category_name,
        c.color as category_color
      FROM indicators i
      JOIN categories c ON i.category_id = c.id
      WHERE i.status = 'active'
      ORDER BY c.id, i.name
    `;
    
    const indicators = await db.query(query);
    res.json(indicators);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/indicators/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    
    const indicator = await db.query('SELECT * FROM indicators WHERE id = @id', { id });
    
    if (indicator.length === 0) {
      return res.status(404).json({ error: 'Indicador não encontrado' });
    }
    
    const history = await db.query(
      'SELECT * FROM indicator_history WHERE indicator_id = @id ORDER BY period_date DESC',
      { id }
    );
    
    res.json({ indicator: indicator[0], history });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/categories/:id/indicators', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const indicators = await db.query(
      'SELECT * FROM indicators WHERE category_id = @id AND status = @status ORDER BY name',
      { id, status: 'active' }
    );
    
    res.json(indicators);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/indicators/:id/update', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const { value, notes } = req.body;
    
    // Atualizar indicador
    await db.query(
      'UPDATE indicators SET current_value = @value, last_updated = GETDATE() WHERE id = @id',
      { id, value }
    );
    
    // Inserir histórico
    await db.query(
      'INSERT INTO indicator_history (indicator_id, value, period_date, notes) VALUES (@id, @value, CAST(GETDATE() AS DATE), @notes)',
      { id, value, notes: notes || '' }
    );
    
    res.json({ success: true, message: 'Indicador atualizado com sucesso' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== DASHBOARD ====================

app.get('/api/dashboard/summary', authenticate, async (req, res) => {
  try {
    const categoriesCount = await db.query('SELECT COUNT(*) as count FROM categories');
    const indicatorsCount = await db.query('SELECT COUNT(*) as count FROM indicators WHERE status = @status', { status: 'active' });
    const ticketsCount = await db.query('SELECT COUNT(*) as count FROM tickets WHERE status IN (@status1, @status2)', { status1: 'open', status2: 'in_progress' });
    const projectsCount = await db.query('SELECT COUNT(*) as count FROM projects WHERE status = @status', { status: 'in_progress' });
    
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
    const { status } = req.query;
    
    let query = 'SELECT * FROM tickets';
    let params = {};
    
    if (status) {
      query += ' WHERE status = @status';
      params.status = status;
    }
    
    query += ' ORDER BY created_at DESC';
    
    const tickets = await db.query(query, params);
    res.json(tickets);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== PROJETOS ====================

app.get('/api/projects', authenticate, async (req, res) => {
  try {
    const projects = await db.query('SELECT * FROM projects ORDER BY created_at DESC');
    res.json(projects);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== ATIVOS ====================

app.get('/api/assets', authenticate, async (req, res) => {
  try {
    const { status } = req.query;
    
    let query = 'SELECT * FROM it_assets';
    let params = {};
    
    if (status) {
      query += ' WHERE status = @status';
      params.status = status;
    }
    
    query += ' ORDER BY created_at DESC';
    
    const assets = await db.query(query, params);
    res.json(assets);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== BACKUPS ====================

app.get('/api/backups', authenticate, async (req, res) => {
  try {
    const backups = await db.query('SELECT TOP 30 * FROM backups ORDER BY backup_date DESC');
    res.json(backups);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== REDE ====================

app.get('/api/network-links', authenticate, async (req, res) => {
  try {
    const links = await db.query('SELECT * FROM network_links ORDER BY link_name');
    res.json(links);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== RECURSOS ====================

app.get('/api/resources', authenticate, async (req, res) => {
  try {
    const resources = await db.query('SELECT * FROM resources ORDER BY name');
    res.json(resources);
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
      console.log(`🚀 API rodando na porta ${PORT}`);
      console.log(`🔗 Health check: http://localhost:${PORT}/health`);
      console.log(`📊 Endpoints disponíveis em: http://localhost:${PORT}/api/`);
    });
  } catch (error) {
    console.error('❌ Erro ao iniciar servidor:', error);
    process.exit(1);
  }
}

start();

module.exports = app;
