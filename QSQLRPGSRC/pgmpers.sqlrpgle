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
  //Entrada
  I_JSON CHAR(32740);
  //Salida
  O_JSON CHAR(32740);
END-PI;
// estudios de una persona
// direcciones de una persona
// obtener todas las personas


// ================== Definicion de archivo de pantalla =======================

// ================= Definicion de estructuras de datos =======================
DCL-DS educacion QUALIFIED;
    nivel        VARCHAR(20);
    instituto    VARCHAR(50);
    anio_inicio  INT(5);
    anio_final   INT(5);
END-DS;
// CLEAR educacion;

DCL-DS persona QUALIFIED;
    identidad   VARCHAR(18);
    nombre      VARCHAR(50);
    edad        INT(5);
    genero      VARCHAR(20);
    estudios    likeds(educacion) DIM(5);
// $estudios(*NEXT) = educacion;

// CREAR estructura en tiempo de ejecucion
// ================= Definicion de variables globales =========================
dcl-s $estudios like(educacion) dim(*AUTO:5);
dcl-s myJSON CHAR(1500);

// ======================== Programa principal ================================
CLEAR persona.estudios;
persona.identidad = '0801199701738';
persona.nombre = 'Cristian Jeanluc Boquin';
persona.edad = 29;
persona.genero = 'Masculino';

educacion.nivel = 'Secundaria';
educacion.instituto = 'Instituto Emiliani';
educacion.anio_inicio = 2009;
educacion.anio_final = 2014;

$estudios(*NEXT) = educacion;
// persona.estudios(1) = educacion;
CLEAR educacion;

educacion.nivel = 'Universitaria';
educacion.instituto = 'Universidad Nacional Autonoma de Honduras';
educacion.anio_inicio = 2015;
educacion.anio_final = 2022;

$estudios(*NEXT) = educacion;
// persona.estudios(2) = educacion;
CLEAR educacion;

persona.estudios = $estudios;

DATA-GEN persona %DATA(myJSON) %GEN('YAJLDTAGEN');

*INLR = *ON;
// ============================================================================


// =========================== Procesos internos ==============================
// ============================================================================
// -- Procedimiento: x
// -- Descripcion..:
// ============================================================================
DCL-PROC x;
END-PROC x;


