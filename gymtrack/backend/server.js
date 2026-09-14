// ==============================================================================
// SERVIDOR PRINCIPAL DE GYMTRACK (EXPRESS + NODE.JS)
// ==============================================================================

// 1. IMPORTACIÓN DE DEPENDENCIAS Y MÓDULOS
// Express: Framework web para crear la API REST, gestionar rutas y peticiones HTTP
const express = require("express");

// CORS (Cross-Origin Resource Sharing): Middleware para permitir que aplicaciones externas 
// (como el frontend en React/Vite que corre en otro puerto) puedan comunicarse con esta API
const cors = require("cors");

// Dotenv: Carga automáticamente las variables definidas en el archivo .env en 'process.env'
require("dotenv").config();

// Cliente de Supabase: Instancia configurada para interactuar con la base de datos PostgreSQL en la nube
const supabase = require("./src/config/supabase");
// importa ruta
const authRoutes = require("./src/routes/authRoutes");
const pagoRoutes = require("./src/routes/pagoRoutes");
const gimnasioRoutes = require("./src/routes/gimnasioRoutes");
const socioRoutes = require("./src/routes/socioRoutes");

// 2. INICIALIZACIÓN DE LA APLICACIÓN
// Crea una instancia de la aplicación Express
const app = express();

// 3. MIDDLEWARES GLOBALES
// Habilita CORS para aceptar solicitudes de otros orígenes (por ejemplo: http://localhost:5173 del frontend)
app.use(cors());

// Permite que Express entienda y procese datos en formato JSON en el cuerpo (body) de las peticiones POST/PUT
app.use(express.json());

// 4. RUTAS (ENDPOINTS)
// Ruta raíz (/): Sirve como prueba inicial básica para comprobar que el servidor responde
app.get("/", (req, res) => {
    res.json({
        message: "API de GymTrack funcionando"
    });
});

// Ruta de Salud (/api/health): Endpoint para verificar el estado del servidor y la conexión a Supabase
// Útil para monitoreo o para que el frontend valide si la base de datos está disponible
app.get("/api/health", async (req, res) => {
    try {
        // Ejecutamos una llamada ligera a Supabase (consultar el estado de la sesión de autenticación)
        // para certificar que las credenciales son válidas y hay comunicación con el servicio
        const { error } = await supabase.auth.getSession();
        if (error) throw error;

        // Si no hay error, respondemos con código HTTP 200 y mensaje de éxito
        res.json({
            status: "ok",
            database: "Supabase conectado correctamente",
            timestamp: new Date().toISOString()
        });
    } catch (err) {
        // En caso de fallo de conexión o credenciales inválidas, respondemos con error 500
        res.status(500).json({
            status: "error",
            database: "Error al conectar con Supabase",
            message: err.message
        });
    }
});
// Registrar las rutas de Autenticación (/api/auth/register y /api/auth/login)
app.use("/api/auth", authRoutes);
app.use("/api/pagos", pagoRoutes);
app.use("/api/gimnasios", gimnasioRoutes);
app.use("/api/socios", socioRoutes);



// 5. CONFIGURACIÓN DEL PUERTO Y PUESTA EN MARCHA DEL SERVIDOR
// Usa el puerto definido en el archivo .env (PORT), o el 3000 por defecto si no está especificado
const PORT = process.env.PORT || 3000;

// Inicia el servidor HTTP para escuchar peticiones en el puerto asignado
app.listen(PORT, async () => {
    console.log(`Servidor ejecutándose en http://localhost:${PORT}`);
    
    // Verificación automática de la base de datos al encender el servidor:
    // Realiza una prueba rápida para avisar por consola si la conexión a Supabase fue exitosa o falló
    try {
        const { error } = await supabase.auth.getSession();
        if (error) {
            console.error("❌ Error al verificar conexión con Supabase:", error.message);
        } else {
            console.log("✅ Conexión con Supabase establecida correctamente");
        }
    } catch (err) {
        console.error("❌ Error inesperado al conectar con Supabase:", err.message);
    }
});