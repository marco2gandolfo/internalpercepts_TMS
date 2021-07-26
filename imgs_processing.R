library(magick)
library(tidyverse)
library(EBImage)


set1 <- "/home/marcogdesktop/Documents/internalpercepts_pilot/stimuli/set1"
set2 <- "/home/marcogdesktop/Documents/internalpercepts_pilot/stimuli/set2"
set1 <- "D:/all_stims/set1"
set2 <- "D:/all_stims/set2"




set1 <- "C:/Users/uomom/Desktop/second_images_resized/set1_backup_newnumbers"

set2 <- "C:/Users/uomom/Desktop/second_images_resized/set2_backup_newnumbers"

imgs1 <- list.files(set1, pattern = ".jpg|.JPG", full.names = TRUE)
imgs2 <- list.files(set2, pattern = ".jpg|.JPG", full.names = TRUE)

imgnames <- basename(imgs2)

imglist <- list()


for(img in seq_along(imgs2)){
  
  imglist[[img]] <- readImage(imgs2[img])
  imglist[[img]] <- resize(imglist[[img]], 800)
  
  gc()
  print(img)
}



for(img in seq_along(imglist)){
  writeImage(imglist[[img]], paste0(set2, "/resize_", imgnames[img]),quality = 85)
  print(img)
}


### flip and flop

set1 <- "C:/Users/uomom/Desktop/second_images_resized/set1_backup_resized"

set2 <- "C:/Users/uomom/Desktop/second_images_resized/set2_backup_resized"

imgs1 <- list.files(set1, pattern = ".jpg|.JPG", full.names = TRUE)
imgs2 <- list.files(set2, pattern = ".jpg|.JPG", full.names = TRUE)

imgnames1 <- basename(imgs1)

imglist <- list()

for(img in seq_along(imgs1)){
  imglist[[img]] <- readImage(imgs1[img])
  imglist[[img]] <- flop(imglist[[img]])

  gc()
  print(img)
}

for(img in seq_along(imglist)){
  writeImage(imglist[[img]], paste0("C:/Users/uomom/Desktop/second_images_resized/set1_flop/fl_"
, imgnames[img]), quality = 100)
  print(img)
}

rm(imglist)
rm(imgnames)
rm(imgs1)

imgs2 <- list.files(set2, pattern = ".jpg|.JPG", full.names = TRUE)

imgnames <- basename(imgs2)

imglist <- list()

for(img in seq_along(imgs2)){
  imglist[[img]] <- readImage(imgs2[img])
  imglist[[img]] <- flop(imglist[[img]])

  gc()
  print(img)
}

for(img in seq_along(imglist)){
  writeImage(imglist[[img]], paste0("C:/Users/uomom/Documents/MEGAsync/Images_scenes/renamed_resized_set1_and_2/set2_flop/fl_"
, imgnames[img]), quality = 85)
  print(img)
}



## paths for new control images

path <- "C:/Users/uomom/Desktop/new_control/new control images"
imgs <- list.files(path, pattern = "jpg|JPG", recursive = TRUE, full.names = TRUE)
relnames <- data.frame(x = list.files(path, pattern = "jpg|JPG", recursive = TRUE, full.names = FALSE))


therelpaths <- relnames %>% 
                separate(x, c("set", "mem", "name"), remove = FALSE, sep = "/") %>% 
                unite("partpath",  set, mem, remove = FALSE, sep = "/")




## futurenames split and remove foil and scene number
futurenames <- as.data.frame(str_split(basename(imgs), "_", simplify = TRUE))

futurenames <-  futurenames %>% 
                  rename( imno = V1, obj = V2, foilno = V3) %>% 
                  select(-foilno) %>% 
                  unite("realname", imno, obj, remove = FALSE)
  

imglist <- list()


for(img in seq_along(imgs)){
  
  imglist[[img]] <- readImage(imgs[img])
  imglist[[img]] <- resize(imglist[[img]], 800)
  
  gc()
  print(img)
}


for(img in seq_along(imglist)){
  writeImage(imglist[[img]], paste0(path, "/",therelpaths$partpath[img], "/",futurenames$realname[img], ".jpg"),quality = 100)
  print(img)
}

## generate flop

floppath <- "C:/Users/uomom/Desktop/new_control/new control images flop"

imgflop <- list()

for(img in seq_along(imglist)){
 
  imgflop[[img]] <- flop(imglist[[img]])
  
  gc()
  print(img)
}



for(img in seq_along(imglist)){
  writeImage(imgflop[[img]], paste0(floppath, "/",therelpaths$partpath[img], "/",futurenames$realname[img], ".jpg"),quality = 100)
  print(img)
}


## do the same procedure for the box images


## paths for new control images

path <- "C:/Users/uomom/Desktop/new_control/AVEbox"
imgs <- list.files(path, pattern = "jpg|JPG", recursive = TRUE, full.names = TRUE)
relnames <- data.frame(x = list.files(path, pattern = "jpg|JPG", recursive = TRUE, full.names = FALSE))


therelpaths <- relnames %>% 
  separate(x, c("set", "mem", "name"), remove = FALSE, sep = "/") %>% 
  unite("partpath",  set, mem, remove = FALSE, sep = "/")


## futurenames split and remove foil and scene number
futurenames <- as.data.frame(str_split(basename(imgs), "_", simplify = TRUE))

futurenames <-  futurenames %>% 
  rename( imno = V1, obj = V2, foilno = V3) %>% 
  select(-foilno) %>% 
  unite("realname", imno, obj, remove = FALSE)


imglist <- list()


for(img in seq_along(imgs)){
  
  imglist[[img]] <- readImage(imgs[img])
  imglist[[img]] <- resize(imglist[[img]], 800)
  
  gc()
  print(img)
}


for(img in seq_along(imglist)){
  writeImage(imglist[[img]], paste0(path, "/",therelpaths$partpath[img], "/",futurenames$realname[img], "_box.jpg"),quality = 100)
  print(img)
}

## generate flop

floppath <- "C:/Users/uomom/Desktop/new_control/AVEbox flop"



imgflop <- list()

for(img in seq_along(imglist)){
  
  imgflop[[img]] <- flop(imglist[[img]])
  
  gc()
  print(img)
}



for(img in seq_along(imglist)){
  writeImage(imgflop[[img]], paste0(floppath, "/",therelpaths$partpath[img], "/",futurenames$realname[img], "_box.jpg"),quality = 100)
  print(img)
}


## correct the name of foils again because I am stupid


path <- "C:/Users/uomom/Desktop/new_control/new control images"
imgs <- list.files(path, pattern = "jpg|JPG", recursive = TRUE, full.names = TRUE)

newname <- str_replace_all(basename(imgs), ".jpg", "_foil.jpg")

newfullname <- paste0(dirname(imgs),"/",newname)

file.rename(imgs, newfullname)

### new full name for flop

path <- "C:/Users/uomom/Desktop/new_control/new control images flop"
imgs <- list.files(path, pattern = "jpg|JPG", recursive = TRUE, full.names = TRUE)

newname <- str_replace_all(basename(imgs), ".jpg", "_foil.jpg")

newfullname <- paste0(dirname(imgs),"/",newname)

file.rename(imgs, newfullname)


### new fullnames again based on the script


## correct the name of foils again because I am stupid


path <- "C:/Users/uomom/Desktop/new_control/new control images flop/SET2"
imgs <- list.files(path, pattern = "jpg|JPG", recursive = TRUE, full.names = TRUE)

names <- data.frame(x = str_replace_all(basename(imgs), ".jpg", "") )

names <- names %>% 
          separate(x, c("no", "obj", "tag"), remove = FALSE, sep = '_') %>% 
          mutate(no = as.numeric(no)) %>% 
          arrange(by = no) %>% 
          mutate(newno = rep(seq.int(65,96), 2)) %>% 
          unite("correct_name", newno, obj, tag)

newnames <- paste0(names$correct_name, ".jpg")

newfullname <- paste0(dirname(imgs),"/",newnames)

file.rename(imgs, newfullname)

### new full name for flop

path <- "C:/Users/uomom/Desktop/new_control/new control images flop"
imgs <- list.files(path, pattern = "jpg|JPG", recursive = TRUE, full.names = TRUE)

newname <- str_replace_all(basename(imgs), ".jpg", "_foil.jpg")

newfullname <- paste0(dirname(imgs),"/",newname)

file.rename(imgs, newfullname)