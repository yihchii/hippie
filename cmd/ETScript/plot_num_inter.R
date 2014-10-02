library(RColorBrewer)

cmd_args = commandArgs();
input <- cmd_args[4];


reads <- read.table(paste(input,".txt",sep=""));
reads <- reads$V1;

read.break <- c(0,1,2,3,4,5,10,15,20);
support<-NULL;

for (i in read.break)
  support <- c(support,length(reads[reads>i]));

support.percent <- support/support[1]*100;
pdf(paste(input,".pdf",sep=""));
plot(read.break, support.percent, type="o",ylab = "Percentage", xlab = "Number of read support",cex.lab=1.5, cex.axis=1.5)

dev.off();
