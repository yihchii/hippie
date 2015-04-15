####################################################
#
#
#
#

import sys, re, time
from itertools import izip
import pysam

lalign = sys.argv[1]  # left aligned read
ralign = sys.argv[2]	# right aligned read
lchim = sys.argv[3]	# left chimeric read
rchim = sys.argv[4]	# right chimeric read
chimSegMin = int(sys.argv[5]) # chimeric read mimimum length
sizeSelect = int(sys.argv[6])  # size selection upper bound (Hi-C default: 500bp)
re_file = sys.argv[7]	# restriction site (MboI: 4bp)
out_file = sys.argv[8]	# output file name

def restriction_site_reader(in_file):
	resite_start = dict()
	resite_end = dict()
	for l in open(re_file):
		v = l.rstrip().split()
		if v[0] not in resite_start:
			resite_start[v[0]] = list()
			resite_end[v[0]] = list()
		resite_start[v[0]].append(int(v[1]))
		resite_end[v[0]].append(int(v[2]))
	return resite_start, resite_end

def chimeric_reader(in_file, chimSegMin):
	cont = dict()
	pre_id = ""
	for l in open(in_file):
		if not l.startswith("@"):
			v = l.rstrip().split("\t")
			matchObj = re.match(r'(\d+)([MS])(\d+)([MS])', v[5])
			current_id = v[0]
			std = flag_explain_strand(int(v[1]))

			if matchObj and int(matchObj.group(1)) >=(chimSegMin-2) and int(matchObj.group(3)) >=(chimSegMin-2):
				if pre_id == current_id and v[0] not in cont: # first read did't pass matching
					pre_id = current_id
					continue
				if v[0] not in cont:  # initialized the dictionary of the chimeric read, key=readid
					cont[v[0]] = dict(chrm=list(), loc=list(), lgh=list(), std=list())
				cont[v[0]]['chrm'].append(v[2])
				lgh = 0 #length
				if matchObj.group(2) == 'M':
					lgh = int(matchObj.group(1))
				elif matchObj.group(4) == 'M':
					lgh = int(matchObj.group(3))
				else:
					sys.stderr.write("Error, MS wrong!" + v[5] +"\n")
					exit(1)					
				cont[v[0]]['loc'].append(int(v[3]))
				cont[v[0]]['lgh'].append(lgh)
				cont[v[0]]['std'].append(std)
			else:
				if pre_id == current_id and v[0] in cont: # second read didn't pass matching
					del cont[v[0]]
			pre_id = current_id
	return cont

def chimeric_mapping(bamRead, chrom, c_cont, re_start, re_end, sizeSelect):
#	read_id = v_cont[0]
	read_id = str(bamRead.query_name) # read ID
	chr_index = c_cont[read_id]['chrm'].index(chrom) #chormosome ID
	chr_other_index = 1 - chr_index
	pos_list = sorted([c_cont[read_id]['loc'][chr_index]-1, c_cont[read_id]['loc'][chr_index]-1+c_cont[read_id]['lgh'][chr_index], int(bamRead.pos), int(bamRead.reference_end) ])

# the further part (from the aligned read) of the chimeric read should be paried if the chimeric read spanned on the same chromosome
	if (c_cont[read_id]['chrm'][chr_other_index] == c_cont[read_id]['chrm'][chr_index]):
		pos_other_list = sorted([c_cont[read_id]['loc'][chr_other_index]-1, c_cont[read_id]['loc'][chr_other_index]-1+c_cont[read_id]['lgh'][chr_other_index], int(bamRead.pos), int(bamRead.reference_end) ])
			
		if ((pos_other_list[2] - pos_other_list[1]) < (pos_list[2] - pos_list[1])):
			temp = pos_other_list
			pos_other_list = pos_list
			pos_list = temp
			temp2 = chr_index
			chr_index = chr_other_index
			chr_other_index = temp2

	v_std = flag_explain_strand(int(bamRead.flag))
	c_std = c_cont[read_id]['std'][chr_index]
# the linear distance of the paired read should be closer than the size selection step (Hi-C default = 500bp)

	# the one closer to the read should be read on opposite strand from the alinged read
	check = True
	if (pos_list[2] - pos_list[1] <= sizeSelect) and (v_std != c_std) and (v_std != ".") and (c_std != "."):
		chr = c_cont[read_id]['chrm'][chr_index]
		if chr in re_start:
			check = check_re(pos_list[1], pos_list[2], re_start[chr], re_end[chr], len (re_start[chr])-1)
		else:
			check = False
	else:
		check = False
	
	if check:
		return [c_cont[read_id]['chrm'][chr_other_index], c_cont[read_id]['loc'][chr_other_index]-1, c_cont[read_id]['loc'][chr_other_index]-1+c_cont[read_id]['lgh'][chr_other_index], c_cont[read_id]['std'][chr_other_index]]
	else:
		return []

def check_re (left, right, re_left, re_right, end):
	start = 0
	if start >= end:
		sys.stderr.write("Error! End index <= start index (0) in the beginning! End index =" + str(end) +"\n")
		exit(1)
	while start != end-1:
		mid = start + (end - start)/2
		if right == re_right[mid]:
			end = mid
			start = end-1
			break
		if right > re_right[mid]:
			start = mid
		elif right < re_right[mid]:
			end = mid

	if left >= re_left[start]: 
		return True
	else:
		return False


def flag_explain_strand(flag):
	# check the strandness of the read by the FLAGS reported by STAR
	# 0:  forward strand
	# 16: reverse strand
	# 256: forward strand as not primary read (shorter part of the chimeric read)
	# 272: reverse strand as not primary read (shorter part of the chimeric read) 
	if flag == 0 or flag == 256:
		return "+"
	if flag == 16 or flag == 272:
		return "-"
	else:
		return "."  ## shouldn't happen for the star mapped bam file


def alignment_reader(in_file1, in_file2, lc, rc, sizeSelect, re_start, re_end, out_file):
	#with open(in_file1) as f1, open(in_file2) as f2:
	f1 = pysam.AlignmentFile(in_file1, "rb")
	f2 = pysam.AlignmentFile(in_file2, "rb")
	fout = open(out_file, 'w')
	std1=""
	std2=""
	for l1, l2 in izip(f1, f2):
		#if not l1.startswith("@") and not l2.startswith("@"):
		if l1.query_name != l2.query_name:
			sys.stderr.write("Error, two reads have different ids!" + str(l1.query_name) + "\t" + str(l2.query_name) +"\n")
			exit(1)
			
		std1 = flag_explain_strand(int(l1.flag))
		std2 = flag_explain_strand(int(l2.flag))

		if(l1.tid>=0):
			chromL = str(f1.getrname(l1.tid))
		else:
			chromL = "chr"+str(0)

		if(l2.tid>=0):
			chromR = str(f2.getrname(l2.tid))
		else:
			chromR = "chr"+str(0)

		# if the right(2nd) aligned read could be paired to the left(1st) chimeric read
		if str(l2.query_name) in lc and chromR in lc[str(l2.query_name)]['chrm']:
			co = chimeric_mapping(l2, chromR, lc, re_start, re_end, sizeSelect)
			if co: # if chim. read is good (one part close enough (eg. <500 nt) and on the same RE fragment to alingned read)
				fout.write("\t".join([str(s) for s in [co[0], co[1], co[2], co[3], chromR, l2.pos, l2.reference_end, std2, l2.query_name, "c"]])+"\n")
				continue
		elif str(l1.query_name) in rc and chromL in rc[str(l1.query_name)]['chrm']:

			co = chimeric_mapping(l1, chromL, rc, re_start, re_end, sizeSelect)
			if co:
				fout.write("\t".join([str(s) for s in [chromL, l1.pos, l1.reference_end, std1, co[0], co[1], co[2], co[3], l1.query_name, "c"]])+"\n")
				continue
			# if no chimeric reads involved, check the mapping quality and the uniqness
		if int(l1.mapping_quality) == 255 and int(l2.mapping_quality) == 255 and int(l1.tags[0][1]) == 1 and int(l2.tags[0][1]) == 1:
			fout.write("\t".join([str(s) for s in [chromL, l1.pos, l1.reference_end, std1, chromR, l2.pos, l2.reference_end, std2, l1.query_name,"."]]) + "\n")
	fout.close()
	
sys.stdout.write("["+time.strftime("%c")+"] Start sam file pairing... " +"\n")
sys.stdout.flush()

sys.stdout.write("["+time.strftime("%c")+"] Reading left (1st) chimeric sam file... " + "\n")
sys.stdout.flush()
start = time.clock()
lchim_cont = chimeric_reader(lchim,chimSegMin)
sys.stdout.write("Time reading left chimeric sam file: "+ str(time.clock()-start)+ " s"+"\n")
sys.stdout.flush()

sys.stdout.write("["+time.strftime("%c")+"] Reading right (2nd) chimeric sam file... " +"\n")
sys.stdout.flush()
start = time.clock()
rchim_cont = chimeric_reader(rchim, chimSegMin)
sys.stdout.write("Time reading rignt chimeric sam file: "+ str(time.clock()-start)+ " s"+"\n")
sys.stdout.flush()

sys.stdout.write("["+time.strftime("%c")+"] Reading restriction site file... "+"\n")
sys.stdout.flush()
start = time.clock()
re_start, re_end = restriction_site_reader(re_file)
sys.stdout.write("Time reading restriction site file: "+ str(time.clock()-start)+ " s"+"\n")
sys.stdout.flush()

sys.stdout.write("["+time.strftime("%c")+"] Reading and processing aligned sam files... "+"\n")
sys.stdout.flush()
start = time.clock()
alignment_reader(lalign, ralign, lchim_cont, rchim_cont, sizeSelect, re_start, re_end, out_file)
sys.stdout.write("Time reading and processing alinged sam files: "+ str(time.clock()-start)+ " s"+"\n")
sys.stdout.flush()
sys.stdout.write( "["+time.strftime("%c")+"] Complete analysis (parse_starSam_to_paired) successfully "+"\n")
sys.stdout.flush()

