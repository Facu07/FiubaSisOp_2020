#! /bin/bash

function validar_Existe_NoVacio_Regular
{

if [[ -s "$archivo" ]] 									# Archivo vacio?
then
	if [[ -r "$archivo" ]]; 							# Archivo legible?
	then
		if [[ -f "$archivo" ]]; 						# Archivo normal?
		then
			return 0									#Existe y no esta vacío && Existe y puede leerse 
		fi
		# Grabar en el log el nombre del archivo rechazado. Motivo: No es un archivo normal
		$BINDIR./glog.sh "proc" "$nombreArchivo rechazado. Motivo: No es un archivo normal"
	fi
	# Grabar en el log el nombre del archivo rechazado. Motivo: No es legible
	$BINDIR./glog.sh "proc" "$nombreArchivo rechazado. Motivo: No es legible"
	return -1
fi
# Grabar en el log el nombre del archivo rechazado. Motivo: Archivo vacio
$BINDIR./glog.sh "proc" "$nombreArchivo rechazado. Motivo: Archivo vacio"
return -1

}

function validar_Mes
{

if [[ "$mm" < "13" ]] && [[ "$mm" > "01" ]]					# valido q el mes este entre 12 y 1
then
	# mes valido
	return 0
fi
$BINDIR./glog.sh "proc" "$nombreArchivo rechazado. Motivo: $mm No es un mes valido"
return -1

}

function validar_Dias_del_Mes
{
case $mm in
'02')
  if [[ "$dd" < "29" ]] && [[ "$dd" > "01" ]]					# valido q el dia sea de 29
	then
		#mes febrero
		return 0
	fi
  ;;
'01' | '03' | '05' | '07' | '09' | '11')
    if [[ "$dd" < "31" ]] && [[ "$dd" > "01" ]]					# valido q el dia sea de 31
	then
		# mes valido de 31 dias
		return 0
	fi
  ;;
'04' | '06' | '08' | '10' | '12')
    if [[ "$dd" < "30" ]] && [[ "$dd" > "01" ]]					# valido q el dia sea de 30
	then
		# mes valido de 30 dias
		return 0
	fi
  ;;
 *)
	# dia no valido
	$BINDIR./glog.sh "proc" "$nombreArchivo rechazado. Motivo: $dd No es un dia valido"
	return -1
esac
return -1

}

function validar_Repetido
{


for file in "$procesados/"*.csv;
	do
		if [[ $archivo == $file ]];
		then
			# Grabar en log que se rechaza el $nombreArchivo por que esta duplicado
			$BINDIR./glog.sh "proc" "Se rechaza el $nombreArchivo por estar duplicado"
			return -1 
		fi
	done
return 0

}

function validar_State_Code
{

codigosProvincias="$(find . -iname "CodigosProvincias.csv")"

while IFS=',' read name code
do
	if [ "$stateCode" == "$code" ];
	then
		stateName="$name"
		# "Estado: $name con codigo: $stateCode"
		return 0
	fi
done < "$codigosProvincias"

$BINDIR./glog.sh "proc" "Se rechaza el $nombreArchivo por tener un codigo de provincia no valido"
return -1

}

function validar_Merchant_Code
{

codigosComercios="$(find . -iname "CodigosComercios.csv")"

while IFS=',' read comercio estado
do
	if [ "$merchantCode" == "$comercio" ];
	then
		if [ "$estado" == "HABILITADO" ]
		then
			# "Comercio: $merchantCode con estado $estado"
			return 0
		fi
	fi
done < "$codigosComercios"

$BINDIR./glog.sh "proc" "Se rechaza el $nombreArchivo por tener un codigo de comercio no valido"
return -1

}

function validar_Archivo
{

if validar_Existe_NoVacio_Regular;
then
	if validar_Mes;
	then
		if validar_Dias_del_Mes
		then
			if validar_Repetido;
			then
				if validar_State_Code
				then
					if validar_Merchant_Code
					then
						return 0
					fi
				fi
			fi
		fi
	fi
fi
return -1

}

function validar_registros_completos
{
CONTADOR=0
CONTEO=0

for file in "$aceptados/"*.csv;
do
	CANTREGISTROS=0
	if [ ! "$(ls $aceptados/)" ]
    then
    	$BINDIR./glog.sh "proc" "No hay archivos en $aceptados..."
    	echo "Se proceso todo en $aceptados"
    	return 0
    fi  
	while IFS=',' read idTransaction cProcessingCode nTransactionAmount cSystemTrace cLocalTransactionTime cRetrievalReferenceNumber cAuthorizationResponse cResponseCode installments hostResponse cTicketNumber batchNumber cGuid cMessageType cMessageType_Response
	do
		let CANTREGISTROS=CANTREGISTROS+1
		nombreArchivo="${file##*$aceptados/}"
		if registro_es_apto 
		then
			procesarSalida
		else
			echo -e "$idTransaction,$cProcessingCode,$nTransactionAmount,$cSystemTrace,$cLocalTransactionTime,$cRetrievalReferenceNumber,$cAuthorizationResponse,$cResponseCode,$installments,$hostResponse,$cTicketNumber,$batchNumber,$cGuid,$cMessageType,$cMessageType_Response,Registro: $CANTREGISTROS no cumple con la estrucutra,$nombreArchivo" >> "$salida"
		fi
	done < "$file"
	$BINDIR./glog.sh "proc" "$nombreArchivo tiene $CANTREGISTROS cantidad de registros"
done
return 0

}

function registro_es_apto
{

estructuraNovedades="$(find . -iname "EstructuraNovedades.csv")"

while IFS=',' read col1 col2 col3 col4 col5 col6 col7 col8 col9 col10 col11 col12 col13 col14 col15
do
	if [[ $idTransaction = *$col1* ]] && [[ $cProcessingCode = *$col2* ]] && [[ $nTransactionAmount = *$col3* ]] && [[ $cSystemTrace = *$col4* ]] && [[ $cLocalTransactionTime = *$col5* ]] && [[ $cRetrievalReferenceNumber = *$col6* ]] && [[ $cAuthorizationResponse = *$col7* ]] && [[ $cResponseCode = *$col8* ]] && [[ $installments = *$col9* ]] && [[ $hostResponse = *$col10* ]] && [[ $cTicketNumber = *$col11* ]] && [[ $batchNumber = *$col12* ]] && [[ $cGuid = *$col13* ]] && [[ $cMessageType = *$col14* ]] && [[ $cMessageType_Response = *$col15* ]]
	then
		return 0
	else 
		return -1
	fi
done < "$estructuraNovedades"

}


function obtener_cResponseCodeShortDescription
{

codigos_Respuestas_Gateway="$(find . -iname "Codigos_Respuestas_Gateway.csv")"

while IFS='		' read iso09_ResponseCode shortDescription longDescription
do
	if [[ $cResponseCode = *$iso09_ResponseCode* ]]
	then
		isO15_cResponseCodeShortDescription="\"isO15_cResponseCodeShortDescription\": \"$shortDescription\""
		return 0
	fi
done < "$codigos_Respuestas_Gateway"

}

function procesarSalida
{

merchantCode="${nombreArchivo:7:8}"
mmdd="${nombreArchivo:0:4}"
stateCode="${nombreArchivo:5:1}"
nombreArchivoSalida="$merchantCode-$mmdd"
cOriginalFile="\"cOriginalFile\": \"${merchantCode%.csv*}\""

validar_State_Code

isO05_cStateName="\"isO05_cStateName\": \"$stateName\""
isO05_cStateCode="\"isO05_cStateCode\": \"$stateCode\""
isO07_cTransmissionDateTime="\"isO07_cTransmissionDateTime\": \"$mmdd$cLocalTransactionTime\""
isO13_cLocalTransactionDate="\"isO13_cLocalTransactionDate\": \"$mmdd\""

obtener_cResponseCodeShortDescription

isO42_cMerchantCode="\"isO42_cMerchantCode\": \"$merchantCode\""
isO49_cTransactionCurrencyCode="\"isO49_cTransactionCurrencyCode\": \"032\""
if [[ ${nTransactionAmount:28:1} = 0 ]]
then
	isO04_cTransactionAmount="\"isO04_cTransactionAmount\": \"000000000000\""
else
	isO04_cTransactionAmount="\"isO04_cTransactionAmount\": \"00000000${nTransactionAmount:28:4}\""
fi

echo -e "$cOriginalFile,$isO05_cStateName,$isO05_cStateCode,$isO07_cTransmissionDateTime,$isO13_cLocalTransactionDate,$isO15_cResponseCodeShortDescription,$isO42_cMerchantCode,$isO49_cTransactionCurrencyCode,$isO04_cTransactionAmount" >> "$salida/$nombreArchivoSalida.csv"

unset merchantCode
unset mmdd
unset stateCode
unset nombreArchivoSalida
unset cOriginalFile
unset isO05_cStateName
unset isO05_cStateCode
unset isO07_cTransmissionDateTime
unset isO13_cLocalTransactionDate
unset isO42_cMerchantCode
unset isO49_cTransactionCurrencyCode
unset isO04_cTransactionAmount

}


# ------------------------------------------------------------------------------------------------------------#
# ------------------------------------------------------------------------------------------------------------#
# ------------------------------------------	Cuerpo Principal	------------------------------------------#
# ------------------------------------------------------------------------------------------------------------#
# ------------------------------------------------------------------------------------------------------------#


CICLO=0
PROCESO_ACTIVO=true

maestro="$DIRMAE"
novedades="$DIRNOV"
aceptados="$DIROK"
rechazados="$DIRNOK"
procesados="$DIRPROC"
salida="$DIROUT"
transacciones="$DIRTRANS"

touch "$DIRNOK/rejecteddata.csv"

$BINDIR./glog.sh "proc" "Procesando... "
function finalizar_proceso {
   let PROCESO_ACTIVO=false
}


trap finalizar_proceso SIGINT SIGTERM


while [ $PROCESO_ACTIVO = true ]
do
	for file in "$novedades/"*.csv;
	do
		let CICLO=CICLO+1
		if [ "$(ls $novedades/)" ]
    	then  
			nombreArchivo="${file##*$novedades/}"
			archivo=$file
			mm="${nombreArchivo:0:2}"
			dd="${nombreArchivo:2:2}"
			stateCode="${nombreArchivo:5:1}"
			merchantCode="${nombreArchivo:7:8}"
			if validar_Archivo; 
			then	
				mv $archivo $aceptados					# Mueve a la carpeta de aceptados
				# Grabar en el log el nombre del archivo aceptado
				$BINDIR./glog.sh "proc" "Archivo $archivo aceptado"
			else
				mv $archivo $rechazados					# Mueve a la carpeta de rechazados
			fi
     	else
         	echo "Nada por procesar"
         	$BINDIR./glog.sh "proc" "No hay archivos en $novedades..."
     	fi
		
	done

	if [ "$(ls $aceptados/)" ]
    then  
		validar_registros_completos
	fi

	sleep 10

	#loggear el CICLO en el que voy
	$BINDIR./glog.sh "proc" "Ciclo Nº: $CICLO"

done

PID_PROCESO=`ps -a | grep proc.sh | awk '{print $1}'`
$BINDIR./glog.sh "proc" "Programa finalizado con pid: $PID_PROCESO"

exit 0

