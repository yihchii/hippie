cmd_args = commandArgs();
line <- cmd_args[4];
filename <- cmd_args[5];
out_dir <- cmd_args[6];

## Get histone marks table:
filename <- paste(out_dir,"/",filename,sep="")
histone_marks <- read.table (filename, header = T, row.names=1);

## plot ratio figure
ratio <- histone_marks[2,]/histone_marks[4,];
rownames(ratio) <- NULL;

filename <- paste(out_dir,"/", line, "_histone_enrichment.jpg",sep = "")
jpeg(filename, 4096, 1536, quality = 95)
par(cex = 6.1, lwd = 4)
barplot(t(t(ratio)), names = colnames(ratio), xlab = "", ylab = "Enrichment", main = paste(line, "Promoter Partner Enrichment in Epigenomics", sep = " "))

abline(h=0,lwd=4)
abline(h=1, lty = 'dashed',lwd=4)

dev.off()

