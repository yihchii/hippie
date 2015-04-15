cmd_args = commandArgs();

cell <- cmd_args[4];
thre <- cmd_args[5];
distance_closest_file <- cmd_args[6];
# "hESC_95_CEE_strong_closestGene_dist.txt"
distance_HiC_file <- cmd_args[7]; 
# "hESC_95_CEE_gene_strong_dist.txt"
output_dir <- cmd_args[8]; 

distance_closest <- read.table(distance_closest_file,header=FALSE)
distance_HiC <- read.table(distance_HiC_file,header=FALSE)

distance_closest <- as.numeric(distance_closest$V1)
distance_closest <- (distance_closest+1)/1000; # adjust for log transform

distance_HiC <- as.numeric(distance_HiC$V1)
distance_HiC <- (distance_HiC +1)/1000; # adjust for log transform

df <- data.frame(values = c(distance_closest, distance_HiC), vars=rep(c("col1","col2"),times=c(length(distance_closest),length(distance_HiC))))

filename <- paste(output_dir,"/",cell,"_",thre,"_ET_distance.jpg",sep="")
#filename <- "hESC_ET_distance_human.jpg";
jpeg(filename, 1536, 1536, quality = 95);
par(cex=2,cex.lab = 2,cex.main=3, cex.axis=2,cex.sub=2, lwd = 4, mar=c(5,9,2,2)+0.1)


boxplot(values ~ vars, data = df, main="",  xlab="", ylab="", log="y", names=c("Closest gene","Hi-C target gene"),las=1,cex.lab=5,yaxt="n")

#boxplot(c(distance_closest, distance_HiC), main="",  xlab="", ylab="", log="y", names=c("Closest gene","Hi-C target gene"),las=1)
mtext("Median distance (Kbp)", side=2, line=6.7,cex=5)
axis(2, at=c(1e-3,1e-1,1e+1,1e+3,1e+5), labels=c("0.001","0.1","10","1000","100000"),las=1,cex.axis=2)

dev.off()
wilcox.test(distance_closest,distance_HiC)


