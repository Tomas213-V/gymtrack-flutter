const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const supabase = require('../config/supabase');

// Expresión regular para validar formato de correo electrónico
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

/**
 */
const registerOwner = async (req, res) => {
  try {
    const { 
      nombreGimnasio, 
      direccion, 
      telefono, 
      emailGimnasio,
      nombre, 
      apellido, 
      email, 
      contrasena 
    } = req.body;

    // 1. Criterio de Aceptación: Validar datos obligatorios
    if (!nombre || !apellido || !email || !contrasena) {
      return res.status(400).json({ error: 'Todos los campos obligatorios deben ser completados.' });
    }

    const cleanEmail = email.trim().toLowerCase();

    if (!EMAIL_REGEX.test(cleanEmail)) {
      return res.status(400).json({ error: 'El formato del email ingresado no es válido.' });
    }

    // 2.  No permitir registrar usuarios con un email que ya exista
    const { data: usuarioExistente } = await supabase
      .from('usuario')
      .select('id_usuario')
      .ilike('email', cleanEmail)
      .maybeSingle();

    if (usuarioExistente) {
      return res.status(400).json({ error: 'El email ingresado ya está registrado.' });
    }

    // 3. Encriptar contraseña
    const saltRounds = 10;
    const contrasenaHash = await bcrypt.hash(contrasena, saltRounds);

    // 4. Insertar el Usuario (Dueño)
    const { data: nuevoUsuario, error: errorUser } = await supabase
      .from('usuario')
      .insert([
        {
          nombre: nombre.trim(),
          apellido: apellido.trim(),
          email: cleanEmail,
          contrasena: contrasenaHash,
          rol: 'dueño',
          estado: 'activo',
          fecha_creacion: new Date().toISOString()
        }
      ])
      .select('id_usuario, nombre, apellido, email, rol, estado, fecha_creacion')
      .single();

    if (errorUser) {
      return res.status(500).json({ error: 'Error al registrar el usuario: ' + errorUser.message });
    }

    // 5. Insertar el Gimnasio si se proporcionó nombreGimnasio y vincular al id_usuario
    let nuevoGimnasio = null;
    if (nombreGimnasio && nombreGimnasio.trim()) {
      const { data: gymData, error: errorGym } = await supabase
        .from('gimnasio')
        .insert([
          {
            nombre: nombreGimnasio.trim(),
            direccion: direccion ? direccion.trim() : null,
            telefono: telefono ? telefono.trim() : null,
            email: emailGimnasio ? emailGimnasio.trim().toLowerCase() : cleanEmail,
            fecha_registro: new Date().toISOString(),
            estado: 'activo',
            id_usuario: nuevoUsuario.id_usuario
          }
        ])
        .select()
        .single();

      if (errorGym) {
        return res.status(500).json({ error: 'Error al registrar el gimnasio: ' + errorGym.message });
      }
      nuevoGimnasio = gymData;
    }

    // 6. Generar Token JWT para iniciar sesión automáticamente tras el registro
    const jwtSecret = process.env.JWT_SECRET || 'gymtrack_jwt_secret_key_2026';
    const expiresIn = process.env.JWT_EXPIRES_IN || '24h';

    const token = jwt.sign(
      {
        id_usuario: nuevoUsuario.id_usuario,
        id_gimnasio: nuevoGimnasio ? nuevoGimnasio.id_gimnasio : null,
        email: nuevoUsuario.email,
        rol: nuevoUsuario.rol
      },
      jwtSecret,
      { expiresIn }
    );

    // 7. Respuesta exitosa 
    return res.status(201).json({
      mensaje: nuevoGimnasio
        ? 'Dueño y Gimnasio registrados exitosamente.'
        : 'Usuario registrado exitosamente.',
      token,
      usuario: {
        ...nuevoUsuario,
        gimnasio: nuevoGimnasio
      },
      gimnasio: nuevoGimnasio
    });

  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor: ' + error.message });
  }
};

/**
 * Valida credenciales, comprueba contraseña con bcrypt y genera token JWT
 */
const login = async (req, res) => {
  try {
    const { email, contrasena, password } = req.body;
    const passwordInput = contrasena || password;

    if (!email || !passwordInput) {
      return res.status(400).json({ 
        error: 'Por favor, proporciona tanto el email como la contraseña.' 
      });
    }

    const cleanEmail = email.trim().toLowerCase();

    if (!EMAIL_REGEX.test(cleanEmail)) {
      return res.status(400).json({ 
        error: 'El formato del email ingresado no es válido.' 
      });
    }

    // 1. Buscar al usuario por su email
    const { data: usuario, error: errorUsuario } = await supabase
      .from('usuario')
      .select('id_usuario, nombre, apellido, email, contrasena, rol, estado, fecha_creacion')
      .ilike('email', cleanEmail)
      .maybeSingle();

    if (errorUsuario) {
      return res.status(500).json({ 
        error: 'Error al consultar la base de datos: ' + errorUsuario.message 
      });
    }

    if (!usuario) {
      return res.status(401).json({ 
        error: 'Credenciales inválidas. Verifica tu email y contraseña.' 
      });
    }

    if (usuario.estado !== 'activo') {
      return res.status(403).json({ 
        error: 'Tu cuenta se encuentra inactiva o suspendida. Por favor, contacta al administrador.' 
      });
    }

    // 2. Comparar la contraseña con bcrypt
    const passwordValida = await bcrypt.compare(passwordInput, usuario.contrasena);

    if (!passwordValida) {
      return res.status(401).json({ 
        error: 'Credenciales inválidas. Verifica tu email y contraseña.' 
      });
    }

    // 3. Buscar el gimnasio asociado al usuario (si existe)
    const { data: gimnasio } = await supabase
      .from('gimnasio')
      .select('id_gimnasio, nombre, direccion, telefono, estado')
      .eq('id_usuario', usuario.id_usuario)
      .maybeSingle();

    // 4. Generar token JWT
    const jwtSecret = process.env.JWT_SECRET || 'gymtrack_jwt_secret_key_2026';
    const expiresIn = process.env.JWT_EXPIRES_IN || '24h';

    const tokenPayload = {
      id_usuario: usuario.id_usuario,
      id_gimnasio: gimnasio ? gimnasio.id_gimnasio : null,
      email: usuario.email,
      rol: usuario.rol
    };

    const token = jwt.sign(tokenPayload, jwtSecret, { expiresIn });

    // 5. Devolver datos al cliente
    const usuarioSeguro = {
      id_usuario: usuario.id_usuario,
      nombre: usuario.nombre,
      apellido: usuario.apellido,
      email: usuario.email,
      rol: usuario.rol,
      estado: usuario.estado,
      fecha_creacion: usuario.fecha_creacion,
      gimnasio: gimnasio || null
    };

    return res.status(200).json({
      mensaje: 'Inicio de sesión exitoso.',
      token,
      usuario: usuarioSeguro
    });

  } catch (error) {
    return res.status(500).json({ 
      error: 'Error interno del servidor al procesar el inicio de sesión: ' + error.message 
    });
  }
};

/**
 * Valida email, DNI y contraseña directamente en la tabla socio.
 */
const loginSocio = async (req, res) => {
  try {
    const { email, dni, contrasena, password } = req.body;
    const passwordInput = contrasena || password;

    // 1. Validar campos requeridos
    if (!email || !dni || !passwordInput) {
      return res.status(400).json({
        error: 'El correo electrónico, DNI y contraseña son obligatorios.'
      });
    }

    const cleanEmail = email.trim().toLowerCase();
    const cleanDni = dni.toString().trim();

    // 2. Buscar al socio por email y DNI en la tabla socio
    const { data: socio, error: socioError } = await supabase
      .from('socio')
      .select('id_socio, id_gimnasio, dni, telefono, fecha_alta, estado, nombre, apellido, email, contrasena')
      .ilike('email', cleanEmail)
      .eq('dni', cleanDni)
      .maybeSingle();

    if (socioError) {
      return res.status(500).json({
        error: 'Error al consultar la base de datos de socios: ' + socioError.message
      });
    }

    if (!socio) {
      return res.status(401).json({
        error: 'Credenciales inválidas. Verifique su correo electrónico y DNI.'
      });
    }

    // 3. Verificar estado del socio (Debe ser activo)
    if (socio.estado?.toLowerCase() !== 'activo') {
      return res.status(403).json({
        error: 'El socio se encuentra inactivo. Comuníquese con la administración del gimnasio.'
      });
    }

    // 4. Verificar que tenga una contraseña asignada
    if (!socio.contrasena) {
      return res.status(401).json({
        error: 'Este socio aún no tiene una contraseña asignada. Solicite su registro en el gimnasio.'
      });
    }

    // 5. Verificar contraseña con bcrypt
    let passwordValida = false;
    try {
      passwordValida = await bcrypt.compare(passwordInput, socio.contrasena);
    } catch {
      passwordValida = false;
    }

    // Fallback de contingencia en caso de coincidencia directa
    if (!passwordValida && passwordInput === socio.contrasena) {
      passwordValida = true;
    }

    if (!passwordValida) {
      return res.status(401).json({
        error: 'Credenciales inválidas. Contraseña incorrecta.'
      });
    }

    // 6. Consultar datos del gimnasio asociado
    let gimnasio = null;
    if (socio.id_gimnasio) {
      const { data: gymData } = await supabase
        .from('gimnasio')
        .select('id_gimnasio, nombre, direccion, telefono, estado')
        .eq('id_gimnasio', socio.id_gimnasio)
        .maybeSingle();
      gimnasio = gymData;
    }

    // 7. Generar Token JWT
    const jwtSecret = process.env.JWT_SECRET || 'gymtrack_jwt_secret_key_2026';
    const expiresIn = process.env.JWT_EXPIRES_IN || '24h';

    const tokenPayload = {
      id_socio: socio.id_socio,
      id_gimnasio: socio.id_gimnasio,
      dni: socio.dni,
      email: socio.email,
      rol: 'socio'
    };

    const token = jwt.sign(tokenPayload, jwtSecret, { expiresIn });

    const socioSeguro = {
      id_socio: socio.id_socio,
      id_gimnasio: socio.id_gimnasio,
      nombre: socio.nombre,
      apellido: socio.apellido,
      dni: socio.dni,
      email: socio.email,
      telefono: socio.telefono,
      estado: socio.estado,
      rol: 'socio',
      gimnasio
    };

    // 8. Devolver respuesta exitosa
    return res.status(200).json({
      mensaje: 'Inicio de sesión exitoso.',
      token,
      usuario: socioSeguro,
      socio: socioSeguro
    });

  } catch (error) {
    return res.status(500).json({
      error: 'Error interno del servidor al procesar el inicio de sesión del socio: ' + error.message
    });
  }
};

/**
 * CONTROLADOR: OBTENER PERFIL DEL USUARIO AUTENTICADO
 */
const getMe = async (req, res) => {
  try {
    const idUsuario = req.usuario?.id_usuario;
    const idSocio = req.usuario?.id_socio;

    if (!idUsuario && !idSocio) {
      return res.status(401).json({ error: 'Usuario no autenticado.' });
    }

    if (idSocio) {
      const { data: socio, error: socioErr } = await supabase
        .from('socio')
        .select('id_socio, id_gimnasio, dni, telefono, fecha_alta, estado, nombre, apellido, email')
        .eq('id_socio', idSocio)
        .maybeSingle();

      if (socioErr || !socio) {
        return res.status(404).json({ error: 'Socio no encontrado.' });
      }

      let gimnasio = null;
      if (socio.id_gimnasio) {
        const { data: gymData } = await supabase
          .from('gimnasio')
          .select('id_gimnasio, nombre, direccion, telefono, estado')
          .eq('id_gimnasio', socio.id_gimnasio)
          .maybeSingle();
        gimnasio = gymData;
      }

      return res.status(200).json({
        usuario: {
          ...socio,
          rol: 'socio',
          gimnasio
        }
      });
    }

    const { data: usuario, error: errorUsuario } = await supabase
      .from('usuario')
      .select('id_usuario, nombre, apellido, email, rol, estado, fecha_creacion')
      .eq('id_usuario', idUsuario)
      .maybeSingle();

    if (errorUsuario || !usuario) {
      return res.status(404).json({ error: 'Usuario no encontrado.' });
    }

    const { data: gimnasio } = await supabase
      .from('gimnasio')
      .select('id_gimnasio, nombre, direccion, telefono, estado')
      .eq('id_usuario', usuario.id_usuario)
      .maybeSingle();

    usuario.gimnasio = gimnasio || null;

    return res.status(200).json({
      usuario
    });
  } catch (error) {
    return res.status(500).json({ error: 'Error al obtener datos del perfil: ' + error.message });
  }
};

module.exports = {
  registerOwner,
  login,
  loginSocio,
  getMe
};