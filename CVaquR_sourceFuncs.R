# Funció per obtenir dades bàsiques del DOI utilitzant CrossRef
get_crossref_data <- function(doi) {
  response <- cr_works(dois = doi)
  if (!is.null(response$data)) {
    data <- response$data
    tibble(
      DOI = data$doi,
      Title = data$title,
      Authors = paste(sapply(data$author, function(x) {
        # Extraer apellido y nombre completo
        apellido <- x$family
        nombre_completo <- x$given  # El nombre completo
        
        # Formatear el autor como 'Apellido, Nombre Completo'
        paste(apellido, ",", nombre_completo)
      }), collapse = "; "),
      Year = sub("^([0-9]{4}).*", "\\1",data$issued),
      Journal = data$container.title,
      Volume=data$volume,
      ISSN = data$issn
    )%>%
      mutate(
        ISSN = str_split_fixed(ISSN, ",", 2)[, 1],
        ISSN_2 = str_split_fixed(ISSN, ",", 2)[, 2])
  } else {
    tibble(DOI = doi, Title = NA, Authors = NA, Year = NA, Journal = NA, ISSN = NA, ISSN2 = NA)
  }
}

# Obtenir cites des de Scopus (requereix clau API)
get_scopus_citations <- function(doi) {
  response <- scopus_search(query = paste0("DOI(", doi, ")"), api_key = scopus_key)
  if (!is.null(response$entries[[1]]$`citedby-count`)) {
    as.numeric(response$entries[[1]]$`citedby-count`)
  } else {
    0
  }
}

# Funció per obtenir l'índex SJR des de SCImago
get_sjr_data <- function(issn, Year) {
  
  if(Year>max(SJR_Data$year)){
    Year=max(SJR_Data$year)
  }
  
  SJR_journal <- SJR_Data %>% dplyr::filter(year%in%Year & (ISSN%in%issn | ISSN_2%in%issn ))
  
  if (nrow(SJR_journal)>0) {
    tibble(
      IF_SJR=SJR_journal$SJR,
      Quartile_SJR=SJR_journal$`SJR Best Quartile`,
      Categoria_SJR = SJR_journal$Categories,
    )
    
    
  } else {
    tibble( IF_SJR = NA, Quartile_SJR = NA, Categoria_SJR=NA)
  }
}


# Funció per obtenir l'índex JCR des de SCImago
get_jcr_data <- function(issn, year) {
  
  if(year>max(JCR_Data$AÑO)){
    year=max(JCR_Data$AÑO)
    print(year)
  }
  
  JCR_journal <- JCR_Data %>% dplyr::filter(AÑO%in%year , (ISSN%in%issn | eISSN%in%issn))
  print(nrow(JCR_journal))
  if (nrow(JCR_journal)>0) {
    tibble(
      IF_JCR=JCR_journal$FACTOR_IMPACTO,
      Quartile_JCR=JCR_journal$CUARTIL ,
      Categoria_JCR = JCR_journal$DESCRIPCION_CATEGORIA,
      Rank_JCR= JCR_journal$RANKING_CATEGORÍA
    ) %>% 
      mutate(Pos=sub("/.*", "", Rank_JCR)) %>% 
      filter(Pos==max(Pos)) %>% 
      select(-Pos) %>% 
      .[1,]
    
    
  } else {
    tibble( IF_JCR = NA, Quartile_JCR = NA, Categoria_JCR=NA, Rank_JCR=NA)
  }
}
