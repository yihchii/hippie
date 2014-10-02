#Usage: R --no-save --args NcoI_GM_1_ehotspot_class < plot_annotation.R

cmd_args = commandArgs();
threshold_txt <- cmd_args[4];
threshold <- as.numeric(threshold_txt)/100;
specific_read <- cmd_args[5];
nonspecific_read <- cmd_args[6];
fragment_prefix <- strsplit(specific_read, "\\.")[[1]][1]

peak_fragment <- paste(fragment_prefix,"_",threshold_txt,"_simple.bed",sep = "");

# specific_read <- ${LINE}_${RE}_fragment_S_reads.bed
#s_data<-read.table(specific_read,comment.char="",sep = "\t",header=FALSE)
#names(s_data) <- c("chrm","start","end","readID","reads")
s_data<-read.table(pipe(paste("cut -f1-3,5", specific_read,sep =" ")),comment.char="",sep = "\t",header=FALSE)
names(s_data) <- c("chrm","start","end","reads")

ns_data <- read.table(pipe(paste("cut -f1-3,5", nonspecific_read, sep = " ")),comment.char="",sep = "\t",header=FALSE)
names(ns_data) <- c("chrm","start","end","reads")

s_data$length <- s_data$end - s_data$start

# d1+d2 <=500 region
s_data$normReads <- s_data$reads / 500
#s_data2 <- s_data[c(s_data$length>500),]

s_data$normReads[s_data$length<=500] <- s_data$reads[s_data$length<=500]/s_data$length[s_data$length<=500]




ns_data$length <- ns_data$end - ns_data$start

ns_data$normReads <- ns_data$reads / (ns_data$length-500)
ns_data2 <- ns_data[c(ns_data$length>500),]

#bg <- sort(ns_data2$normReads)

windows <- seq (1,1000)/1000
perc <- quantile(ns_data2$normReads, windows) 
len <- 1000

print (length(s_data$normReads)) # report number of fragments with specific hi-c reads

#b <-sapply (a, function(x) 1-rank(c(x,perc))[1]/len)

s_data$pvalue <- sapply ( s_data$normReads, function (x) 1-rank(c(x,perc))[1]/len)
s_data$pvalue[which(s_data$pvalue <=0)] <- 0;



#for (i in 1:length(s_data$normReads) ) {
#	s_data$pvalue[i] <- 1-rank(c(s_data$normReads[i],perc))[1]/len
#}


s_data2 <- s_data



s_data3 <- s_data2[c(s_data2$normReads>quantile(ns_data2$normReads,threshold)),]

output <- NULL

write.table(s_data3, file=peak_fragment, quote = FALSE, sep = "\t", row.names=FALSE,col.names = FALSE)


read_distribution <- paste(fragment_prefix,"pdf",sep=".")
pdf (read_distribution)
p1 <- hist(ns_data2$normReads,breaks=c(seq(0,250)/100,max(ns_data2$normReads)),xlim=c(0,2.5),probability=TRUE,plot=FALSE)
p2 <- hist(s_data2$normReads,breaks=c(seq(0,250)/100,max(s_data2$normReads)),xlim=c(0,2.5),probability=TRUE,plot=FALSE)
plot( p1, col=rgb(0,0,1,1/4),xlim=c(0,2.5),xlab = "No. reads per nt. per fragment") 
plot( p2, col=rgb(1,0,0,1/4),xlim=c(0,2.5), add=T)
abline(v=quantile(ns_data2$normReads,.95),lty=2)
abline(v=quantile(ns_data2$normReads,.99),lty=3)

legend('topright',c('specific reads','nonspecific reads'), fill = rgb(1:0,0,0:1,0.4), bty = 'n', border = NA)

dev.off()


