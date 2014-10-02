setwd("./")

# read in the file
# R --no-save --args gap_test < test.R
cmd_args = commandArgs();
inputfile <- cmd_args[4];
outputfile.lower <- cmd_args[5];
outputfile.upper <- cmd_args[6];
gap.table <- read.table(inputfile,header = T,sep = "\t",comment.char="")

# geometric distribution p < 0.05

lower.gaplength <- sapply(unique(gap.table$chrm), function(ch) qgeom(0.05, 1/mean(gap.table$gapLength[gap.table$chrm==ch])))
names(lower.gaplength) <- unique(gap.table$chrm)

upper.gaplength <- sapply(unique(gap.table$chrm), function(ch) qgeom(0.95, 1/mean(gap.table$gapLength[gap.table$chrm==ch])))
names(upper.gaplength) <- unique(gap.table$chrm)


write.table(lower.gaplength,outputfile.lower, sep = "\t", row.names=T, quote = F, col.names=F)

write.table(upper.gaplength,outputfile.upper, sep = "\t", row.names=T, quote = F, col.names=F)

