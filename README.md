**Codi d'R per accedir a dades bibliometriques adaptat per generar la secció B del curriculum AQU**

***Nota:*** *S'ha d'executar dins la xarxa de la institució o amb conexxió via VPN*

Pasos:
1. Descarregar tot el repositori i descomprimir-lo
2. Obrir `CV_aquR_exe.R`
3. Establir working directory, a la funció `setwd()`, que apunti a la carpeta descomprimida descomprimida.
4. Descarregar CV perfil de la WoS en format JSON i carregar-lo a linia `dataJSON <- fromJSON(...)`
5. Carregar BBDD SJR i JRC (accesibles via FECYT)
6. Solicitar API kei a https://dev.elsevier.com/apikey/manage i inserir-la a la línia `scopus_key <- "..."`
7. Executar tot el codi `CV_aquR_exe.R`

