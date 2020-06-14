****************************************************************************************************************************************
****************************************************************************************************************************************
# Sistemas Operativos 75.08 - Trabajo Práctico Nº1
# Grupo 02 - 1º Cuatrimestre del 2020
****************************************************************************************************************************************
****************************************************************************************************************************************

# Descarga y descompresión del sistema
- Descargarel paquete Grupo_02.tar.gz del siguiente link: https://github.com/Facu07/FiubaSisOp_2020
- Mover el paquete a la ubicación que usted desee.
- Abrir la terminal en la ubicación elegida y ejecutar el comando tar -xvf Grupo02.tar.gz
- Se obtendrá dentro de la ubicación el install.sh y una carpeta con el paquete de la aplicación. 



# Instalación
- Ubicado en el directorio elegido, ejecutar por la terminal el comando ./install.sh
- Una vez ejecutado el comando se crean los subdirectorios conf y cong/log.
- A continuación, se pide asignar las rutas de los directorios de ejecutables,de archivos maestros,de recepcion de novedades, de archivos aceptados,de archivos rechazados, de archivos procesados, de archivos de salida. Ademas, se pide setear el horario de cierre.
Se puede ingresar una ruta, pero tambien da la opcion de asignar por defecto solo presionando enter para confirmar la ruta mostrada por pantalla.
- Se pedirá una confirmación de la información ingresada. Si ingresa "si" se completará la instalación creando todos los directorios mencionados y ubicando los script y archivos maestros donde corresponden. Y si ingresa "no" volverá a comenzar la instalación y se pedirá nuevamente que se configuren los directorios.
- Finalmente, muestra un mensaje del estado de la instalacion exitosa.
- En caso que se ejecute el comando ./install.sh nuevamente, mostrará por pantalla un mensaje diciendo que el programa ha sido instalado correctamente.





# Instrucciones de inicialización
- Ir al directorio de los ejecutables (por defecto bin) y ejecutar por la terminal el comando ./inicio.sh
- Se informará si se inicializa por primera vez el sistema, da una lista de todos los directorios que existen, se da permiso de lectura al directorio que contiene los archivos maestros y se da permisos de lectura y ejecucion al directorio que contiene los archivos ejecutables.
En caso de ejecutar el comando nuevamente, muestra el mensaje que el sistema ya fue inicializado n veces. 



# Uso
- Con el proceso daemon funcionando, se puede detener ubicandose en el directorio de ejecutables. Para eso hay que correr el comando ./stop.sh el cual informa si sea ha detenido el proceso o si no se puede detener porque no existe dicho proceso.
- Para volver a iniciar el proceso daemon, ubicado en el directorio de ejecutables, se abre la terminal y se escribe el comando ./inicio.sh el cual volverá a poner en funcionamiento el proceso daemon, siempre y cuando estén dadas las condiciones. 
En caso de que ya se encuentre un proceso daemon corriendo, no se correra uno adicional y se informará de la situación mostrando el pid donde se encuentra ejecutado.
- Para procesar archivos debe colocar los archivos de lotes dentro del directorio novedades.


# Estructuras

- Grupo_02/conf/tpconfig.txt

# Listado de archivos de prueba dados por la cátedra

0504-B-34567890.csv
0504-C-23456789.csv
0504-M-72501608.csv
0506-B-34567890.csv
0506-C-23456789.csv
0506-M-72501608.csv
0506-X-72501607.csv
0507-C-23456789.csv
0507-M-72501608.csv
0515-B-12345678.csv
0515-X-72501733.csv
0516-B-12345678.csv
0516-B-34567890.csv
0517-X-72501733.csv
0520-X-72501608.csv
0522-X-72501608.csv
1231-B-34567890.csv







