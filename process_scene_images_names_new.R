library(tidyverse)
library(magick)


path <- "C:/Users/uomom/Documents/MEGAsync/Images_scenes/New/1stselection/"

imgs <- list.files(path,  full.names = TRUE, recursive = TRUE)

imglist <- list()
imgnames <- basename(imgs)


for(img in seq_along(imgs)){
  
  imglist[[img]] <- image_read(imgs[img])
  imglist[[img]] <- image_resize(imglist[[img]], "700x")
  
  gc()
  print(img)
}




bwlist <- list()


for(img in seq_along(imglist)) {
bwlist[[img]] <-  image_convert(imglist[[img]], colorspace = "gray")
gc()

print(img)

}


for(img in seq_along(imglist)){
  image_write(imglist[[img]], paste0("C:/Users/uomom/Desktop/second_images_resized/", imgnames[img]),quality = 100)
  print(img)
}
  



for(img in seq_along(bwlist)){
  image_write(bwlist[[img]], paste0("C:/Users/PC/Desktop/first_images_resized/BW/", imgnames[img]),quality = 100)
print(img)
}

### THIS SCRIPT RENAMES all the images coming from MARTINA'S NAMES

path <- "C:/Users/uomom/Desktop/second_images_resized/"
path <- "/home/marcogdesktop/MEGAsync/Images_scenes/New/stimuli_copy_oldnames_correct/"
imgs <- list.files(path, pattern = ".jpg|.JPG", full.names = TRUE)

imglist <- list()

fname <- basename(imgs)
d <- data.frame(fname)
d <- d %>% mutate(fnamenoext = str_replace_all(fname,".jpg|.JPG","")) %>%  separate(fnamenoext, into = c("no","place","obj","transp","blur"),sep = "_", remove = FALSE)

## assign visible to the stimuli non blurred
d$transp[is.na(d$transp) ] <- "visible"

## sorting column
d <- d %>% mutate(imgord = case_when(transp == "E" ~ 5,
                       transp == "H" ~ 4,
                       transp == "M" ~ 3,
                       transp == "F" ~ 2,
                       transp == "grey" ~ 1,
                       TRUE ~ 0))



dfil <- d %>% mutate(catord = case_when(obj == "person" ~ 1,
                                         obj == "furniture" ~ 2,
                                         obj == "car" ~ 3,
                                         TRUE ~ 4),
                      transparency = case_when(transp == "E" ~ "empty",
                                               transp == "H" ~ "trans",
                                               transp == "M" ~ "lowtrans",
                                               transp == "F" ~ "notrans",
                                               transp == "grey" ~ "box",
                                               TRUE ~ "full"),
                      trans_order = case_when(transparency == "full" ~ 0,
                                              transparency == "box" ~ 1,
                                              transparency == "empty" ~ 2,
                                              transparency == "trans" ~ 3,
                                              transparency == "lowtrans" ~ 4,
                                              TRUE ~ 5))

dfil %>% arrange(by = no, obj, blur)

dfil <- dfil %>% arrange(by = no, obj, catord, trans_order, blur) 

## assign 0 to blur level if it is NA
dfil$blur[is.na(dfil$blur) ] <- 0

## correct names of BLUR level
dfil <- dfil %>% mutate(blur_ord = rep(seq(1:14), nrow(dfil)/14)) %>% 
                 mutate(realblur = case_when(blur_ord == 3 | blur_ord == 6 | blur_ord == 9 | blur_ord == 12 ~ "L",
                                     blur_ord == 4 | blur_ord == 7 | blur_ord == 10 | blur_ord == 13 ~ "M",
                                     blur_ord == 5 | blur_ord == 8 | blur_ord == 11 | blur_ord == 14 ~ "H",
                                     TRUE ~ "null"))

dord <- dfil %>% arrange(by =  no, catord, trans_order, realblur) %>% 
                  unite("newname", no, obj, transparency, realblur, remove  = FALSE)

dir.create(paste0(getwd(), "/renamed_all/"))

file.copy()

file.copy(paste0("/home/marcogdesktop/MEGAsync/Images_scenes/New/stimuli_copy_oldnames_correct/", dord$fname), paste0(getwd(),"/renamed_all/", dord$newname, ".jpg"))


#### now read the img sets and try to see if they are balanced

set1 <- "/home/marcogdesktop/MEGAsync/Images_scenes/New/stimuli_renamed_all/set1"
set2 <- "/home/marcogdesktop/MEGAsync/Images_scenes/New/stimuli_renamed_all/set2"

set1 <- "C:/Users/uomom/Desktop/second_images_resized/set1_backup_oldnumbers"
set2 <- "C:/Users/uomom/Desktop/second_images_resized/set2_backup_oldnumbers"

imgs1 <- list.files(set1, pattern = ".jpg|.JPG", full.names = TRUE)
imgs2 <- list.files(set2, pattern = ".jpg|.JPG", full.names = TRUE)


fname1 <- basename(imgs1)
fname2 <- basename(imgs2)

d1 <- data.frame(fname1)
d2 <- data.frame(fname2)

d1 <- d1 %>% mutate(fnamenoext = str_replace_all(fname1,".jpg|.JPG","")) %>%  separate(fnamenoext, into = c("no","category","transp","blur"),sep = "_", remove = FALSE)

d2 <- d2 %>% mutate(fnamenoext = str_replace_all(fname2,".jpg|.JPG","")) %>%  separate(fnamenoext, into = c("no","category","transp","blur"),sep = "_", remove = FALSE)



d1 %>% group_by(category) %>%  tally() %>% mutate(n/11)
d2 %>% group_by(category) %>% tally() %>% mutate(n/11)

d1 %>% group_by(no) %>%  tally() %>% mutate(n/11) %>% View()
d2 %>% group_by(no) %>% tally() %>% mutate(n/11) %>% View()



chk1 <- d1 %>% group_by(no,category) %>%  tally() %>% mutate(num_cat = n/4)
chk2 <- d2 %>% group_by(no,category) %>% tally() %>% mutate(num_cat = n/4)

bind_cols(chk1, chk2) -> checkcategories

### check if the pairs are balanced :) they are ranging from 9 to 7, so it is not that more often is one or the other
checkcategories <- checkcategories %>% 
                    unite("bothcats", category...2, category...6, remove = FALSE)

checkcategories %>% group_by(bothcats) %>% tally()

########################################################## Final Renaming of the sets #######

d1 <- d1 %>%  mutate(catord = case_when(category == "person" ~ 1,
                                        category == "furniture" ~ 2,
                                        category == "car" ~ 3,
                                  TRUE ~ 4),
               trans_order = case_when(transp == "full" ~ 0,
                                       transp == "box" ~ 1,
                                       transp == "empty" ~ 2,
                                       transp == "trans" ~ 3,
                                       TRUE ~ 4))

d1 <- d1 %>% arrange(by = catord, no)


      realno_person <- rep(seq.int(1,64, by = 4), each = 11)
      realno_furniture <- rep(seq.int(2,64, by = 4), each = 11)
      realno_car <- rep(seq.int(3,64, by = 4), each = 11)
      realno_animal <- rep(seq.int(4,64, by = 4), each = 11)

d1$realnumber <- c(realno_person,realno_furniture, realno_car, realno_animal)


d2 <- d2 %>%  mutate(catord = case_when(category == "person" ~ 1,
                                     category == "furniture" ~ 2,
                                     category == "car" ~ 3,
                                     TRUE ~ 4),
                  trans_order = case_when(transp == "full" ~ 0,
                                          transp == "box" ~ 1,
                                          transp == "empty" ~ 2,
                                          transp == "trans" ~ 3,
                                          TRUE ~ 4))

d2 <- d2 %>% arrange(by = catord, no)

d2$realnumber <- c(realno_person,realno_furniture, realno_car, realno_animal)

d1 <- d1 %>% unite("newname", realnumber, category, transp, blur, remove = FALSE)

d2 <- d2 %>% unite("newname", realnumber, category, transp, blur, remove = FALSE)



file.rename(paste0(set1, "/", d1$fname1), paste0(set1, "/", d1$newname, ".jpg"))
file.rename(paste0(set2, "/", d2$fname2), paste0(set2, "/", d2$newname, ".jpg"))

write.csv(d1, paste0(set1, "/set1_old_to_new_names.csv"))

write.csv(d2, paste0(set2, "/set2_old_to_new_names.csv"))


#### load them in for catalogues, later

for(img in seq_along(imgs)){
  
  imglist[[img]] <- image_read(paste0(path,d$fname[img], ".jpg"))
  imglist[[img]] <- image_resize(imglist[[img]], "400x")
  
  print(img)
  gc()
}



imgsxtile <- 13
noimages <- 130

thesequence <- seq.int(1,1690,by = 13) ## 1677 +13
jimglist <- list()
for(img in seq_along(1: noimages)) {
  jimglist <- image_join(imglist[thesequence[img]:(thesequence[img+1]-1)])

  thecatalogue <- image_montage(jimglist, bg = "gray", geometry = "700x", shadow = TRUE, tile = "3x5")
  thegifs <- image_animate(jimglist, delay = 80)
  image_write(image_convert(thecatalogue,format = "jpeg"), paste0(path, "catalogue/",  img, ".jpeg"), quality = 100)
  image_write(thegifs, paste0(path, "catalogue/gifs/",  img, ".gif"), quality = 100)
  print(img)
  gc()
}


extra <- image_join(imglist[1665:1677])

?image_join