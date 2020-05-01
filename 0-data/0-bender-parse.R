# Patricia Bender Salaries Script, adapted from:
# https://rpubs.com/brandonemmerich/collecting-nba-data

# ---- start --------------------------------------------------------------

library("tidyverse")
library("rvest")
library("stringr")

# Create a directory for the data
local_dir    <- "0-data/salaries"
data_source  <- paste0(local_dir, "/raw")
if (!file.exists(local_dir)) dir.create(local_dir, recursive = T)
if (!file.exists(data_source)) dir.create(data_source, recursive = T)

nba_teams <- read_csv("offline/bender_teams_edit.csv")

# Function to parse through each text file for player salary information
parse.salary.data.2.0 <- function(x) {
  print(x)
  raw_file <- read_file(x)
  
  split_txt <- raw_file %>% 
    str_split("\n") %>% 
    unlist() %>% 
    data.frame(value = .) %>% 
    filter(value != "")
  
  
  #What season does this salary correspond to?
  season.roster <<- if_else(parse_number(basename(x)) < 80,
                            parse_number(basename(x)) + 2000,
                            parse_number(basename(x)) + 1900)
  
  #How do we split each team, with a series of dashes or a double line break?
  regex.splitting <- ifelse(season.roster > 2007, "----", "\n\n|\n \n|\n  \n")
  regex.splitting <- ifelse(season.roster == 1996, "----", regex.splitting)
  # regex.splitting <- ifelse(season.roster == 1997, "\n \n", regex.splitting)
  
  #Collect, combine, and clean the data
  raw_file %>% 
    #Split text by team
    str_split(regex.splitting) %>% unlist() %>% #.[5:length(.)] %>%
    #We'll come back to this
    map(clean.salary.2.0) %>%
    bind_rows() %>%
    # filter(!is.na(player_raw), !is.na(team_raw)) %>% 
    mutate(season = season.roster)
}

# Called within function above to extract player information to each piece of
#  text file that includes a team grouping
clean.salary.2.0 <- function(x) {
  players_temp <-
    x %>% 
    # raw_file %>% 
    # #Split text by team
    # str_split(regex.splitting) %>% unlist() %>% .[1] %>% 
    str_split("\n") %>% 
    unlist() %>% 
    data.frame(value = .) %>% 
    filter(grepl("\\.{2,}", value))
  
  if (nrow(players_temp) == 0) {
    return(data.frame(player_raw = NA,
                      salary_raw = NA,
                      team = NA))
  } else {
    players <-
      players_temp %>% 
      rowwise() %>% 
      summarise(player_raw = str_split(value, "\\.{2,}")[[1]][1],
                salary_raw = str_split(value, "\\.{2,}")[[1]][2]) %>% 
      mutate_all(str_trim)
    
  }
  
  team <-
    x %>% 
    # raw_file %>% 
    # #Split text by team
    # str_split(regex.splitting) %>% unlist() %>% .[1] %>% 
    str_split("\n") %>% 
    unlist() %>% 
    data.frame(value = .) %>% 
    mutate_all(str_trim) %>% 
    filter(!grepl("\\.+", value),
           value != "",
           !grepl("Player", value, ignore.case = T)) %>% 
    as_vector()
  
  if (length(team) > 0 & season.roster != 1997) {
    players$team_raw <- team[1]
    
    team_temp <- which(sapply(nba_teams$team,
                              function(x) grepl(x, team[1])))
    
    if (length(team_temp > 0)) {
      players$team      <- nba_teams$team_name[team_temp]
      players$team_abbr <- nba_teams$team_abbr[team_temp]
    } else {
      players$team      <- NA
      players$team_abbr <- NA
    }
    
  } else if (season.roster %in% c(1995:1997, 2010:2016)) {
    # What if we have 1995 where the first entry was the team?
    team <- x %>% 
      # raw_file %>% 
      # #Split text by team
      # str_split(regex.splitting) %>% unlist() %>% .[1] %>% 
      str_split("\n") %>% 
      unlist() %>% 
      data.frame(value = .) %>% 
      mutate(value = str_trim(value)) %>% 
      filter(value != "") %>% 
      slice(1)
    
    team_temp <- which(sapply(nba_teams$team,
                              function(x) grepl(x, team[1,])))
    
    players$team_raw <- team[1,]
    
    if (length(team_temp > 0)) {
      players$team      <- nba_teams$team_name[team_temp]
      players$team_abbr <- nba_teams$team_abbr[team_temp]
    } else {
      players$team      <- NA
      players$team_abbr <- NA
    }
    
  } else {
    players$team_raw <- "error"
  }
  
  return(players)
}

# ---- read-write ---------------------------------------------------------


bender_files <- dir(data_source, full.names = T)

all_salaries <- bender_files %>% 
  # Apply the custom function to parse through raw txt files
  map(parse.salary.data.2.0) %>% 
  bind_rows() %>% 
  arrange(season) %>% 
  # Pelicans correction
  mutate(team_abbr = ifelse(season < 2003 & team_abbr == "CHA",
                            "NOP", team_abbr),
         # Popeye Jones correction
         salary_raw = ifelse(salary_raw == "2,531 250",
                             "2,531,250", salary_raw),
         salary = parse_number(salary_raw))

all_salaries %>% 
  filter(!is.na(player_raw)) %>% 
  write_csv(paste0(local_dir, "/bender_raw.csv"))