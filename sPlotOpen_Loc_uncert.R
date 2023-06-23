# Which datasets are the ones with high location uncertainty? 

plots <- st_read(here("../data/sPlotOpen/sPlotOpen_Germany_Grassland.gpkg"))
iDs <- plots$PlotObservationID

load(here("../data/sPlotOpen/sPlotOpen.RData"))

header.oa[header.oa$PlotObservationID %in% iDs,]

# which are over 100m uncertain? 
IDs_loc_uncert <- header.oa$PlotObservationID[header.oa$GIVD_ID %in% unique(plots$GIVD_ID[plots$Location_uncertainty > 100])]

table(IDs_loc_uncert %in% iDs)
# about half of the grassland plots in Germany are over 100m uncertain

unique(plots$GIVD_ID[plots$Location_uncertainty > 100])
# belong to three GIVD_IDs 

IDs <- iDs
level <- "database"
out.file <- paste0(here("test.bib"))


meta_iDs <- metadata.oa %>% 
  filter(PlotObservationID %in% IDs) %>% 
  distinct()

bibtexkeys <- meta_iDs %>% 
  pull(all_of(getkey)) # getkey points to DB_BIBTEXKEY for databases

reference.oa %>% 
  dplyr::select(-Fullref) %>% 
  filter(BIBTEXKEY %in% bibtexkeys) |>
  pull(BIBTEXKEY)


ID_DB_key <- metadata.oa |>
  select(DB_BIBTEXKEY, PlotObservationID)


plots_key <- merge(plots, ID_DB_key)

table(plots_key$Location_uncertainty, plots_key$DB_BIBTEXKEY)

# chytr2003a, dengler2012a and garbolino2012a are safe
# ask ewald2012a and jandt2012a 

# which Plots don't have a literature reference? 
meta_iDs |>
  filter(is.na(DB_BIBTEXKEY)) |>
  pull(PlotObservationID)

# # sPlotOpen_citation: 
#   
#   function(IDs, level=c("plot", "database"), out.file){ 
#     ## IDs - vector of PlotObservationIDs,
#     ## level - At what level should the bibliorefrence be extracted? at the level of individual plot, or GIVD datasets?
#     ## out.file - filename where to sink the reference list (also as a .bib file)
#     require(dplyr)
#     require(bib2df)
#     if(level=="plot") {getkey <- "BIBTEXKEY"}
#     if(level=="database") {getkey <- "DB_BIBTEXKEY"}
#     bibtexkeys <- metadata.oa %>% 
#       filter(PlotObservationID %in% IDs) %>% 
#       distinct() %>% 
#       pull(all_of(getkey))
#     df2bib(reference.oa %>% 
#              dplyr::select(-Fullref) %>% 
#              filter(BIBTEXKEY %in% bibtexkeys), file = out.file)
#     message("WARNING: This is a beta-version. References were parsed and converted automatically. They might need to be double-checked")
#   }
# 
# sPlotOpen_citation(IDs=iDs, level="database",
#                    out.file = "test.bib") 
