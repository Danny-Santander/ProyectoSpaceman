# ProyectoSpaceman
Proyecto para evaluar habilidades como Data Engineer.

# Archivo Untiled.ipynb
Este archivo es un cuaderno de Jupyter que contiene código Python para descargar y procesar archivos TXT desde el Google Drive previamente compartidos y cargarlos en un PostgreSQL definidas en Script.sql.

Las principales operaciones incluyen:
Instalación de los paquetes necesarios para la descarga de los archivos.

Descarga de los archivos en función a la ruta proveida y almacenmiento posterior en un directorio local.

Configuración de la conexión a PostgreSQL: Se establecen los parámetros necesarios para conectar con la base de datos, utilizando variables de entorno para la configuración.

Definición de funciones para inferir tipos de datos: Se implementa una función que infiere el tipo de datos de PostgreSQL basado en los tipos de datos de pandas, facilitando la creación dinámica de tablas.

Procesamiento de archivos TXT: Se define una función que lee archivos TXT desde una carpeta local, infiere la estructura de la tabla correspondiente y carga los datos en la base de datos.

Manejo de errores y cierre de conexiones: Se implementa manejo de excepciones para capturar errores durante el procesamiento y asegurar el cierre adecuado de las conexiones a la base de datos.

# Archivo Script.sql
Este archivo define la estructura de la base de datos en PostgreSQL previamente realiazado, creando tablas para gestionar información relacionada con productos, tickes y calendario.

Las principales operaciones incluyen:
Creación de la tabla productos: Almacena detalles de los productos, como identificadores, descripciones, clasificaciones y detalles del fabricante.

Creación de la tabla tickets: Registra las transacciones de ventas, incluyendo información sobre el punto de venta, fecha y hora, productos vendidos, precios y estado de anulación.

Creación de la tabla calendario: Proporciona información sobre las fechas, indicando el día de la semana y si es festivo, útil para análisis temporales.

Inserción de datos en la tabla calendario: Se añaden registros específicos para fechas clave, indicando si son festivos.

Alteración de la tabla tickets: Se establece una restricción de clave foránea en la columna fecha, vinculándola con la columna fecha de la tabla calendario, asegurando la integridad referencial entre las transacciones y el calendario.

Corrección de datos de las tablas tickets y productos.
