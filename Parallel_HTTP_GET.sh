#!/bin/bash
# Autor: @joseccnet
# El autor no se hace responsable del mal uso que pueda darse a esta herramienta.

echo -e " +++ Parallel HTTP GET +++\n"
if [ "$#" -le 2 ] ; then
   echo -e "3 Argumentos requeridos:\n"
   echo -e "  $0 NumProcesosConcurrentes NumHits URL\n"
   echo -e "  Ejemplo: $0 5 20 'http://yahoo.com/x=1&y=2'\n"
   exit -1
fi

CURL=$(which curl)
if [ "$CURL" == "" ] ; then
   echo "'curl' no encontrado. Instale curl"
   exit -1
fi

numprocesos=$1
numhits=$2
URL=$3
OutputFile="/dev/null"
UserAgentFake="Mozilla/5.0 ($(echo -e "Windows NT 6.3\nLinux\nMac\nAndroid\niPhone" | sort -R | head -1); WOW64; rv:34.0) Gecko/20$((RANDOM%(15-10+1)+10))0101 Firefox/$(for i in {30..41}.0; do echo $i; done | sort -R | head -1)"
export numprocesos URL OutputFile CURL UserAgentFake

function descargar
{
   echo -n "."
   #response=$($CURL -o $OutputFile --connect-timeout 5 --max-time 10 --insecure -A "$UserAgentFake" --location --max-redirs 3 --silent --head --write-out '%{http_code} %{time_total}' "$URL") #SOLO los HEADERS. Es mas rapida la respuesta.
   response=$($CURL -o $OutputFile --connect-timeout 5 --max-time 10 --insecure -A "$UserAgentFake" --location --max-redirs 3 --silent --write-out '%{http_code} %{time_total}' "$URL") #Descarga la pagina solicitada.
   echo $response | awk '{print $2}' >> /tmp/httpcodes/respuestas_HTTP_$(echo $response | awk '{print $1}')
   #echo -n "$1 " #Mostrar el numero de iterancia actual.
}
export -f descargar

if [ ! -d /tmp/httpcodes ] ; then
   mkdir /tmp/httpcodes
fi
rm -f /tmp/httpcodes/respuestas_HTTP_* 2> /dev/null

echo -n "Ejecutando "
date1=$(date +"%s")
for i in $(seq 1 $numhits); do echo $i; done | xargs -I '{}' -P $numprocesos -n1 bash -c "descargar '{}'" 
date2=$(date +"%s")
diff=$(($date2-$date1))

echo -e "\n"
echo "Estadisticas:"
wc -l /tmp/httpcodes/respuestas_HTTP_* | sed -e 's/\/tmp\/httpcodes\///g' -e 's/_/ /g'

echo -e "\nTiempos de respuesta:"
cat /tmp/httpcodes/respuestas_HTTP_* | sed 's/,/./g' | awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1< min) {min=$1}; total+=$1; count+=1} END {print min" segs(minimo) / "total/count" segs(promedio) / " max" segs(maximo)"}'

rm -f /tmp/httpcodes/respuestas_HTTP_* 2> /dev/null
echo -e "\nTiempo total de ejecucion:\n$(($diff / 60)) minutos y $(($diff % 60)) segundos."

echo -e "\nDone."
exit 0
