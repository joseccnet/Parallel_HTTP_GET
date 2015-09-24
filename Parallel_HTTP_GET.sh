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
export numprocesos URL OutputFile CURL

function descargar
{
   echo -n ". "
   versionFakeFirefox=$(for i in {20..41}.0; do echo $i; done | sort -R | head -1)
   UserAgentFake="Mozilla/5.0 (Windows NT 6.3; WOW64; rv:34.0) Gecko/20$((RANDOM%(15-10+1)+10))0101 Firefox/$versionFakeFirefox"
   #response_http_code=$($CURL -o $OutputFile --insecure -A "$UserAgentFake" --silent --head --write-out '%{http_code}' "$URL") #SOLO los HEADERS. Es mas rapida la respuesta.
   response_http_code=$($CURL -o $OutputFile --insecure -A "$UserAgentFake" --silent --write-out '%{http_code}' "$URL") #Descarga la pagina solicitada.
   echo "." >> /tmp/httpcodes/respuestas_$response_http_code
   #echo -n "$1 "
}
export -f descargar

if [ ! -d /tmp/httpcodes ] ; then
   mkdir /tmp/httpcodes
fi
rm -f /tmp/httpcodes/respuestas_* 2> /dev/null

date1=$(date +"%s")
for i in $(seq 1 $numhits); do echo $i; done | xargs -I '{}' -P $numprocesos -n1 bash -c "descargar '{}'" 
date2=$(date +"%s")
diff=$(($date2-$date1))

echo -e "\n"
echo "Estadisticas:"
wc -l /tmp/httpcodes/respuestas_* | sed 's/\/tmp\/httpcodes\///g'
rm -f /tmp/httpcodes/respuestas_* 2> /dev/null
echo -e "\n$(($diff / 60)) minutos y $(($diff % 60)) segundos de ejecucion."

echo -e "\nDone."
exit 0
