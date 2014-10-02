library(RColorBrewer)

cmd_args = commandArgs();
line <- cmd_args[4];

## Get histone marks table:
histone_marks <- read.table ("histone_enrichment.txt", header = T, row.names=1);


## plot ratio figure
# Set color
col <- brewer.pal(7, "Set1")  # Genome-overall color set to "black"
col <- col[seq(1,8,by=1)]
ratio <- histone_marks[2,]/histone_marks[4,];
rownames(ratio) <- NULL;


filename <- paste(line, "histone_enrichment.jpg",sep = "_")
jpeg(filename, 4096, 1536, quality = 95)
par(cex = 6.1, lwd = 4)
#par(mfrow=c(1,6),cex = 8, lwd = 2, mar = c(20, 25, 10, 3) + 1, mgp = c(2.6, 0.8, 0))
#layout(matrix(c(1,1,1,1,1,2), 1, 6, byrow = TRUE))
barplot(t(t(ratio)), names = colnames(ratio), xlab = "", ylab = "Enrichment", main = paste(line, "Promoter Partner Enrichment in Epigenomics", sep = " "))

#mp <- barplot(t(ratio), beside = TRUE, las = 1, col = col,space=c(0,0.5),ylim = c(0,max(ratio)),
#  ylab = "", cex.names=8, cex.lab = 8, cex.axis=8,axisnames = FALSE ,axes =FALSE)
#axis(2, las=1, at=c(0,0.5,1.0,1.5), cex.axis = 8,lwd.ticks =6,)
abline(h=0,lwd=4)
abline(h=1, lty = 'dashed',lwd=4)
#mtext(side = 1, at = colMeans(mp), line = 10, text = rownames(ratio), cex = 8)
#mtext(side = 2, line = 15, text = "Enrichment", cex = 8)

#plot.new()
#par (mar = c(3,10,10,2))
#legend("center", legend = c("IMR90/HindIII"), fill = col, cex = 8, box.lwd = 4)
dev.off()

