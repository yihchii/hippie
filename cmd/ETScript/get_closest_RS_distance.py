import sys, re, time

rr_size = int(sys.argv[1])
re_file = sys.argv[2]
align_file_in = sys.argv[3]
out_file = sys.argv[4]

def restriction_site_reader(in_file):
	re_start = dict()
	re_end = dict()
	for l in open(re_file):
		v = l.rstrip().split()
		if v[0] not in re_start:
			re_start[v[0]] = list()
			re_end[v[0]] = list()
		re_start[v[0]].append(int(v[1]))
		re_end[v[0]].append(int(v[2]))
	return re_start, re_end


def alignment_reader(in_file, rrSize, re_start, re_end, out_file):
	pair_file = open(in_file)
	fout = open(out_file, 'w')
	for line in pair_file:
		v = line.rstrip().split("\t")
		if (v[0] in re_end and v[4] in re_end):
			d1 = get_distance(int (v[1]), int(v[2]), re_end[v[0]], len(re_end[v[0]])-1, int(rrSize))
			d2 = get_distance(int (v[5]), int(v[6]), re_end[v[4]], len(re_end[v[4]])-1, int(rrSize))
			# when the distance < 0, means the end of the read is overalaping a restriction recognition site
			d1 = d1 if (d1>0) else 0
			d2 = d2 if (d2>0) else 0
			fout.write ("\t".join([str(s) for s in v+[d1,d2]]) + "\n")
	fout.close()
	

def get_distance(left, right, re_array, end, RRsize):
	start = 0
	if (start >= end):
		sys.stderr.write("Error! End index <= start index (0) in the beginning! End index =" + str(end) +"\n")
		exit(1)
		
	while start != (end -1):
		mid = start + (end - start)/2
		if right == re_array[mid]:
			end = mid
			start = end -1
			break
		if right < re_array[mid]:
			end = mid
		else:
			start = mid
	while (left < re_array[start]-int(RRsize) and start >= 0):
		start -= 1
	return left-re_array[start] if ((left-re_array[start])<=(re_array[end]-int(RRsize)-right)) else re_array[end]-4-right
		


sys.stdout.write( "["+time.strftime("%c")+"] Start calculating the distance to resite... "+"\n")
sys.stdout.flush()

sys.stdout.write( "["+time.strftime("%c")+"] Reading restriction site file... "+"\n")
sys.stdout.flush()
start = time.clock()
re_start, re_end = restriction_site_reader(re_file)
sys.stdout.write( "Time reading restriction site file: "+ str(time.clock()-start)+ " s"+"\n")
sys.stdout.flush()

sys.stdout.write( "["+time.strftime("%c")+"] Reading and processing paired_bed files... "+"\n")
sys.stdout.flush()
start = time.clock()
alignment_reader(align_file_in, rr_size, re_start, re_end, out_file)
sys.stdout.write("Time reading and processing alinged sam files: "+ str(time.clock()-start)+ " s"+"\n")
sys.stdout.flush()

sys.stdout.write( "["+time.strftime("%c")+"] Complete analysis successfully "+"\n")
sys.stdout.flush()


