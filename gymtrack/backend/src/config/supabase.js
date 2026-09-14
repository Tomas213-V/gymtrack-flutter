// ==============================================================================
// CONFIGURACIÓN DEL CLIENTE DE SUPABASE (BASE DE DATOS)
// ==============================================================================

// Importamos la función 'createClient' del SDK oficial de Supabase para Node.js
const { createClient } = require('@supabase/supabase-js');

// Importamos 'path' para construir rutas de archivos de manera segura en cualquier sistema operativo
const path = require('path');

// Cargamos las variables de entorno desde el archivo .env ubicado en la raíz de 'backend'
// Usamos path.resolve para garantizar que siempre encuentre el archivo .env,
// sin importar desde qué carpeta se ejecute la terminal o el servidor.
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });

// Obtenemos la URL de Supabase desde las variables de entorno.
// Admite tanto 'SUPABASE_URL' (estándar para backend) como 'VITE_SUPABASE_URL' (convención de frontend)
const supabaseUrl = process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL;

// Obtenemos la clave de la API (API Key) de Supabase desde las variables de entorno.
// Admite la clave estándar, anon key o publishable key.
const supabaseKey = process.env.SUPABASE_KEY || process.env.SUPABASE_ANON_KEY || process.env.VITE_SUPABASE_PUBLISHABLE_KEY;

// Validación: verificamos que ambas variables existan antes de inicializar el cliente
if (!supabaseUrl || !supabaseKey) {
  console.error('❌ Error: Faltan las variables de entorno de Supabase (SUPABASE_URL y SUPABASE_KEY en .env).');
}

// Creamos la instancia del cliente de Supabase con las credenciales cargadas.
// Esta instancia nos permite realizar operaciones como consultas a tablas (.from),
// autenticación (.auth), almacenamiento (.storage), etc.
const supabase = createClient(supabaseUrl, supabaseKey);

// Exportamos la instancia para que pueda ser reutilizada en controladores, servicios y rutas
// siguiendo el patrón singleton (una sola conexión compartida en toda la app)
module.exports = supabase;
