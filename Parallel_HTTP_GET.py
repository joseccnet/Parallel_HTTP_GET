#!/usr/bin/env python
# Autor: @joseccnet
# El autor no se hace responsable del mal uso que pueda darse a esta herramienta.

import os,sys,glob,signal,random
import multiprocessing as mp
from datetime import datetime

print (" +++ Parallel HTTP GET +++\n")
if sys.platform.startswith('win'):
   print("Esta herramienta no trabaja en Windows. Exit.")
   exit(-1)

try:
   import pycurl
except ImportError:
   print ("PyCurl No encontrado. Instale pycurl")
   exit(-1)

if(len(sys.argv) > 3):
   max_task = int(sys.argv[1])
   hits = int(sys.argv[2])
   url = sys.argv[3] #Nota: Utilice comillas cuando utilice caracteres especiales como &
   outputfile='/dev/null'
   UserAgentFake="Mozilla/5.0 ("+random.choice(['Windows NT 6.3','Linux','Mac','Android','iPhone'])+"; WOW64; rv:34.0) Gecko/20"+repr(random.randint(10,15))+"0101 Firefox/"+repr(random.randint(30,41))+".0"
else:
   print("3 Argumentos requeridos:\n")
   print("   "+sys.argv[0]+" NumProcesosConcurrentes NumHits URL\n")
   print("   Ejemplo: "+sys.argv[0]+" 5 20 'http://yahoo.com/x=1&y=2'\n")
   exit()

def mycurl(n):
   signal.signal(signal.SIGINT, signal.SIG_IGN)
   sys.stdout.write('.')
   sys.stdout.flush()
   c = pycurl.Curl()
   c.fp = open(outputfile, 'wb')
   c.setopt(pycurl.WRITEDATA, c.fp)
   c.setopt(pycurl.CONNECTTIMEOUT, 5)
   c.setopt(pycurl.TIMEOUT, 10)
   c.setopt(pycurl.SSL_VERIFYPEER, False)
   c.setopt(pycurl.SSL_VERIFYHOST, False)
   c.setopt(pycurl.USERAGENT, UserAgentFake)
   c.setopt(pycurl.FOLLOWLOCATION, True)
   c.setopt(pycurl.MAXREDIRS, 3)
   #c.setopt(c.HEADER, True) # Solo los HEADER, NO el contenido.
   #c.setopt(c.NOBODY, True) # Solo los HEADER, NO el contenido.
   c.setopt(c.URL, url)
   c.perform()
   os.system('echo '+repr(c.getinfo(c.TOTAL_TIME))+' >> respuestas_HTTP_'+repr(c.getinfo(c.RESPONSE_CODE))) #Hacer esto para salvar uso de memoria con numeros altos de hits(utilizamos disco).
   c.close()

os.system('rm -f respuestas_HTTP_* 2>/dev/null')

sys.stdout.write('Ejecutando ')
timea = datetime.now()
pool = mp.Pool(processes=max_task)
try:
   pool.map(mycurl, range(0,hits))
   pool.close()
   pool.join()
except (KeyboardInterrupt, SystemExit):
   print ("control-c")
   pool.terminate()
   pool.join()
   exit(-1)
timeb = datetime.now()
print(" Termino.")

print("\nEstadisticas:")
files=glob.glob('respuestas_HTTP_*')
for f in files:
   num_lines = sum(1 for line in open(f))
   print(repr(num_lines)+" "+f.replace('_',' '))

print("\nTiempos de respuesta:")
os.system('cat respuestas_HTTP_* | awk \'{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1< min) {min=$1}; total+=$1; count+=1} END {print min" segs(minimo) / "total/count" segs(promedio) / " max" segs(maximo)"}\'')
os.system('rm -f respuestas_HTTP_* 2>/dev/null')

tmins,tsegs=divmod((timeb-timea).total_seconds(), 60)
print("\nTiempo total de ejecucion:\n"+repr(int(tmins))+" minutos y "+repr(tsegs)+" segundos.")

print("\nDone.\n")
