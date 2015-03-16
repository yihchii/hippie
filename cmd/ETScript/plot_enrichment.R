
cmd_args = commandArgs();
line <- cmd_args[4];

## Get histone marks table:
histone_marks <- read.table ("histone_enrichment.txt", header = T, row.names=1);


## plot ratio figure
ratio <- histone_marks[2,]/histone_marks[4,];
rownames(ratio) <- NULL;


filename <- paste(line, "histone_enrichment.jpg",sep = "_")
jpeg(filename, 4096, 1536, quality = 95)
par(cex = 6.1, lwd = 4)
#par(mfrow=c(1,6),cex = 8, lwd = 2, mar = c(20, 25, 10, 3) + 1, mgp = c(2.6, 0.8, 0))
#layout(matrix(c(1,1,1,1,1,2), 1, 6, byrow = TRUE))
barplot(t(t(ratio)), names = colnames(ratio), xlab = "", ylab = "Enrichment", main = paste(line, "Promoter Partner Enrichment in Epigenomics", sep = " "))

abline(h=0,lwd=4)
abline(h=1, lty = 'dashed',lwd=4)

dev.off()

