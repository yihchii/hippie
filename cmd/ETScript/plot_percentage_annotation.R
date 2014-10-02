#Usage: R --no-save --args NcoI_GM_1_ehotspot_class < plot_annotation.R

cmd_args = commandArgs();
inputclass <- cmd_args[4];

table <- read.table(paste(inputclass,".txt",sep=""),header = FALSE, row.names = 1)
percentage <- table$V3*100

annotation_index <- c("RefSeq-promoter", "RefSeq-gene",
"RefSeq-exon", "RefSeq-intron", 
"miRNA", "pseudogene" ,"RNA-repeats", "TE", "TR","intergenic") 

pdf(paste(inputclass,".pdf",sep=""))
par(mar=c(9,5,4,2)+0.1)
#dfnumber <- data.frame(number)
bar <- percentage[-12]

barmid <- barplot(bar,names = as.character(annotation_index[-12]),las=3, main = "", cex.names=1.2)
axis(1,at=barmid,labels =FALSE)
#mtext(1,text='Annotation',line=7)
mtext(2,text='Percentage of feature total length (%)',line = 3, cex = 1.5)
dev.off()


