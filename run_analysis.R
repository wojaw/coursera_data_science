project_data = list(
  url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip ",
  zipfile = 'project_data.zip', dirname = "UCI HAR Dataset", setnames = c('test','train'),
  measurements = c('mean','std'), colnums = list())

### If 'UCI HAR Dataset' is not in your working directory, uncomment and execute the two lines below:
# download.file(project_data$url, destfile=project_data$zipfile, method='curl')
# unzip(project_data$zipfile)

features = read.table(paste(".",project_data$dirname,'features.txt', sep="/"),
                      colClasses=c('numeric','character'))
activities = read.table(paste(".",project_data$dirname,'activity_labels.txt', sep="/"),
                             colClasses=c('numeric','character'))
colnames(features) = colnames(activities) = c('id','name')

for (measurement in project_data$measurements) {
  features[[measurement]] =  grepl(paste0('-',measurement,'\\(\\)'), features$name)
  project_data$colnums[[measurement]] = which(features[[measurement]])
}
rm(measurement)
project_data$colnums$all = sort(as.vector(unlist(project_data$colnums)))

data_sets = list()
for (setname in project_data$setnames) {
  data_sets[[setname]] = read.table(paste('.',project_data$dirname,setname,
                          paste0('X_',setname,'.txt'),sep='/'))
  colnames(data_sets[[setname]]) = features$name
  data_sets[[setname]] = data_sets[[setname]][,project_data$colnums$all]
  data_sets[[setname]]$subject = read.table(paste('.',project_data$dirname,setname,
                          paste0('subject_',setname,'.txt'),sep='/'))[,1]
  data_sets[[setname]]$activity = activities$name[read.table(paste('.',project_data$dirname,setname,
                                    paste0('y_',setname,'.txt'),sep='/'))[,1]]
  data_sets[[setname]]$setname = setname
}
rm(setname)
merged_data_set = rbind(data_sets$train, data_sets$test)
colnames(merged_data_set) = gsub("-", "_", gsub("\\(\\)", "", colnames(merged_data_set)))

### In order to get rid of the 'data_sets' data frame from your workspace, uncomment and execute the line below:
# rm(data_sets)

tidy_data_set = aggregate.data.frame(FUN=mean, na.rm=T,
  x=merged_data_set[,grep('_', colnames(merged_data_set))],
  by=merged_data_set[,c('subject','activity')])

### In order to reproduce the uploaded txt file 'tidy_data_set.txt', uncomment and execute the line below:
# write.table(tidy_data_set, 'tidy_data_set.txt', row.name=F, quote=F)
