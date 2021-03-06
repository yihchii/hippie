
cmd_args = commandArgs();
inputlength <- cmd_args[4];
totallength <- cmd_args[5];

table <- read.table(paste(inputlength,".txt",sep=""),header = FALSE, row.names = 1)
percentage <- table$V2/as.numeric(totallength)*100

annotation_index <- c("RefSeq-promoter", "RefSeq-gene",
"RefSeq-exon", "RefSeq-intron", 
"miRNA", "pseudogene" ,"RNA-repeats", "TE", "TR","intergenic") 

pdf(paste(inputlength,"_ratio.pdf",sep=""))
par(mar=c(9,5,4,2)+0.1)
bar <- percentage

barmid <- barplot(bar,names = as.character(annotation_index),las=3, main = "", cex.names=1.2)
axis(1,at=barmid,labels =FALSE)
mtext(2,text='Percentage of Fragment Total Length (%)',line = 3, cex = 1.5)
dev.off()


