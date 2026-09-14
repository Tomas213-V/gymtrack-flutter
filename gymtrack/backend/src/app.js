const express = require('express');
const cors = require('cors');
const path = require('path');

require('dotenv').config({ path: path.resolve(__dirname, '../.env') });

// Importación de las rutas
const authRoutes = require('./routes/authRoutes');
const socioRoutes = require('./routes/socioRoutes'); // 👈 Importante agregar esto

const app = express();

app.use(cors());
app.use(express.json());

// Registro de endpoints base
app.use('/api/auth', authRoutes);
app.use('/api/socios', socioRoutes); // 👈 Importante agregar esto

app.get('/', (req, res) => {
  res.send('Servidor GymTrack funcionando correctamente 🚀');
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ Servidor escuchando en http://localhost:${PORT}`);
});