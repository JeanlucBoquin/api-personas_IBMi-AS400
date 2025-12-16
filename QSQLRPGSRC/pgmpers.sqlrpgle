**FREE
// ============================================================================
// -- Programa.....: PGMPERS
// -- Descripcion..: API basico de personas
// -- Desarrollador: Jeanluc Boquin
// -- Fecha........: 08 de diciembre del 2025
// STRDBG PGM(CJB4033071/PGMPERS) UPDPROD(*YES) OPMSRC(*YES)
// ============================================================================


// ======================= Control de opciones ================================
CTL-OPT DFTACTGRP(*NO) ACTGRP(*CALLER) OPTION(*SRCSTMT:*NODEBUGIO);

// Definir parametros de entrada
DCL-PI *N;
  I_JSON CHAR(80);    //JSON entrada
  O_JSON VARCHAR(32740); //JSON salida
END-PI;

// ================== Definicion de archivo de pantalla =======================

// ================= Definicion de estructuras de datos =======================
DCL-DS datosEntrada QUALIFIED;
  metodo VARCHAR(25);
  id VARCHAR(18);
END-DS;

// ================= Definicion de variables globales =========================


// ======================== Programa principal ================================
DATA-INTO datosEntrada %DATA(I_JSON) %PARSER('YAJL/YAJLINTO');

SELECT;
  WHEN %TRIM(datosEntrada.metodo) = 'obtenerPersonas';
    O_JSON = obtenerPersonas();
  WHEN %TRIM(datosEntrada.metodo) = 'obtenerEsdudiosPersona' AND
       %TRIM(datosEntrada.id) <> '';
    O_JSON = obtenerEsdudiosPersona(datosEntrada.id);
  WHEN %TRIM(datosEntrada.metodo) = 'obtenerDireccionesPersona' AND
       %TRIM(datosEntrada.id) <> '';
    O_JSON = obtenerDireccionesPersona(datosEntrada.id);
  OTHER;
     O_JSON = '{status: "error", code: "404 Not Found"}';
ENDSL;

*INLR = *ON;
// ============================================================================


// =========================== Procesos internos ==============================
// ============================================================================
// -- Procedimiento: obtenerPersonas
// -- Descripcion..: Obtener todas las personas registradas en la tabla
//                   PERSONAS
// ============================================================================
DCL-PROC obtenerPersonas;
  DCL-PI obtenerPersonas VARCHAR(32740);
  END-PI;
  DCL-S myJSON VARCHAR(32740);

  EXEC SQL
  SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'ide'    VALUE TRIM(P.IDEPER),
                'nombre' VALUE TRIM(P.NOMPER),
                'edad'   VALUE TRIM(P.EDAPER),
                'genero' VALUE TRIM(P.GENPER)
            )
         ) AS personas_json
         INTO :myJSON
      FROM CJB4033071.PERSONA P;

  SQLSTATE = SQLSTATE;
  IF SQLSTATE = '00000';
    RETURN myJSON;
  ELSE;
    RETURN '{status: "error SELECT", code: ' + SQLSTATE + '}';
  ENDIF;
END-PROC obtenerPersonas;

// ============================================================================
// -- Procedimiento: obtenerEsdudiosPersona
// -- Descripcion..: Obtener todos los estudios de una persona
// ============================================================================
DCL-PROC obtenerEsdudiosPersona;
  DCL-PI obtenerEsdudiosPersona VARCHAR(32740);
    identidad VARCHAR(18);
  END-PI;
  DCL-S myJSON VARCHAR(32740);

  EXEC SQL
  SELECT JSON_OBJECT(
        'identidad'  VALUE TRIM(P.IDEPER),
         'nombre'    VALUE TRIM(P.NOMPER),
         'edad'      VALUE TRIM(P.EDAPER),
         'genero'    VALUE TRIM(P.GENPER),
         'estudios'  VALUE (
                SELECT JSON_ARRAYAGG(
                        JSON_OBJECT(
                          'nivel'       VALUE TRIM(E.NIVEDU),
                          'instituto'   VALUE TRIM(E.INSTIT),
                          'anio_inicio' VALUE TRIM(E.ANIINI),
                          'anio_final'  VALUE TRIM(E.ANIFIN)
                        )
                      )
                  FROM CJB4033071.PEREDU E
                  WHERE E.IDEPER = P.IDEPER
                ) FORMAT JSON
       ) AS persona_con_estudios
      INTO :myJSON
      FROM CJB4033071.PERSONA P
      WHERE P.IDEPER = TRIM(:identidad);

  SQLSTATE = SQLSTATE;
  IF SQLSTATE = '00000';
    RETURN myJSON;
  ELSE;
    RETURN '{status: "error SELECT", code: ' + SQLSTATE + '}';
  ENDIF;
END-PROC obtenerEsdudiosPersona;

// ============================================================================
// -- Procedimiento: obtenerDireccionesPersona
// -- Descripcion..: Obtener todas las direcciones de una persona
// ============================================================================
DCL-PROC obtenerDireccionesPersona;
  DCL-PI obtenerDireccionesPersona VARCHAR(32740);
    identidad VARCHAR(18);
  END-PI;
  DCL-S myJSON VARCHAR(32740);

  EXEC SQL
  SELECT JSON_OBJECT(
            'identidad'   VALUE TRIM(P.IDEPER),
            'nombre'      VALUE TRIM(P.NOMPER),
            'direcciones' VALUE (
              SELECT JSON_ARRAYAGG(
                        JSON_OBJECT(
                          'tipo'          VALUE TRIM(D.TIPDIR),
                          'calle'         VALUE TRIM(D.CALLE),
                          'cuidad'        VALUE TRIM(D.CIUDAD),
                          'departamento'  VALUE TRIM(D.DEPART),
                          'pais'          VALUE TRIM(D.PAIS)
                        )
                    )
              FROM CJB4033071.PERDIR D
              WHERE D.IDEPER = P.IDEPER
            ) FORMAT JSON
        ) AS persona_json
    INTO :myJSON
    FROM CJB4033071.PERSONA P
    WHERE P.IDEPER = TRIM(:identidad);

  SQLSTATE = SQLSTATE;
  IF SQLSTATE = '00000';
    RETURN myJSON;
  ELSE;
    RETURN '{status: "error SELECT", code: ' + SQLSTATE + '}';
  ENDIF;
END-PROC obtenerDireccionesPersona;

