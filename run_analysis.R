linkdata<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
comp<-getwd()
download.file(linkdata,destfile =file.path(comp,"zipfile.zip"))
unzip(zipfile = "zipfile.zip")

activities<-read.table(file.path(comp, "UCI HAR Dataset/activity_labels.txt"),col.names = c("classlabel","namelabel"))
feature<-read.table(file.path(comp,"UCI HAR Dataset/features.txt"),col.names = c("index","fearturename"))
checkfeature<-grep("(mean|std)\\(\\)",feature$fearturename)
measurement<-rep(66,0)
for (i in 1:66){
  measurement[i]<-feature$fearturename[checkfeature[i]]  
}
measurement<-gsub("[()]","",measurement)

#train data set
traindt<-read.table(file.path(comp,"UCI HAR Dataset/train/X_train.txt"))[,checkfeature]
colnames(traindt)<-measurement
trainacti<-read.table(file.path(comp,"UCI HAR Dataset/train/y_train.txt"))
colnames(trainacti)<-"Activity"
trainSub<-read.table(file.path(comp,"UCI HAR Dataset/train/subject_train.txt"))
colnames(trainSub)<-"SubjectName"
traindt<-cbind(trainSub,trainacti,traindt)

#test data set
testdt<-read.table(file.path(comp,"UCI HAR Dataset/test/X_test.txt"))[,checkfeature]
colnames(testdt)<-measurement
testacti<-read.table(file.path(comp,"UCI HAR Dataset/test/y_test.txt"))
colnames(testacti)<-"Activity"
testSub<-read.table(file.path(comp,"UCI HAR Dataset/test/subject_test.txt"))
colnames(testSub)<-"SubjectName"
testdt<-cbind(testSub,testacti,testdt)

#merge data
datatotal<-rbind(traindt,testdt)

#Set activity name
nameacti<-datatotal$Activity
num<-c("1","2","3","4","5","6")
name<-c("WALKING","WALKING_UPSTAIRS","WALKING_DOWNSTAIRS","SITTING","STANDING","LAYING")
for (i in 1:6){
  nameacti<-gsub(num[i],name[i],nameacti)
}
datatotal$Activity<-nameacti

library(reshape2)
datatotal<-melt(data = datatotal, id = c("SubjectName", "Activity"))
datatotal<-dcast(data = datatotal, SubjectName + Activity ~ variable, fun.aggregate = mean)

#creat txt file
write.table(datatotal,file= "tidyData.txt",row.names = F)