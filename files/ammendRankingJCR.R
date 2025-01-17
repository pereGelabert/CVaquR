library(readxl)
library(tidyverse)

JCR_Data <- read_xlsx("D:/OneDrive - udl.cat/Altres/JCR_excel.xlsx") %>% 
  mutate(
    # Usamos case_when para modificar solo los valores que no tienen "/"
    `RANKING CATEGORÍA` = case_when(
      grepl("/", `RANKING CATEGORÍA`) ~ `RANKING CATEGORÍA`,  # Si contiene "/", deja el valor como está
      TRUE ~ paste(
        month(as.Date(as.numeric(`RANKING CATEGORÍA`), origin = "1899-12-30")),
        year(as.Date(as.numeric(`RANKING CATEGORÍA`), origin = "1899-12-30")) %% 100,
        sep = "/"
      )
    )
  ) %>% rename_with(function(x) gsub(" ", "_", x))

save(JCR_Data, file="D:/OneDrive - udl.cat/Altres/JCR_data.RData")
