// ==============================================================================
// ARCHIVO: paymentGatewayService.js
// PROYECTO: GYMTRACK - Backend
// DESCRIPCIÓN: Servicio de Integración de Pasarelas de Pago Digitales (Mercado Pago y Ualá).
// ==============================================================================
// 
// GUÍA DE ARQUITECTURA DE MERCADO PAGO PARA EL DESARROLLADOR:
// 1. FLUJO CHECKOUT PRO (Mercado Pago):
//    - El backend genera una "Preferencia" en la API de Mercado Pago (`/checkout/preferences`).
//    - La preferencia encapsula el monto en ARS, datos del socio (DNI, email, nombre), descripción
//      del plan de entrenamiento y URLs de retorno (`back_urls`).
//    - Mercado Pago responde con:
//        * `id`: ID único de la preferencia en los servidores de Mercado Pago.
//        * `init_point`: URL de pago oficial en producción (permite pagar con tarjeta, saldo MP, Rapipago, etc.).
//        * `sandbox_init_point`: URL de pruebas para desarrolladores en entorno de pruebas.
// 2. REFERENCIA EXTERNA (external_reference):
//    - Generamos un identificador unívoco: `GYM-{id_gimnasio}-SOC-{id_socio}-PL-{id_plan}-{timestamp}`.
//    - Esta clave viaja a Mercado Pago y regresa en los callbacks y webhooks para asociar la transacción
//      con el socio y plan correctos de forma 100% confiable e idempotente.
// 3. RETORNO Y REDIRECCIÓN (back_urls):
//    - `success`: Redirige al alumno a `/membresia-socio?pago_status=approved&ref=...` al pagar.
//    - `pending`: En pagos en efectivo pendientes de acreditación.
//    - `failure`: Si la tarjeta fue rechazada o el usuario canceló la operación.
// 4. MODO FALLBACK (Sandbox Simulado):
//    - Si no existe un Access Token de producción (`APP_USR-...`), el sistema conmuta automáticamente
//      a un entorno simulado interactivo, generando links de prueba y códigos QR válidos para desarrollo.
// ==============================================================================

const MERCADOPAGO_ACCESS_TOKEN = process.env.MERCADOPAGO_ACCESS_TOKEN || process.env.Token_Mer || process.env.Api_MER || '';
const UALA_CLIENT_ID = process.env.UALA_CLIENT_ID || '';
const UALA_CLIENT_SECRET = process.env.UALA_CLIENT_SECRET || '';
const FRONTEND_URL = process.env.FRONTEND_URL || 'http://localhost:5173';

/**
 * Genera una preferencia de pago en la API de Mercado Pago (Checkout Pro).
 * 
 * @param {Object} params - Parámetros de la orden de cobro
 * @param {string} params.titulo - Nombre del plan de membresía o concepto (ej: 'Pase Libre Musculación')
 * @param {number} params.monto - Importe exacto a cobrar en pesos argentinos (ARS)
 * @param {string} params.externalReference - Identificador único de trazabilidad GymTrack
 * @param {Object} params.socio - Datos de filiación del alumno (nombre, apellido, email, dni)
 * @param {Object} params.gimnasio - Metadatos institucionales del gimnasio emisor
 * @returns {Promise<Object>} Objeto con init_point, id_preferencia, qr_codigo y modo de ejecución
 */
async function crearPreferenciaMercadoPago({ titulo, monto, externalReference, socio, gimnasio }) {
  const precioUnitario = Number(monto);

  // ---------------------------------------------------------------------------------------
  // PASO 1: CONEXIÓN CON LA API EN VIVO DE MERCADO PAGO (Si hay Token APP_USR configurado)
  // ---------------------------------------------------------------------------------------
  if (MERCADOPAGO_ACCESS_TOKEN && MERCADOPAGO_ACCESS_TOKEN.startsWith('APP_USR-')) {
    try {
      // POST a la API oficial de Mercado Pago para registrar la preferencia de Checkout Pro
      const response = await fetch('https://api.mercadopago.com/checkout/preferences', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${MERCADOPAGO_ACCESS_TOKEN}`
        },
        body: JSON.stringify({
          // Ítems a cobrar (detalle del plan de gimnasio)
          items: [
            {
              id: externalReference,
              title: `${titulo} - ${gimnasio?.nombre || 'GymTrack'}`,
              description: `Membresía en ${gimnasio?.nombre || 'GymTrack'} para ${socio.nombre} ${socio.apellido}`,
              quantity: 1,
              currency_id: 'ARS',
              unit_price: precioUnitario
            }
          ],
          // Datos del pagador (utilizados por Mercado Pago para precompletar el formulario de tarjeta)
          payer: {
            name: socio.nombre,
            surname: socio.apellido,
            email: socio.email || 'socio@gymtrack.com',
            identification: {
              type: 'DNI',
              number: String(socio.dni || '00000000')
            }
          },
          // Clave de correlación única para conciliar el pago en el webhook / verificación
          external_reference: externalReference,
          // URLs a las que Mercado Pago redirige al socio tras completar o cancelar el checkout
          back_urls: {
            success: `${FRONTEND_URL}/membresia-socio?pago_status=approved&ref=${externalReference}`,
            pending: `${FRONTEND_URL}/membresia-socio?pago_status=pending&ref=${externalReference}`,
            failure: `${FRONTEND_URL}/membresia-socio?pago_status=rejected&ref=${externalReference}`
          }
        })
      });

      // Si Mercado Pago responde 200/201 OK, devolvemos las URLs de pago reales
      if (response.ok) {
        const mpData = await response.json();
        return {
          proveedor: 'mercadopago',
          modo: 'api_real',
          id_preferencia: mpData.id,
          init_point: mpData.init_point,                               // URL oficial de cobro
          sandbox_init_point: mpData.sandbox_init_point || mpData.init_point, // URL para cuentas de test
          external_reference: externalReference,
          monto: precioUnitario,
          qr_codigo: `https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${encodeURIComponent(mpData.init_point)}`
        };
      }
    } catch (err) {
      console.warn('Fallo al conectar con la API en vivo de Mercado Pago, usando fallback simulado:', err.message);
    }
  }

  // ---------------------------------------------------------------------------------------
  // PASO 2: MODO SANDBOX / FALLBACK SIMULADO (Para desarrollo local y pruebas sin credenciales)
  // ---------------------------------------------------------------------------------------
  // Genera una preferencia sintética que simula el proceso de pago en la UI sin requerir dinero real
  const mockPrefId = `MP-PREF-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
  const mockCheckoutUrl = `${FRONTEND_URL}/membresia-socio?checkout=mercadopago&ref=${externalReference}&pref=${mockPrefId}&monto=${precioUnitario}`;

  return {
    proveedor: 'mercadopago',
    modo: 'sandbox_simulado',
    id_preferencia: mockPrefId,
    init_point: mockCheckoutUrl,
    sandbox_init_point: mockCheckoutUrl,
    external_reference: externalReference,
    monto: precioUnitario,
    qr_codigo: `https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${encodeURIComponent(mockCheckoutUrl)}`,
    mensaje: 'Sesión de Mercado Pago preparada correctamente.'
  };
}

/**
 * Genera una orden de cobro para Ualá (Ualá Bis).
 * @param {Object} params
 * @param {string} params.titulo - Nombre del plan o concepto
 * @param {number} params.monto - Precio a cobrar en ARS
 * @param {string} params.externalReference - ID o referencia única del pago
 * @param {Object} params.socio - Datos del socio pagador
 * @param {Object} params.gimnasio - Datos del gimnasio
 */
async function crearOrdenUala({ titulo, monto, externalReference, socio, gimnasio }) {
  const precioUnitario = Number(monto);

  // Si hay credenciales reales de Ualá Bis, intentamos conectar
  if (UALA_CLIENT_ID && UALA_CLIENT_SECRET) {
    try {
      // 1. Obtener token de Ualá
      const authRes = await fetch('https://auth.prod.bis.com.ar/connect/token', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
          grant_type: 'client_credentials',
          client_id: UALA_CLIENT_ID,
          client_secret: UALA_CLIENT_SECRET
        })
      });

      if (authRes.ok) {
        const authData = await authRes.json();
        const orderRes = await fetch('https://api.prod.bis.com.ar/v2/checkout/order', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${authData.access_token}`
          },
          body: JSON.stringify({
            amount: precioUnitario,
            description: `${titulo} - ${gimnasio?.nombre || 'GymTrack'}`,
            userName: socio.email || `${socio.nombre}.${socio.apellido}@gymtrack.com`,
            callback_fail: `${FRONTEND_URL}/socio/membresia?pago_status=rejected&ref=${externalReference}`,
            callback_success: `${FRONTEND_URL}/socio/membresia?pago_status=approved&ref=${externalReference}`,
            notification_url: `${FRONTEND_URL}/api/socio/pagos/webhook?proveedor=uala`,
            external_reference: externalReference
          })
        });

        if (orderRes.ok) {
          const ualaData = await orderRes.json();
          return {
            proveedor: 'uala',
            modo: 'api_real',
            id_orden: ualaData.order_id || ualaData.id,
            init_point: ualaData.links?.checkoutLink || ualaData.url,
            external_reference: externalReference,
            monto: precioUnitario,
            qr_codigo: `https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${encodeURIComponent(ualaData.links?.checkoutLink || '')}`
          };
        }
      }
    } catch (err) {
      console.warn('Fallo al conectar con la API en vivo de Ualá, usando fallback simulado:', err.message);
    }
  }

  // Modo Sandbox/Simulado listo para operar de inmediato
  const mockOrderId = `UALA-ORD-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
  const mockCheckoutUrl = `${FRONTEND_URL}/socio/membresia?checkout=uala&ref=${externalReference}&order=${mockOrderId}&monto=${precioUnitario}`;

  return {
    proveedor: 'uala',
    modo: 'sandbox_simulado',
    id_orden: mockOrderId,
    init_point: mockCheckoutUrl,
    external_reference: externalReference,
    monto: precioUnitario,
    qr_codigo: `https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${encodeURIComponent(mockCheckoutUrl)}`,
    mensaje: 'Orden de cobro Ualá preparada correctamente.'
  };
}

module.exports = {
  crearPreferenciaMercadoPago,
  crearOrdenUala
};
