library(tidyverse)
library(youtubecaption)
library(readxl)
library(janitor)

links <- read_excel("NSSD Links.xlsx", range = "A2:E75")

links <- links %>%
        clean_names() %>%
        mutate(vid = str_replace_all(video_url, ".*=(.*)$", "\\1"))

safe_scripts <- safely(get_caption)

nssd_scripts <- map(links$video_url, safe_scripts)

output <- map(1:length(nssd_scripts), ~pluck(nssd_scripts, . , "result")) %>%
        compact() %>%
        bind_rows %>%
        inner_join(x = links, y = ., by = "vid")

write_csv(output, "transcripts.csv")
