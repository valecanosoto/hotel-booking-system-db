/* =====================================================
-- Proyecto Integrador | Bases de datos

   Contribuidores:
-- Integrante 1: Cano Soto Valeria (valecanosoto@ciencias.unam.mx)
-- Integrante 2: Magaña Solís Enrique Jesús Mauro (Jesusmagana@ciencias.unam.mx)
-- Integrante 3: Martínez Mejía Ana Karina (anak.martinez@ciencias.unam.mx)
*/
-- ========================================================

USE cadena_hotelera

-- 1) Pregunta: ¿Cuántas y cuáles habitaciones de cada tipo se encuentran en mantenimiento por hotel?

/* Explicación: Los ejecutivos requieren saber cuántas y cuáles habitaciones de cada tipo
                se encuentran en mantenimiento por hotel para obtener una estimación del costo total
                acumulado hasta el momento que ha representando para la cadena los trabajos de
                reparación y mantenimiento.
*/

SELECT ho.id_hotel AS "ID Hotel", 
       ho.nombre AS "Nombre Hotel", 
       tipo.tipo AS "Tipo de habitación",
       COUNT(ha.id_habitacion) AS "Cantidad de habitaciones",
       GROUP_CONCAT(ha.numero ORDER BY ha.numero) AS "Números de las habitaciones 'En mantenimiento'"
FROM habitaciones ha
JOIN tipo_habitacion tipo ON ha.clave_tipo = tipo.id_tipo
JOIN hoteles ho ON ha.clave_hotel = ho.id_hotel
WHERE ha.disponibilidad = 'En mantenimiento'
GROUP BY ho.id_hotel, ha.clave_tipo
ORDER BY ho.id_hotel, tipo.tipo;


-- 2) Pregunta: ¿Cuáles son las direcciones de hoteles que tienen 5 estrellas, que cuentan con
--              gimnasio y que se encuentran en CDMX, Jalisco, y Nuevo León?

/* Explicación:  En 2026 será el próximo mundial que se celebrará en México/EU/Canadá, por lo que 
                 queremos saber cuántos hoteles hay en cada ciudad sede para saber si son suficientes
                 y se pueda cumplir con la demanda.
*/

SELECT h.nombre AS 'Nombre del Hotel',
       CONCAT_WS(', ', d.calle, d.num_ext, d.num_int, c.nombre, m.nombre, e.nombre) AS 'Dirección del Hotel',
       h.categoria AS 'Categoría'
FROM hoteles h
JOIN direcciones d ON h.clave_direccion = d.id_direccion
JOIN colonias c ON d.clave_colonia = c.id_colonia
JOIN municipios m ON c.clave_mun = m.id_municipio
JOIN estados e ON m.clave_estado = e.id_estado
JOIN hoteles_servicios hs ON h.id_hotel = hs.clave_hotel
JOIN servicios s ON hs.clave_servicio = s.id_servicio
WHERE h.categoria = '5'
      AND s.nombre = 'gimnasio'
      AND e.nombre IN ('Ciudad de México', 'Jalisco', 'Nuevo León');


-- 3) Pregunta: ¿Cuántas reservas ha hecho cada cliente y cuál es su gasto total acumulado?

/* Explicación: Esta consulta es útil para identificar a los clientes más frecuentes y valiosos 
                o que invierten más en la cadena hotelera, lo que permite personalizar
                promociones de anclaje para estos clientes. En este caso, con un número de reservas
                superior a 3.
*/

SELECT c.id_cliente AS 'ID Cliente',
    CONCAT(c.nombre, '  ', c.apellido_paterno, '  ', IFNULL(c.apellido_materno, '')) AS 'Nombre completo',
    COUNT(r.id_reserva) AS 'Total de reservas',
    LPAD(CONCAT('$  ', FORMAT(SUM(r.importe_total),2)),LENGTH('Gasto Total'),'') AS 'Gasto Total'
FROM clientes c
LEFT JOIN reservas r ON c.id_cliente = r.clave_cliente
GROUP BY c.id_cliente
HAVING COUNT(r.id_reserva) > 3
ORDER BY 4 DESC;


-- 4) Pregunta: ¿Cuáles son las promociones que seguirán vigentes hasta julio, en qué hoteles y cuál
--              es el número de reservas confrimadas por hotel para ese entonces?

/* Explicación:  Los ejecutivos desean saber cuál es la tasa de éxito de las nuevas promociones
                 basados en la cantidad de reservas que se confirmaron por hotel para el siguiente
                 periodo vacacional.
*/

SELECT hp.clave_hotel AS "ID Hotel",
       ho.nombre AS "Nombre Hotel",
       JSON_OBJECTAGG(pr.descripcion, pr.fecha_fin) AS "Promociones vigentes + Fecha de término",
       IFNULL(RC.total_reservas, 0) AS "Reservas confirmadas para julio, 2025"
FROM hoteles_promociones hp
JOIN hoteles ho ON hp.clave_hotel = ho.id_hotel
JOIN promociones pr ON hp.clave_promocion = pr.id_promocion
LEFT JOIN (
    SELECT ho.id_hotel, COUNT(r.id_reserva) AS total_reservas
    FROM reservas r
    JOIN habitaciones ha ON r.clave_habitacion = ha.id_habitacion
    JOIN hoteles ho ON ha.clave_hotel = ho.id_hotel
    WHERE r.estado_reserva = 'Confirmada'
      AND r.fecha_inicio BETWEEN '2025-07-01' AND '2025-07-31'
    GROUP BY ho.id_hotel
) AS RC ON hp.clave_hotel = RC.id_hotel
WHERE pr.fecha_inicio <= '2025-07-01' AND pr.fecha_fin >= '2025-07-01'
GROUP BY hp.clave_hotel, ho.nombre
ORDER BY 4 DESC, 1;


-- 5) Pregunta: ¿Cuál es el método de pago más usado en cada hotel?

/* Explicación: Permite obterner un mejor control administrativo para cada hotel y saber cómo manejar
                de una forma más eficaz los pagos dependiendo del método más utilizado.
*/

SELECT h.nombre AS 'Nombre del hotel',
       p.metodo_pago as 'Método de Pago',
       COUNT(*) AS 'No. de veces usado'
FROM pagos p
JOIN reservas r ON p.clave_reserva = r.id_reserva
JOIN habitaciones hab ON r.clave_habitacion = hab.id_habitacion
JOIN hoteles h ON hab.clave_hotel = h.id_hotel
GROUP BY h.id_hotel, h.nombre, p.metodo_pago
HAVING COUNT(*) = (
    SELECT 
        MAX(subconsulta.cuenta)
    FROM (
        SELECT 
            COUNT(*) AS cuenta
        FROM pagos p2
        JOIN reservas r2 ON p2.clave_reserva = r2.id_reserva
        JOIN habitaciones hab2 ON r2.clave_habitacion = hab2.id_habitacion
        WHERE hab2.clave_hotel = h.id_hotel
        GROUP BY p2.metodo_pago
    ) AS subconsulta)
ORDER BY 3 DESC
LIMIT 50;


-- 6) Pregunta: ¿Cuál es la ocupación total y la estancia promedio por tipo de habitación?

/* Explicación: Esta consulta permite evaluar qué tipos de habitaciones se utilizan más y durante cuánto
                tiempo, lo cual ayuda a ajustar precios y optimizar el inventario.
*/

SELECT
    th.tipo AS 'Tipo de habitación',
    COUNT(r.id_reserva) AS 'Total de reservas',
    ROUND(AVG(DATEDIFF(r.fecha_termino, r.fecha_inicio)), 0) AS 'Duración promedio por días'
FROM tipo_habitacion th
JOIN habitaciones h ON th.id_tipo = h.clave_tipo
JOIN reservas r ON h.id_habitacion = r.clave_habitacion
GROUP BY th.tipo
ORDER BY 2 DESC;


-- 7) Pregunta: ¿Cuál es la ocupación total por hotel en vacaciones decembrinas y de dónde visitan principalmente?

/* Explicación: Los ejecutivos desean conocer la ocupación total por hotel durante diciembre y enero,
                y de qué estados proviene la mayor cantidad de huéspedes en ese periodo para reforzar
                las campañas publicitarias en los estados de procedencia de la mayoría de los clientes.
*/

SELECT SUB.id_h AS "ID Hotel",
       SUB.nombre_h AS "Nombre Hotel",
       GROUP_CONCAT(SUB.estados) AS "Nombre Estados de mayor procedencia",
       SUB.ocupacion_total AS "Ocupación total"
FROM (SELECT 
            ho.id_hotel AS id_h,
            ho.nombre AS nombre_h,
            IFNULL(e.nombre, "No hay visitas registradas") AS estados,
            IFNULL(OT.ocupacion_total,0) AS ocupacion_total
      FROM hoteles ho
      LEFT JOIN (
            -- Subconsulta para seleccionar el id_hotel y id_estado del estado del que proceden la
            -- mayor cantidad de visitantes por hotel.
            SELECT 
                  oe.id_hotel,
                  oe.id_estado
            FROM (
                  -- Subconsulta para obtener un estimado de la ocupación por hotel y por estado del
                  -- cliente que reserva, utilizando la capacidad de la habitación.
                  SELECT 
                        ho.id_hotel,
                        e.id_estado,
                        SUM(t.capacidad) AS ocupacion_estado
                  FROM reservas r
                  JOIN habitaciones ha ON r.clave_habitacion = ha.id_habitacion
                  JOIN tipo_habitacion t ON ha.clave_tipo = t.id_tipo
                  JOIN hoteles ho ON ha.clave_hotel = ho.id_hotel
                  JOIN clientes cl ON r.clave_cliente = cl.id_cliente
                  JOIN direcciones d ON cl.clave_direccion = d.id_direccion
                  JOIN colonias co ON d.clave_colonia = co.id_colonia
                  JOIN municipios m ON co.clave_mun = m.id_municipio
                  JOIN estados e ON m.clave_estado = e.id_estado
                  WHERE MONTH(r.fecha_inicio) IN (12, 1)
                  GROUP BY ho.id_hotel, e.id_estado
                  ) AS oe
            WHERE oe.ocupacion_estado = (
                                          -- Subconsulta para obtener la ocupación máxima por hotel según el
                                          -- estado de procedencia del cliente que reserva y del cual se
                                          -- registran más visitas.
                                          SELECT MAX(oe2.ocupacion_estado)
                                          FROM (
                                                SELECT 
                                                      ho.id_hotel,
                                                      e.id_estado,
                                                      SUM(t.capacidad) AS ocupacion_estado
                                                FROM reservas r
                                                JOIN habitaciones ha ON r.clave_habitacion = ha.id_habitacion
                                                JOIN tipo_habitacion t ON ha.clave_tipo = t.id_tipo
                                                JOIN hoteles ho ON ha.clave_hotel = ho.id_hotel
                                                JOIN clientes cl ON r.clave_cliente = cl.id_cliente
                                                JOIN direcciones d ON cl.clave_direccion = d.id_direccion
                                                JOIN colonias co ON d.clave_colonia = co.id_colonia
                                                JOIN municipios m ON co.clave_mun = m.id_municipio
                                                JOIN estados e ON m.clave_estado = e.id_estado
                                                WHERE MONTH(r.fecha_inicio) IN (12, 1)
                                                GROUP BY ho.id_hotel, e.id_estado
                                                ) AS oe2
                                          WHERE oe2.id_hotel = oe.id_hotel
                                    )
            ) AS EM ON ho.id_hotel = EM.id_hotel
      LEFT JOIN estados e ON e.id_estado = EM.id_estado -- Join para obtener los nombres de los estados
      LEFT JOIN (
            -- Subconsulta para obtener la ocupación total por hotel en vacaciones decembrinas 
            SELECT ho.id_hotel, SUM(t.capacidad) AS ocupacion_total
            FROM reservas r
            JOIN habitaciones ha ON r.clave_habitacion = ha.id_habitacion
            JOIN tipo_habitacion t ON ha.clave_tipo = t.id_tipo
            JOIN hoteles ho ON ha.clave_hotel = ho.id_hotel
            WHERE MONTH(r.fecha_inicio) IN (12, 1)
            GROUP BY ho.id_hotel
            ) AS OT ON ho.id_hotel = OT.id_hotel
      ) AS SUB
GROUP BY SUB.id_h, SUB.nombre_h, SUB.ocupacion_total
ORDER BY 4 DESC,1 ASC
LIMIT 50;


-- 8) Pregunta: ¿Qué tipos de habitaciones y cuántas cuentan con 'servicio a la habitación' por hotel? 

/* Explicación: Necesitamos saber cuántas habitaciones se tienen en total por hotel que ofrezcan servicio
                a la habitación para averguar si es necesario contratar más personal y no descudidadar
                dicha amenidad.
*/

SELECT
  ht.nombre AS 'Nombre del hotel',
  th.tipo AS 'Tipo de habitación',
  COUNT(DISTINCT h.id_habitacion) AS 'No. total de habitaciones con el servicio'
FROM tipo_habitacion th
JOIN habitaciones h ON th.id_tipo = h.clave_tipo
JOIN hoteles ht ON h.clave_hotel = ht.id_hotel
WHERE th.amenidades LIKE '%servicio a la habitación%'
GROUP BY ht.nombre, th.tipo
ORDER BY 1, 3 DESC;


-- 9) Pregunta: ¿Qué hoteles tienen habitaciones disponibles actualmente y qué precio tienen?

/* Explicación: Permite ver la disponibilidad en tiempo real y el rango de precios, lo cual es
                fundamental para operaciones, reservas en línea y análisis de demanda para el sector
                de ventas en la cadena.
*/

SELECT 
    h.nombre AS 'Hotel',
    hab.numero AS 'Número de habitación',
    th.tipo AS 'Tipo',
    LPAD(CONCAT('$  ', FORMAT(hab.precio_noche,2)),LENGTH('Precio por noche'),' ') AS 'Precio por noche'
FROM habitaciones hab
JOIN hoteles h ON hab.clave_hotel = h.id_hotel
JOIN tipo_habitacion th ON hab.clave_tipo = th.id_tipo
WHERE hab.disponibilidad = 'Disponible'
ORDER BY 1, 4;


-- 10) Pregunta: ¿Cuáles son los hoteles cuyo porcentaje de reservas canceladas o 'No show' durante
--              el primer trimestre del año 2023 fue superior al 25 % del total de reservas?

/* Explicación: Los ejecutivos desean averiguar cuál fue el porcentaje de reservas canceladas o
               'No show' por hotel durante el primer trimestre del año 2023 y detectar aquellos hoteles
               cuyo porcentaje calculado sea de al menos el 50 % para identificar posibles causas y
               proponer soluciones que prevengan tasas tan altas de cancelación para futuros años.
*/

SELECT ho.id_hotel AS "ID Hotel",
       ho.nombre "Nombre Hotel",
       LPAD(CONCAT(ROUND((COUNT(r.id_reserva) / TR.total_reservas * 100),1)," %"), 17, " ")
       AS "Cancelaciones (%)"
FROM hoteles ho
JOIN habitaciones ha ON ho.id_hotel = ha.clave_hotel
JOIN reservas r ON ha.id_habitacion = r.clave_habitacion
JOIN (SELECT ho.id_hotel AS id_hotel,
             COUNT(r.id_reserva) AS total_reservas
      FROM hoteles ho
      JOIN habitaciones ha ON ho.id_hotel = ha.clave_hotel
      JOIN reservas r ON ha.id_habitacion = r.clave_habitacion
      WHERE MONTH(r.fecha_inicio) IN (1,2,3)
        AND YEAR(r.fecha_inicio) = 2023
      GROUP BY ho.id_hotel) AS TR ON ho.id_hotel = TR.id_hotel
WHERE r.estado_reserva IN ('Cancelada','No show')
  AND MONTH(r.fecha_inicio) IN (1,2,3)
  AND YEAR(r.fecha_inicio) = 2023
GROUP BY ho.id_hotel, TR.total_reservas
HAVING (COUNT(r.id_reserva) / TR.total_reservas) >= 0.5
ORDER BY 3;