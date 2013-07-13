mart.home <- "C:\\Users\\Killua\\Downloads\\R_MART"                                               
source("C:\\Users\\Killua\\Downloads\\R_MART\\mart.s") 
data=read.table('C:\\Users\\Killua\\Dropbox\\CS229 Project\\dataset\\AllFeature_Short_Long_Term.csv',sep=',')
cols <- c(7,71,20,10)
x = as.matrix(data[1:3001,cols])
y = data[1:3001,1]
mart(x,y,martmode='class')
moremart()
test_x = as.matrix(data[3001:3174,cols]);
pred_y<-martpred(test_x)
real_y=data[3001:3174,1]

sum(abs(pred_y-real_y))/348