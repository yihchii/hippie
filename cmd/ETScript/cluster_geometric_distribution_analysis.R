cmd_args = commandArgs();
inputfile <- cmd_args[4];
outputfile.lower <- cmd_args[5];
outputfile.upper <- cmd_args[6];
chrm.cluster <- read.table(inputfile,header = F, quote="\"",comment.char="")
names(chrm.cluster) <- c("chrm","cLength")
#chr1    100



lower.clusterlength <- sapply(unique(chrm.cluster$chrm), function(ch) qgeom(0.01, 1/mean(chrm.cluster$cLength[chrm.cluster$chrm==ch])))
names(lower.clusterlength) <- unique(chrm.cluster$chrm)
###

upper.clusterlength <- sapply(unique(chrm.cluster$chrm), function(ch) qgeom(0.99, 1/mean(chrm.cluster$cLength[chrm.cluster$chrm==ch])))
names(upper.clusterlength) <- unique(chrm.cluster$chrm)
###
write.table(lower.clusterlength,outputfile.lower, row.names=T, quote = F, col.names=F,sep = "\t")

write.table(upper.clusterlength,outputfile.upper, row.names=T, quote = F, col.names=F,sep = "\t")


