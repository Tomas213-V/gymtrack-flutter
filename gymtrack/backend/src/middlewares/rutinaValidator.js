// backend/src/middlewares/rutinaValidator.js

exports.validateRutina = (req, res, next) => {
  const { nombre } = req.body;
  if (!nombre || typeof nombre !== 'string' || nombre.trim() === '') {
    return res.status(400).json({ error: 'El campo "nombre" es obligatorio y no puede estar vacío.' });
  }
  next();
};

exports.validateEjercicioAsociacion = (req, res, next) => {
  const { id_ejercicio, series, serie, repeticiones } = req.body;

  if (!id_ejercicio || isNaN(Number(id_ejercicio))) {
    return res.status(400).json({ error: 'El id_ejercicio es obligatorio y debe ser numérico.' });
  }

  const numSeries = series !== undefined ? series : serie;
  if (numSeries !== undefined && (isNaN(Number(numSeries)) || Number(numSeries) <= 0)) {
    return res.status(400).json({ error: 'Las series deben ser un número entero mayor a 0.' });
  }

  if (repeticiones !== undefined && (isNaN(Number(repeticiones)) || Number(repeticiones) <= 0)) {
    return res.status(400).json({ error: 'Las repeticiones deben ser un número entero mayor a 0.' });
  }

  next();
};