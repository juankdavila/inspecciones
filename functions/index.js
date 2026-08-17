const {setGlobalOptions} = require("firebase-functions");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {initializeApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");
const {getFirestore} = require("firebase-admin/firestore");

setGlobalOptions({
  maxInstances: 10,
});

initializeApp();

const db = getFirestore();
const auth = getAuth();

/**
 * Crea un nuevo inspector.
 *
 * El usuario que ejecuta esta función debe:
 * 1. Estar autenticado.
 * 2. Tener rol "admin" en Firestore.
 */
exports.crearInspector = onCall(async (request) => {
  // ============================================================
  // 1. VERIFICAR AUTENTICACIÓN
  // ============================================================

  if (!request.auth) {
    throw new HttpsError(
        "unauthenticated",
        "Debes iniciar sesión para realizar esta acción.",
    );
  }

  const uidAdministrador = request.auth.uid;

  // ============================================================
  // 2. VERIFICAR QUE SEA ADMINISTRADOR
  // ============================================================

  const adminDoc = await db
      .collection("usuarios")
      .doc(uidAdministrador)
      .get();

  if (!adminDoc.exists) {
    throw new HttpsError(
        "permission-denied",
        "No se encontró el usuario administrador.",
    );
  }

  const adminData = adminDoc.data();

  if (
    adminData.rol !== "admin" ||
    adminData.activo !== true
  ) {
    throw new HttpsError(
        "permission-denied",
        "No tienes permisos para crear inspectores.",
    );
  }

  // ============================================================
  // 3. RECIBIR DATOS
  // ============================================================

  const {
    nombre,
    usuario,
    password,
  } = request.data || {};

  const nombreLimpio = String(nombre || "").trim();
  const usuarioLimpio = String(usuario || "").trim();

  // ============================================================
  // 4. VALIDACIONES
  // ============================================================

  if (!nombreLimpio) {
    throw new HttpsError(
        "invalid-argument",
        "El nombre del inspector es obligatorio.",
    );
  }

  if (nombreLimpio.length < 3) {
    throw new HttpsError(
        "invalid-argument",
        "El nombre del inspector es demasiado corto.",
    );
  }

  if (!usuarioLimpio) {
    throw new HttpsError(
        "invalid-argument",
        "El usuario es obligatorio.",
    );
  }

  if (usuarioLimpio.length < 3) {
    throw new HttpsError(
        "invalid-argument",
        "El usuario debe tener al menos 3 caracteres.",
    );
  }

  if (/\s/.test(usuarioLimpio)) {
    throw new HttpsError(
        "invalid-argument",
        "El usuario no puede contener espacios.",
    );
  }

  if (typeof password !== "string" || password.length < 6) {
    throw new HttpsError(
        "invalid-argument",
        "La contraseña debe tener al menos 6 caracteres.",
    );
  }

  // ============================================================
  // 5. CREAR CORREO INTERNO PARA FIREBASE AUTH
  // ============================================================
  //
  // El usuario que escribe el administrador puede ser:
  //
  //     jperez
  //
  // Firebase Authentication necesita un email para este proyecto.
  //
  // Utilizaremos un dominio interno que no se muestra
  // como correo de contacto.
  //

  const email = `${usuarioLimpio.toLowerCase()}@inspectores.local`;

  let nuevoUsuario;

  try {
    // ==========================================================
    // 6. CREAR USUARIO EN FIREBASE AUTHENTICATION
    // ==========================================================

    nuevoUsuario = await auth.createUser({
      email: email,
      password: password,
      displayName: nombreLimpio,
      disabled: false,
    });
  } catch (error) {
    console.error("Error creando usuario:", error);

    if (error.code === "auth/email-already-exists") {
      throw new HttpsError(
          "already-exists",
          "El nombre de usuario ya está registrado.",
      );
    }

    if (error.code === "auth/invalid-password") {
      throw new HttpsError(
          "invalid-argument",
          "La contraseña no cumple los requisitos.",
      );
    }

    throw new HttpsError(
        "internal",
        "No se pudo crear el usuario.",
    );
  }

  // ============================================================
  // 7. GUARDAR DATOS EN FIRESTORE
  // ============================================================

  try {
    await db
        .collection("usuarios")
        .doc(nuevoUsuario.uid)
        .set({
          uid: nuevoUsuario.uid,
          nombre: nombreLimpio,
          usuario: usuarioLimpio,
          rol: "inspector",
          activo: true,
          creadoEn: new Date(),
        });
  } catch (error) {
    console.error("Error guardando inspector:", error);

    // Si Firestore falla después de crear Authentication,
    // eliminamos el usuario para evitar dejar información
    // incompleta.

    try {
      await auth.deleteUser(nuevoUsuario.uid);
    } catch (deleteError) {
      console.error(
          "No se pudo eliminar el usuario incompleto:",
          deleteError,
      );
    }

    throw new HttpsError(
        "internal",
        "No se pudo guardar la información del inspector.",
    );
  }

  // ============================================================
  // 8. RESPUESTA
  // ============================================================

  return {
    success: true,
    uid: nuevoUsuario.uid,
    nombre: nombreLimpio,
    usuario: usuarioLimpio,
    rol: "inspector",
    activo: true,
  };
});
