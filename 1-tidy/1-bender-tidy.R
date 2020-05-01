# Tidy the raw data

# ---- start --------------------------------------------------------------

library("tidyverse")
library("rvest")
library("stringr")

# Create a directory for the data
local_dir    <- "1-tidy"
if (!file.exists(local_dir)) dir.create(local_dir, recursive = T)

nba_teams <- read_csv("offline/bender_teams_edit.csv")

all_salaries <- read_csv("0-data/salaries/bender_raw.csv")


# ---- players ------------------------------------------------------------

# Correct for typos, not that frequent considering the sheet number of obs
player_typos      <- read_csv("offline/bender_typos_edit.csv")
typo_cross        <- as.vector(player_typos$good)
names(typo_cross) <- player_typos$bad

all_players <- all_salaries %>% 
  filter(!is.na(team_abbr),
         !grepl("total", player_raw, ignore.case = T),
         !grepl(paste(nba_teams$team, collapse = "|"),
                player_raw, ignore.case = T)) %>%
  mutate(player = str_remove_all(str_to_lower(player_raw),
                                 "\\s*\\([^\\)]+\\)")) %>% 
  mutate(player = ifelse(is.na(typo_cross[player]),
                         player,
                         typo_cross[player])) %>% 
  arrange(team_abbr, season)



all_players %>% 
  select(season, team, team_abbr, player, salary) %>% 
  write_csv(paste0(local_dir, "/bender_salaries.csv"))

