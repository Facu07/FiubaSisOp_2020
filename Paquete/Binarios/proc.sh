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
		echo "$nombreArchivo rechazado. Motivo: No es un archivo normal"
		./glog.sh "proc" "$nombreArchivo rechazado. Motivo: No es un archivo normal"
	fi
	# Grabar en el log el nombre del archivo rechazado. Motivo: No es legible
	echo "$nombreArchivo rechazado. Motivo: No es legible"
	./glog.sh "proc" "$nombreArchivo rechazado. Motivo: No es legible"
	return -1
fi
# Grabar en el log el nombre del archivo rechazado. Motivo: Archivo vacio
echo "$nombreArchivo rechazado. Motivo: Archivo vacio"
./glog.sh "proc" "$nombreArchivo rechazado. Motivo: Archivo vacio"
return -1

}

function validar_Mes
{

if [[ $mm -lt 13 ]] && [[ $mm -gt 0 ]]					# valido q el mes este entre 12 y 1
then
	# mes valido
	return 0
fi
echo "$nombreArchivo rechazado. Motivo: $mm No es un mes valido"
./glog.sh "proc" "$nombreArchivo rechazado. Motivo: $mm No es un mes valido"
return -1

}

function validar_Dias_del_Mes
{
case $mm in
'02')
  if [[ $dd -lt 30 ]] && [[ $dd -gt 0 ]]					# valido q el dia sea de 29
	then
		#mes febrero
		return 0
	fi
  ;;
'01' | '03' | '05' | '07' | '08' | '09' | '10' | '12')
    if [[ $dd -lt 32 ]] && [[ $dd -gt 0 ]]					# valido q el dia sea de 31
	then
		# mes valido de 31 dias
		return 0
	fi
  ;;
'04' | '06' | '09' | '11')
    if [[ $dd -lt 31 ]] && [[ $dd -gt 0 ]]					# valido q el dia sea de 30
	then
		# mes valido de 30 dias
		return 0
	fi
  ;;
 *)
	# dia no valido
	echo "$nombreArchivo rechazado. Motivo: $dd No es un dia valido"
	./glog.sh "proc" "$nombreArchivo rechazado. Motivo: $dd No es un dia valido"
	return -1
esac
return -1

}

function validar_Repetido
{

temp1="${archivo##*/}"

for file in "$procesados/"*.csv;
	do
		temp2="${file##*/}"
		if [[ "$temp1" == "$temp2" ]];
		then
			# Grabar en log que se rechaza el $nombreArchivo por que esta duplicado
			echo "Se rechaza el $nombreArchivo por estar duplicado"
			./glog.sh "proc" "Se rechaza el $nombreArchivo por estar duplicado"
			return -1 
		fi
	done
return 0

}

function validar_State_Code
{

codigosProvincias="$maestro/CodigosProvincias.csv"

while IFS=',' read name code
do
	if [ "$stateCode" == "$code" ];
	then
		stateName="$name"
		# "Estado: $name con codigo: $stateCode"
		return 0
	fi
done < "$codigosProvincias"

./glog.sh "proc" "Se rechaza el $nombreArchivo por tener un codigo de provincia no valido"
return -1

}

function validar_Merchant_Code
{

codigosComercios="$maestro/CodigosComercios.csv"

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

./glog.sh "proc" "Se rechaza el $nombreArchivo por tener un codigo de comercio no valido"
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
    	./glog.sh "proc" "No hay archivos en $aceptados..."
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
			echo -e "$idTransaction,$cProcessingCode,$nTransactionAmount,$cSystemTrace,$cLocalTransactionTime,$cRetrievalReferenceNumber,$cAuthorizationResponse,$cResponseCode,$installments,$hostResponse,$cTicketNumber,$batchNumber,$cGuid,$cMessageType,$cMessageType_Response,Registro: $CANTREGISTROS no cumple con la estrucutra,$nombreArchivo" >> "$rechazados/rejectedData.csv"
		fi
	done < "$file"
	./glog.sh "proc" "$nombreArchivo tiene $CANTREGISTROS cantidad de registros"
	mv $file $procesados
done
return 0

}

function registro_es_apto
{


estructuraNovedades="$maestro/EstructuraNovedades.csv"

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

codigos_Respuestas_Gateway="$maestro/Codigos_Respuestas_Gateway.csv"

while IFS='		' read iso09_ResponseCode shortDescription longDescription
do
	if [[ $cResponseCode = *$iso09_ResponseCode* ]]
	then
		isO15_cResponseCodeShortDescription="\"isO15_cResponseCodeShortDescription\": \"$shortDescription\""
		return 0
	fi
done < "$codigos_Respuestas_Gateway"

}

function validarNombreArchivoSalida
{

merchantCode="${nombreArchivo:7:8}"
mm="${nombreArchivo:0:2}"
dd="${nombreArchivo:2:2}"
stateCode="${nombreArchivo:5:1}"
transactionTime=$(cut -d'"' -f4 <<<$cLocalTransactionTime)

if [[ $transactionTime > $HORACIERRE ]]
then
	case $mm in
		'02')
		  if [[ $dd -eq 29 ]]
			then
				let mm=mm+1
				dd=01
			else
				let dd=dd+1
			fi
		  ;;
		'01' | '03' | '05' | '07' | '09' | '11')
		    if [[ $dd -eq 31 ]]
		    then
				let mm=mm+1
				dd=01
			else
				let dd=dd+1
			fi
		  ;;
		'04' | '06' | '08' | '10')
		    if [[ $dd -eq 30 ]]
			then
				let mm=mm+1
				dd=01
			else
				let dd=dd+1
			fi
		  ;;
		  '12')
 			if [[ $dd -eq 31 ]]
		    then
		    	mm=01
		    	dd=01
		    else
		    	let dd=dd+1
		    fi
		   ;;
		 *)
	esac
	mm=$(printf %02d  $((mm%100)))
	dd=$(printf %02d  $((dd%100)))
fi

nombreArchivoSalida="$merchantCode-$mm$dd"
return 0

}

function procesarSalida
{

validarNombreArchivoSalida

cOriginalFile="\"cOriginalFile\": \"${merchantCode%.csv*}\""

validar_State_Code

isO05_cStateName="\"isO05_cStateName\": \"$stateName\""
isO05_cStateCode="\"isO05_cStateCode\": \"$stateCode\""
isO07_cTransmissionDateTime="\"isO07_cTransmissionDateTime\": \"$mmdd$cLocalTransactionTime\""
isO13_cLocalTransactionDate="\"isO13_cLocalTransactionDate\": \"$mmdd\""

obtener_cResponseCodeShortDescription

isO42_cMerchantCode="\"isO42_cMerchantCode\": \"$merchantCode\""
isO49_cTransactionCurrencyCode="\"isO49_cTransactionCurrencyCode\": \"032\""
nTransactionAmount=$(cut -d':' -f2 <<<$nTransactionAmount)
nTransactionAmount=$(cut -d' ' -f2 <<<$nTransactionAmount)
if [[ $nTransactionAmount = 0 ]]
then
	isO04_cTransactionAmount="\"isO04_cTransactionAmount\": \"000000000000\""
else
	isO04_cTransactionAmount="\"isO04_cTransactionAmount\": \"00000000$nTransactionAmount\""
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
novedades="$DIRNOVE"
aceptados="$DIROK"
rechazados="$DIRNOK"
salida="$DIROUT"
procesados="$DIRPROC"
binarios="$DIRBIN"
horaCierre="$HORACIERRE"


./glog.sh "proc" "Procesando... "
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
				./glog.sh "proc" "Archivo $archivo aceptado"
			else
				mv $archivo $rechazados					# Mueve a la carpeta de rechazados
				./glog.sh "proc" "Archivo $archivo rechazado"
			fi
     	else
         	echo "Nada por procesar"
         	./glog.sh "proc" "No hay archivos en $novedades..."
         	break
     	fi
		
	done

	if [ "$(ls $aceptados/)" ]
    then  
		validar_registros_completos
	fi

	sleep 10

	#loggear el CICLO en el que voy
	./glog.sh "proc" "Ciclo Nº: $CICLO"

done

PID_PROCESO=`ps -a | grep proc.sh | awk '{print $1}'`
./glog.sh "proc" "Programa finalizado con pid: $PID_PROCESO"

exit 0

