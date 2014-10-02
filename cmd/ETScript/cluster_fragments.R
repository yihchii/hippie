#Usage: R --no-save --args NcoI_GM_1_ehotspot_class < plot_annotation.R

cmd_args = commandArgs();
threshold_txt <- cmd_args[4];
threshold <- as.numeric(threshold_txt)/100;
specific_read <- cmd_args[5];
nonspecific_read <- cmd_args[6];
fragment_prefix <- strsplit(specific_read, "\\.")[[1]][1]

s_data<-read.table(pipe(paste("cut -f1-3,5", specific_read,sep =" ")),comment.char="",sep = "\t",header=FALSE)
names(s_data) <- c("chrm","start","end","reads")

ns_data <- read.table(pipe(paste("cut -f1-3,5", nonspecific_read, sep = " ")),comment.char="",sep = "\t",header=FALSE)
names(ns_data) <- c("chrm","start","end","reads")

s_data$length <- s_data$end - s_data$start

# d1+d2 <=500 region
s_data$normReads <- s_data$reads / 500
s_data$normReads[s_data$length<=500] <- s_data$reads[s_data$length<=500]/s_data$length[s_data$length<=500]

ns_data$length <- ns_data$end - ns_data$start
ns_data$normReads <- ns_data$reads / (ns_data$length-500)
ns_data$normReads[ns_data$length<=500] <- 0


print(length(s_data$normReads))

print (length(ns_data$normReads)) # report number of fragments with specific hi-c reads

read_distribution <- paste(fragment_prefix,"_2way",".jpg",sep="")
jpeg(read_distribution)
plot(log(s_data$normReads), log(ns_data$normReads),xlim = c(-10,6),ylim =c(-10,6))
dev.off()

read_distribution2 <- paste(fragment_prefix,"_1way",".jpg",sep="")
h1 <- hist(log((s_data$normReads+1)/(ns_data$normReads+1)),breaks=10000,plot=FALSE)
plot( h1, col=rgb(0,0,1,1/4),xlab = "",xlim = c(-2,2.5))
jpeg(read_distribution2)
plot(log(s_data$normReads/ns_data$normReads))
dev.off()


