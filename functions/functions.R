remove_empty_lines <- function(data) {
  filter(data, raw != "")
}

detect_characters <- function(data) {
  char_imp <- read.csv("data/char_imp.csv")
  char_alias <- read.csv("data/char_alias.csv")
  char_indent <- "                                "
  n <- nchar(char_indent)
  movie_chars <- data %>%
    mutate(
      is_char = str_starts(raw, char_indent) &
        str_sub(raw, n + 1, n + 1) != " ",
      line = 1:n(),
      character = str_trim(raw),
      character = na.locf(character, na.rm = TRUE),
    ) %>%
    filter(is_char) %>%
    select(-is_char, -raw) %>%
    left_join(char_imp, c("character" = "char")) %>%
    filter(imp != 0, !is.na(imp)) %>%
    left_join(char_alias, c("character" = "alias_char")) %>%
    mutate(character = case_when(
      is.na(char) ~ character,
      TRUE ~ char
    )) %>%
    select(-char)

  return(movie_chars)
}

detect_scenes <- function(data) {
  scene_indent <- "     "
  ext_scene <- paste0(scene_indent, "EXT")
  int_scene <- paste0(scene_indent, "INT")
  n <- nchar(scene_indent)
  movie_scenes <- data %>%
    mutate(
      is_scene =
        (str_starts(raw, ext_scene) | str_starts(raw, int_scene)) &
          str_sub(raw, n + 1, n + 1) != " ",
      scene = str_trim(raw),
      line = 1:n(),
      scene_number = 1:n()
    ) %>%
    filter(is_scene) %>%
    select(-is_scene, -raw)

  return(movie_scenes)
}

join_chars_and_scenes <- function(chars, scenes) {
  n <- max(chars$line)

  by_char_scene <- data_frame(line = 1:n) %>%
    left_join(chars, "line") %>%
    left_join(scenes, "line") %>%
    mutate(
      character = ifelse(line == 1, "0", character),
      scene = ifelse(line == 1, "0", scene),
      scene_number = ifelse(line == 1, "0", scene_number),
      scene = zoo::na.locf(scene, na.rm = TRUE),
      character = zoo::na.locf(character, na.rm = TRUE),
      scene_number = zoo::na.locf(scene_number, na.rm = TRUE),
      scene_number = as.numeric(scene_number)
    ) %>%
    filter(scene != "0") %>%
    group_by(scene_number, character, scene) %>%
    arrange(scene_number) %>%
    ungroup()

  scenes <- scenes$scene_number %>%
    unique() %>%
    sort()

  df_scenes <- data_frame(scenes) %>%
    mutate(n = 1:n())

  by_char_scene %>%
    left_join(df_scenes, c("scene_number" = "scenes")) %>%
    select(-line, -scene_number) %>%
    mutate(scene_number = n) %>%
    select(-n)
}

create_movie_db <- function(chars, scenes) {
  chars %>%
    join_chars_and_scenes(scenes) %>%
    filter(scene_number %in% 1:dim(scenes)[1])
}

preprocess_movie_data <- function() {
  raw <- readLines("data/magnolia_script.txt")
  data <- data_frame(raw = raw)
  data <- remove_empty_lines(data)
  chars <- detect_characters(data)
  scenes <- detect_scenes(data)
  movie_db <- create_movie_db(chars, scenes)

  script_scenes <- movie_db %>%
    left_join(scenes, "scene") %>% 
    mutate(st = lead(line),
           diff = line - st) %>% 
    filter(diff != 0) %>% 
    mutate(line_start = line,
           line_end = st) %>% 
    select(scene_number = scene_number.x, line_start, line_end)
  
  by_speaker_scene <- movie_db %>%
    count(scene_number, character)

  speaker_scene_matrix <- by_speaker_scene %>%
    acast(character ~ scene_number, fun.aggregate = length)
  speaker_scene_matrix <- speaker_scene_matrix[, colSums(speaker_scene_matrix) >= 1]

  saveRDS(speaker_scene_matrix, "data/speaker_scene_matrix.rds")
  saveRDS(script_scenes, "data/script_scenes.rds")
}

load_scene_matrix <- function() {
  speaker_scene_matrix <- readRDS("data/speaker_scene_matrix.rds")
}

get_network <- function(mult) {
  lapply(seq_len(ncol(mult)), function(i) {
    # use as.matrix to handle case where i == 1
    mat <- as.matrix(mult[, i])
    mat <- as.matrix(mat[rowSums(mat) > 0, ])
    co <- mat %*% t(mat)
    melt(co, varnames = c("Source", "Target"), value.name = "scenes") %>%
      filter(scenes > 0)
  })
}

get_scene_script <- function(n) {
  movie_db <- readRDS("data/script_scenes.rds") %>% 
    filter(scene_number == n)
  raw <- readLines("data/magnolia_script.txt")
  raw[(min(movie_db$line_start)-2):(max(movie_db$line_end)-2)]
}

get_cum_network <- function(mult) {
  char_imp <- read.csv("data/char_imp.csv")
  mult <- lapply(seq_len(ncol(mult)), function(i) {
    # use as.matrix to handle case where i == 1
    mat <- as.matrix(mult[, 1:i])
    mat <- as.matrix(mat[rowSums(mat) > 0, ])
    co <- mat %*% t(mat)
    melt(co, varnames = c("Source", "Target"), value.name = "scenes") %>%
      filter(scenes > 0)
  })

  mult[[322]] %>%
    left_join(char_imp, c("Source" = "char")) %>%
    left_join(char_imp, c("Target" = "char"))
}
