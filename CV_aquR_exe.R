library(rcrossref)
library(tidyverse)
library(httr)
library(jsonlite)
library(RefManageR)
library(rscopus)
library(readr)
library(lubridate)
library(writexl)

setwd("D:/OneDrive - udl.cat/Altres/")
source("./CVaquR_sourceFuncs.R")
#Carrega les dades de SJR

load("D:/OneDrive - udl.cat/Altres/SJR_data.RData")
load("D:/OneDrive - udl.cat/Altres/JCR_data.RData")

# Configura la teva clau API (per a WoS, Scopus, etc.)
scopus_key <- "7733665b865da28bfc36dbe1690941e7"

dataJSON <- fromJSON("./PereJoanGelabert_Web_of_Science_Researcher_CV_20250117.json")
dois <- dataJSON$records$publication$list$doi
manualdois <- c("10.1186/s42408-023-00228-w","10.1080/19475705.2024.2447514")
dois <- c(dois, manualdois)

# Iterar sobre els DOIs i compilar la informació
resultats <- lapply(dois, function(doi) {
  cr_data <- get_crossref_data(doi)
  cites <- get_scopus_citations(doi)
  sjr_data <- if (!is.na(cr_data$ISSN)) get_sjr_data(Year = as.integer(cr_data$Year),issn = cr_data$ISSN) else tibble(IF_SJR = NA, Quartile_SJR = NA, Categoria_SJR=NA)
  jcr_data <- if (!is.na(cr_data$ISSN)) get_jcr_data(year = as.integer(cr_data$Year),issn = cr_data$ISSN) else tibble(IF_JCR = NA, Quartile_JCR = NA, Categoria_JCR=NA,, Rank_JCR=NA)
  bind_cols(cr_data, tibble(CitationsSJR = cites), sjr_data,jcr_data)
}) %>% bind_rows() %>%
  select(Authors, Title,Year,Journal, Volume, ISSN,DOI,IF_JCR,Quartile_JCR, Categoria_JCR,Rank_JCR, CitationsSJR,IF_SJR,Quartile_SJR,Categoria_SJR) %>% 
  mutate(Indexat_Scopus=ifelse(is.na(CitationsSJR),"NO","SI"),
         Indexat_WOS=ifelse(is.na(IF_JCR),"NO","SI"),
         Citations_JCR="Cerca manual",
         Clau="A",
         Rev_vol=paste0(Journal,", ",Volume)) %>% 
  select(Authors, Title,Year,Clau,Rev_vol, ISSN,DOI,Indexat_WOS,Citations_JCR,IF_JCR, Quartile_JCR, Categoria_JCR, Rank_JCR,Indexat_Scopus,CitationsSJR,IF_SJR,Quartile_SJR,Categoria_SJR) %>% 
  arrange(Year) %>% 
  left_join(.,dataJSON$records$publication$list %>% select(doi,citation_count) %>% mutate(doi=tolower(doi)), by=c("DOI"="doi")) %>% 
  rename(Citations_JCR2=citation_count) %>% 
  mutate(Citations_JCR=Citations_JCR2) %>% 
  select(-Citations_JCR2) %>%  
  t() %>% 
  data.frame() %>% 
  rownames_to_column("Item") %>% 
  rename(X1=2) %>%  
  mutate(Item=c("Autors/res (per ordre de signatura): ",
                "Títol: ",
                "Any: ",
                "Clau (A: article, R: review): ",
                "Revista (títol, volum, pàgina inicial-final): ",
                "ISSN: ",
                "DOI: ",
                "Indexat a WoS (SI/NO): ",
                "Nombre de citacions de l’article (WoS): ",
                "JIF del JCR: ",
                "Quartil JCR: ",
                "Categoria JCR: ",
                "Ranking JCR: ",
                "Indexat a Scopus (SI/NO): ",
                "Nombre de citacions de l’article (Scopus): ",
                "Índex SJR: ",
                "Quartil SJR: ",
                "Categoria SJR: "))


# Guardar els resultats a un fitxer CSV
write_xlsx(resultats, "articles_infoAQU.xlsx")

