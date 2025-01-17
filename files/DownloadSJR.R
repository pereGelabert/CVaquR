# Cargar las librerías necesarias
library(httr)
library(readxl)
library(dplyr)
library(stringr)

# Definir una función para descargar los archivos de Excel por año
descargar_sjr <- function(start_year, end_year, output_dir) {
  # Crear la carpeta de salida si no existe
  if (!dir.exists(output_dir)) {
    dir.create(output_dir)
  }
  
  # Iterar por cada año
  for (year in start_year:end_year) {
    # Construir la URL para el año correspondiente
    url <- paste0("https://www.scimagojr.com/journalrank.php?year=", year, "&out=xls")
    
    # Definir el nombre del archivo de salida
    output_file <- file.path(output_dir, paste0("scimagojr_", year, ".csv"))
    
    # Descargar el archivo
    response <- GET(url, write_disk(output_file, overwrite = TRUE))
    
    # Comprobar si la descarga fue exitosa
    if (response$status_code == 200) {
      cat("Archivo para el año", year, "descargado exitosamente.\n")
    } else {
      cat("Error al descargar el archivo para el año", year, "(Código de estado:", response$status_code, ").\n")
    }
  }
}

# Llamar a la función para descargar archivos desde 1999 hasta 2023
descargar_sjr(start_year = 1999, end_year = 2023, output_dir = "C:/Users/Pere/Documents/")

# Leer y procesar los archivos descargados
procesar_excels <- function(output_dir) {
  # Obtener la lista de archivos en la carpeta
  archivos <- list.files(output_dir, pattern = "*.csv", full.names = TRUE)
# Leer y procesar cada archivo
datos_completos <- lapply(archivos, function(archivo) {
  # Extraer el año del nombre del archivo
  year <- str_extract(basename(archivo), "\\d{4}")
  
  # Leer el archivo de Excel
  datos <- read_csv2(archivo)
  
  # Agregar la columna del año
  datos <- datos %>% mutate(year = as.integer(year))
  
  # Dividir la columna ISSN en dos columnas
  if ("Issn" %in% colnames(datos)) {
    datos <- datos %>%
      mutate(
        ISSN = str_split_fixed(Issn, ",", 2)[, 1],
        ISSN_2 = str_split_fixed(Issn, ",", 2)[, 2],
        ISSN = str_replace_all(ISSN, "(\\d{4})(\\d{3}[0-9Xx])", "\\1-\\2") %>% str_trim(),
        ISSN_2 = str_replace_all(ISSN_2, "(\\d{4})(\\d{3}[0-9Xx])", "\\1-\\2") %>% str_trim(),
      ) %>% 
      select(Rank,year,Sourceid,Title, ISSN, ISSN_2, SJR,`SJR Best Quartile`, Publisher, Categories, Areas )
  }
  
  return(datos)
})

# Combinar todos los datos en un único data frame
datos_completos <- bind_rows(datos_completos)

return(datos_completos)
}


# Procesar los excels descargados
datos_procesados <- procesar_excels(output_dir = "C:/Users/Pere/Documents/")

# Vista previa de los datos procesados
head(datos_procesados)
SJR_Data <- datos_procesados
save(SJR_Data,file="C:/Users/Pere/Documents/SJR_data.RData")
