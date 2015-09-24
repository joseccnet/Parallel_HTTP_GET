# Parallel_HTTP_GET
Herramienta/script para probar el performance de peticiones GET a servicios web(protocolo HTTP).

La herramienta tiene dos versiones:

+ 'Shell Bash' - Mas portable.

+ 'Python' - Mejor performance.

Ejecute de la siguiente manera:

# Version Shell Bash 

./Parallel_HTTP_GET.sh

 +++ Parallel HTTP GET +++

3 Argumentos requeridos:

  ./Parallel_HTTP_GET.sh NumProcesosConcurrentes NumHits URL

  Ejemplo: ./Parallel_HTTP_GET.sh 5 20 'http://yahoo.com/x=1&y=2'

# Version Python

./Parallel_HTTP_GET.py

 +++ Parallel HTTP GET +++

3 Argumentos requeridos:

   ./Parallel_HTTP_GET.py NumProcesosConcurrentes NumHits URL

   Ejemplo: ./Parallel_HTTP_GET.py 5 20 'http://yahoo.com/x=1&y=2'
