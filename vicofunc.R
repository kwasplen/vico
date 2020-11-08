
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}
substrChop <- function(x, n){
  substr(x, 1, nchar(x)-2)
}
mydistance <- function(x1, x2, y1, y2){
  sqrt((x1-x2)*(x1-x2) + (y2-y1)*(y2-y1))
}
nitrogencase <- function(objectivetype) {
  if ((objectivetype == "costmin_Nloadredtarget") | (objectivetype == "Nloadredmax_totalcosttarget"))
    nitrogen <- TRUE
  else
    nitrogen <- FALSE
  nitrogen
}
costmincase <- function(objectivetype) {
  if ((objectivetype == "costmin_Nloadredtarget") | (objectivetype == "costmin_Ploadredtarget"))
    costminopttype <- TRUE
  else
    costminopttype <- FALSE
  costminopttype
}
bothcurves <- function(mode) {
  if (mode =="Nearest")
    both <- TRUE
  else
    both <- FALSE
  both
}
forcedcircle <- function(mode) {
  if (mode =="Forced")
    mustbe <- TRUE
  else
    mustbe <- FALSE
  mustbe
}
samepoint <- function(curve1, curve2, x1, x2, y1, y2) {
  if ((curve1 == curve2) & (x1 == x2) & (y1 == y2))
    same <- TRUE
  else
    same <- FALSE
  same
}
geocodeforthat <- function(geoselected) {
  rawcode1 <- gsub(" ", "", geoselected, fixed = TRUE)
  rawcode2 <- gsub(",", "", rawcode1, fixed = TRUE)
  code <- gsub(".", "", rawcode2, fixed = TRUE)
}
# testbucketandpathfront <- function(bucketname, prefixfront) {
    # filesdf <- get_bucket_df(
      # bucket = bucketname,
      # prefix = prefixfront
    # )
# }
filesdataframe <- function(goahead, geocode, objective, bucketname, prefixfront) {
  if (goahead)
    filesdf <- get_bucket_df(
      bucket = bucketname,
      prefix = paste0(
        prefixfront,
        geocode,
        '/',
        objective
      )
    )
  else
    filesdf <- NULL
}
foundfiles <- function(goahead, filesdf) {
  if (goahead) # not sure if VICOBucketOK can error when S3 access fails
  {
    havefiles <- (nrow(filesdf) > 0)
    if (havefiles)
    {
      thesefiles <-filesdf$Key
      thislist <- thesefiles[which(grepl(".csv", thesefiles))]
      howmany <- length(thislist)
      okay <- (howmany > 0)
    }
    else
      okay <- FALSE
  }
  else
    okay <- FALSE
}
ourfilelist <- function(filesfound, filesdf) {
  if (filesfound)
  {
    thesefiles <- filesdf$Key
    thislist <- thesefiles[which(grepl(".csv", thesefiles))]
  }
  else
    thislist <- NULL
}
geoloadguts <-
  function(okay, have, geochoice, objchoice, bucket, prefix, notestr) {
    tryload <- okay & have
    code <- geocodeforthat(geochoice)
    geodf <-
      filesdataframe(tryload, code, objchoice, bucket, prefix)
    found <- foundfiles(tryload, geodf)
    if (found)
    {
      filelist <- ourfilelist(found, geodf)
      dataset <-
        load.otadataset(filelist, bucket, notestr)
    }
    else
      dataset <- NULL
  }
feasiblepart <- function(fulldataset) {
  if (!is.null(fulldataset))
  {
    otafeasible <-
      subset(fulldataset, feasible != "False")
    if(nrow(otafeasible) < 1)
      otafeasible <- NULL
  }
  else
    otafeasible <- NULL
  otafeasible
}
moneypart <- function(cost) {
  paste0(
    "$",
    formatC(round(cost, digits = 2),
            format = "f",
            digits = 2,
            big.mark = ","
    ))
}  
moneyportion <- function(cost) {
  if (!is.null(cost))
    moneystr <- moneypart(cost)
  else
    moneystr <- ""
  moneystr
}  
lbportion <- function(loaddiff) {
  paste0("(\u2248",
         formatC(
           round(loaddiff, digits = -1),
           format = "f",
           digits = 0,
           big.mark = ","
         ),
         " lb)")
}
pointplace <- function(pointoncurve, place1, place2) {
  if (pointoncurve == 1)
    barplace <- place1
  else
    barplace <- place2
  barplace
}
legendother <- function(otaobjval, xval, yval, lb, dollars) {
  if (otaobjval == "costmin_Nloadredtarget")
    objstr = paste0("N load reduction \u2265 ",
                    xval,
                    "% ",
                    lb,
                    ", Cost = ",
                    dollars)
  else
  {
    if (otaobjval == "costmin_Ploadredtarget")
      objstr = paste0("P load reduction \u2265 ",
                      xval,
                      "% ",
                      lb,
                      ", Cost = ",
                      dollars)
    else
    {
      if (otaobjval == "Nloadredmax_totalcosttarget")
        objstr = paste0(
          "Total cost \u2264 ",
          dollars,
          ", N load reduction \u2248",
          round(yval, digits = 2),
          "% ",
          lb
        )
      else
        objstr = paste0(
          "Total cost \u2264 ",
          dollars,
          ", P load reduction \u2248",
          round(yval, digits = 2),
          "% ",
          lb
        )
    }
  }
  objstr
}
load.otadataset <- function(file_list, bucketname, msgcore)
{
  withProgress(message = msgcore, value = 0, { 
    mycount <- 0
    if (exists("otadataset")){ rm(otadataset) }
    howmany <- length(file_list)
    for (file in file_list){
      csvobj <- get_object(file, bucket=bucketname)
      csvcharobj <- rawToChar(csvobj)  
      con <- textConnection(csvcharobj)  
      temp_dataset <- read.csv(file = con, nrows=1,
                               colClasses = c("integer", "numeric",
                                              "character", "character", "character",
                                              "numeric", "numeric",
                                              "character",
                                              "numeric", "numeric", "numeric", "numeric", "numeric", "numeric",
                                              "character",
                                              "numeric", "numeric") # "Date", "integer", "logical")
      )
      nextone <- length(temp_dataset) + 1
      temp_dataset[, nextone] <- file
      names(temp_dataset)[nextone] <- "ourfilename"
      if (!exists("otadataset")){
        otadataset <- temp_dataset
      }
      else
      {
        if (exists("otadataset")){
          otadataset<-rbind(otadataset, temp_dataset)
        }
      }
      if (exists("temp_dataset")){ rm(temp_dataset) }
      mycount <- mycount + 1
      incProgress(1/howmany, detail = paste0("Get plot data part ", mycount, " of ", howmany))
    }
  })
  otadataset[is.na(otadataset$solution_objective), "feasible"] <- "False"
  otadataset[is.infinite(otadataset$solution_objective), "feasible"] <- "False"
  otadataset[is.na(otadataset$solution_objective), "solution_objective"] <- 0
  otadataset[is.infinite(otadataset$solution_objective), "solution_objective"] <- 0
  lowval <- min(otadataset$solution_objective)  
  otadataset[otadataset$feasible=="False", "solution_objective"] <- lowval
  otadataset
}
load.otabardata <- function(ourdataset, otaopttype, xval, bucketname)
{
  if (!is.null(xval))
  {
    if (costmincase(otaopttype))
      zoomin <-
        ourdataset[which(ourdataset$percent_reduction_minimum == xval), ]
    else
      zoomin <-
        ourdataset[which(ourdataset$totalcostupperbound == xval), ]
    usefilename <- zoomin$ourfilename[1]
    csvobj <-
      get_object(usefilename, bucket = bucketname)
    csvcharobj <- rawToChar(csvobj)
    con <- textConnection(csvcharobj)
    otabarraw <- read.csv(file = con,
                          colClasses = c("integer", "numeric", 
                                         "character", "character", "character", 
                                         "numeric", "numeric", 
                                         "character", 
                                         "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", 
                                         "character", 
                                         "numeric", "numeric") # "Date", "integer", "logical")
    )
    justtwo <-
      unique(otabarraw[, c("bmpfullname", "totalannualizedcostperunit")])
    otasums <- rowsum(otabarraw$acres, otabarraw$bmpfullname)
    otabarraw <- data.frame(bmpfullname=rownames(otasums), acres=otasums)
    otabardata <- merge(x = otabarraw,
                        y = justtwo,
                        by = "bmpfullname",
                        all = FALSE)
    otabardata[order(otabardata$acres, decreasing=TRUE),]
  }
  else
    NULL
}
load.otadownloaddata <- function(ourdataset, otaopttype, xval, bucketname)
{
  if (!is.null(xval))
  {
    if (costmincase(otaopttype))
      zoomin <-
        ourdataset[which(ourdataset$percent_reduction_minimum == xval), ]
    else
      zoomin <-
        ourdataset[which(ourdataset$totalcostupperbound == xval), ]
    usefilename <- zoomin$ourfilename[1]
    csvobj <-
      get_object(usefilename, bucket = bucketname)
    csvcharobj <- rawToChar(csvobj)
    con <- textConnection(csvcharobj)
    otabarraw <- read.csv(file = con,
                          colClasses = c("integer", "numeric", 
                                         "character", "character", "character", 
                                         "numeric", "numeric", 
                                         "character", 
                                         "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", 
                                         "character", 
                                         "numeric", "numeric") # "Date", "integer", "logical")
    )
  }
  else
    NULL
}
load.otadownloadtxtdata <- function(ourdataset, otaopttype, xval, bucketname)
{
  if (!is.null(xval))
  {
    if (costmincase(otaopttype))
      zoomin <-
        ourdataset[which(ourdataset$percent_reduction_minimum == xval), ]
    else
      zoomin <-
        ourdataset[which(ourdataset$totalcostupperbound == xval), ]
    usefilename <- zoomin$ourfilename[1]
    newfilename <- gsub("/exp", "/castformat_exp", usefilename, fixed = TRUE)
    txtfilename <- gsub(".csv", ".txt", newfilename, fixed = TRUE)
    csvobj <-
      get_object(txtfilename, bucket = bucketname)
    csvcharobj <- rawToChar(csvobj)
    con <- textConnection(csvcharobj)
    otatext <- readLines(con)
  }
  else
    NULL
}
plotpoint <- function(whichcurve,
                      xval,
                      yval,
                      whichpoint,
                      labelit)
{
  if ((!is.null(whichcurve)))
  {
    if (whichcurve == 1)
      useshape <- 24
    else
      useshape <- 21
    if (whichpoint == 1)
      uselabel <- '1'
    else
      uselabel <- '2'
    points(
      c(xval),
      c(yval),
      type = 'p',
      pch = useshape,
      cex = 1.5,
      col = "red",
      bg = "yellow",
      lwd = 2,
      yaxt = "n"
    )
    if (labelit)
      text(c(xval),
           c(yval),
           labels = uselabel,
           pos = 3)
  }
}
plotdraftdata <- function()
{
  text(x = grconvertX(0.5, from = "npc"),  # align to center of plot X axis
       y = grconvertY(0.5, from = "npc"), # align to center of plot Y axis
       labels = "DRAFT DATA", # our watermark
       cex = 5, font = 2, # large, bold font - hard to miss
       col = rgb(0.17, 0.17, 0.17, .2), # translucent (0.2 = 20%) gray/gray color
       srt = -20) # srt = angle of text: -20 degree angle to X axis
}
plotempty <- function(mainlabel, xaxislabel, yaxislabel, colorchoice, bgcolor, xleft, xright)
{
  plot(NULL,
       NULL,
       xlab = xaxislabel,
       ylab = yaxislabel,
       type = 'b',
       pch = 24, 
       cex=1.5, 
       col=colorchoice, bg=bgcolor,
       lwd=2, yaxt = "n",
       xlim = c(xleft, xright),
       ylim=c(0,10000000)
  )
  grid()
  title(main = mainlabel, line = 1)
  myTicks = axTicks(2)
  axis(2, at = myTicks, labels = paste(formatC(myTicks/1000000, format = 'd'), 'M', sep = ''))      
}
plotemptybar <- function(mainlabel, colorchoice, bgcolor)
{
  bp <- barplot(c(0),
    horiz = "TRUE",
    xlab = 'Acres',
    ylab = 'Efficiency BMP',
    xlim = c(0, 10000),
    axisnames = FALSE,
    col = c(colorchoice),
    space = 0.5,
    cex.names = par("cex.axis")
  )
  grid(nx = NULL, ny = NA)
  title(main = '', line = 1)
}
