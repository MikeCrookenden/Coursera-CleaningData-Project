library(dplyr)
library(tidyr)
library(reshape2) ## for dcast

##Note: I read the original files into MS Excel then saved them as csv/text files

##Read the training data
xtrain<-tbl_df(read.table("X_train.txt",header=FALSE))

##Accompanying Subject/Activity columns
trainactivities<-read.table("y_train.txt",header=FALSE)
names(trainactivities)<-"ActivityCd"
trainsubjects<-read.table("subject_train.txt",header=FALSE) 
names(trainsubjects)<-"Subject"

##Name the observed measurement variables
varlabels<-as.vector(read.table("features.txt",header=FALSE,stringsAsFactors = FALSE))
## can we use lapply? or transform varlabels to a vector of length 561
    for (iVar in 1:561)
    {
        names(xtrain)[iVar]<-varlabels[iVar,2]
    }
xtrain<-cbind(trainsubjects,trainactivities,xtrain)
rm(trainactivities)
rm(trainsubjects)

##Now the same for the test data
xtest<-tbl_df(read.table("X_test.txt",header=FALSE))

testactivities<-read.table("y_test.txt",header=FALSE)
names(testactivities)<-"ActivityCd"
testsubjects<-read.table("subject_test.txt",header=FALSE) 
names(testsubjects)<-"Subject"

##Same set of measurements as for the training data
for (iVar in 1:561)
{
    names(xtest)[iVar]<-varlabels[iVar,2]
}

xtest<-cbind(testsubjects,testactivities,xtest)
rm(testactivities)
rm(testsubjects)

##Merge the training and the test sets to create one data set: This is the result for Step 1
combined<-rbind(xtrain,xtest) 
rm(xtrain)
rm(xtest)

##Extract only the measurements on the mean and standard deviation for each measurement (Step 2)
desired<-tbl_df(combined[,grep("Subject|ActivityCd|-mean()|-std()",names(combined))])

##Clean up the variable names (Step 4)
##names(desired)<-sapply(names(desired),function(x){sub("^[0-9]{1,} ","",x)})  ##remove unnecessary numbersa at start of variable names
names(desired)<-sapply(names(desired),function(x){gsub("-",".",x)})
names(desired)<-sapply(names(desired),function(x){gsub("[(]","",x)})
names(desired)<-sapply(names(desired),function(x){gsub("[)]","",x)})

##Use the descriptive activity names to name the activities in the data set (Step 3)
activitynames<-read.table("activity_labels.txt",header=FALSE) ##natural names for the Activities
desired<-mutate(desired,Activity=activitynames[ActivityCd,2]) ##Lookup Activity name from code in original files

##Step 5: Create a tidy data set with the average of each variable for each activity and each subject
desired<-mutate(desired,sa=paste(Subject,Activity)) ##introduce a single key value for Subject-Activity
desired<-group_by(desired,sa) ## not required, since we will not use summarize (but this may order the rows)

##Get the averages (grouped by Subject-Activity)
dmelt<-melt(desired,id="sa",(c(names(desired)[3:81])))
results<-tbl_df(dcast(dmelt,sa~variable,mean))
rm(desired)

##re-create the separate Subject and Activity fields
results<-mutate(results,Subject=parse_number(sa))
results<-mutate(results,Activity=sub("^[0-9]{1,} ","",sa))
##re-arrange the columns to put Subject and Activity at the front (mutate always seems to put new cols at the end)
rearrange<-cbind(results[,81],results[,82],results[,2:80])

##finally, sort by Subject and Activity (seems to be already sorted that way, but just to be sure)
##this is our final tidy data set!
rearrange<-arrange(rearrange,Subject,Activity) 
rm(results)

##Write output to text file
write.table(rearrange,file="Week4Project_SummaryAnalysisData.txt",row.names=FALSE)  

