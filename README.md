# Hotel Booking System Database

## 📝 Descripción general

Este proyecto consistió en el diseño e implementación de una **base de datos normalizada** para una cadena hotelera con múltiples sucursales. Su objetivo fue permitir una **gestión centralizada y eficiente** de usuarios, habitaciones y reservas, resolviendo problemas como el *overbooking* y la pérdida de oportunidades por falta de sincronización entre las distintas sucursales.

La base permite realizar consultas clave para la **toma de decisiones** en la empresa, incluyendo:

- Disponibilidad de habitaciones en tiempo real
- Historial de reservas por cliente o por hotel
- Promociones activas
- Servicios ofrecidos por cada sede
- Reportes estratégicos para mejorar la ocupación y rentabilidad

El proyecto simula un entorno real de operación, integrando criterios de **modelado relacional**, **normalización** y **análisis de requerimientos**, inspirado en plataformas de reservas hoteleras modernas.

---

## 📁 Estructura del proyecto

- `diagrama_clases_uml.pdf`  
  Representación visual del modelo de clases y relaciones entre entidades clave.

- `script_construccion.sql`  
  Script en formato *MySQL Dump* que crea la estructura completa de la base de datos:

  - Tablas normalizadas
  - Llaves primarias y foráneas
  - Tipos de datos adecuados
  - Inserción de datos ficticios representativos para simular un entorno de operación real

- `consultas_relevantes.sql`  
  Archivo que contiene 10 consultas SQL diseñadas para responder preguntas estratégicas orientadas a la toma de decisiones operativas y administrativas dentro de la cadena hotelera, tales como:

  - Estado y mantenimiento de habitaciones por tipo y hotel
  - Promociones activas y disponibilidad por región
  - Comportamiento de clientes: frecuencia de reserva y gasto acumulado
  - Estadísticas de ocupación y servicios ofrecidos
  - Análisis de cancelaciones, métodos de pago y tendencias por temporada

---

## ⚙️ Requisitos

- MySQL Server 8.0+ (o equivalente)

---

## 🚀 Instrucciones de uso

1. Ejecutar `script_construccion.sql` para construir la estructura e insertar los datos simulados.
2. Ejecutar `consultas_relevantes.sql` para validar la funcionalidad del modelo y probar los casos de uso del sistema.

---

## 👩‍💻 Autores

Proyecto académico desarrollado para el curso de *Bases de Datos* en colaboración con:

- Valeria Cano Soto (valecanosoto@ciencias.unam.mx)
- Enrique Jesús Mauro Magaña Solís (Jesusmagana@ciencias.unam.mx)
- Ana Karina Martínez Mejía (anak.martinez@ciencias.unam.mx)

Facultad de Ciencias, UNAM – Junio 2025

---

## 📄 Licencia

Uso educativo y demostrativo. Se permite su modificación y reutilización con fines no comerciales.
