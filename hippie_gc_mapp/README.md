<html>

#HIPPIE-GC-Mapp

* HIPPIE-GC-Mapp is an appending pipeline of [HIPPIE] (https://github.com/yihchii/hippie) for calculating gc content and mappability for the restriction fragments based on parameters like the restrizipn enzyme, size-selection, and read length that are specific to the Hi-C protocol performed.
* HIPPIE-GC-Mapp generates a required input file for HIPPIE for the `correctHiCBias` step.


##PREREQUISITES
* HIPPIE-GC-Mapp now supports [Open Grid Schedular] (http://gridscheduler.sourceforge.net/)
* [STAR] (https://github.com/alexdobin/STAR) (tested in 2.4.0h)
* [Bedtools] (https://github.com/arq5x/bedtools2) (tested in 2.19.1)


##SETUP
* HIPPIE-GC-Mapp requires [STAR] (https://github.com/alexdobin/STAR) and [bedtools] (https://github.com/arq5x/bedtools2) to be installed
* To setup the pipeline, please edit "setup.ini" at `/path/to/hippie_gc_mapp/` and provide the following information:
  * Path to the softwares:
    1. Path to STAR aligner
    2. Path to bedtools
  * Hi-C experiment parameters
    1. Read length (`readLength`)
    2. The size selection for the library (`sizeSelect`)
    3. The restriction enzyme recognition sequence/site (`RESite`), e.g. AAGCTT for HindIII
    4. The name for the restriction enzyme (`RE`), e.g. HindIII
    5. Path to the FASTA files of all chromosomes of the genome (`fastaDir`)
    5. Path to the location of STAR genome index (`REF_FASTA`)

##RUN HIPPIE-GC-Mapp
* After setup "setup.ini" file, execute the pipeline as:
```
cd /path/to/hippie_gc_mapp/
sh ./hippie_gc_mapp.sh
```
* The output file will be at `/path/to/hippie_gc_mapp/` with the name as `*RE*_fragment_GC_MAPP_LEN.bed`, where *RE* will be replaced by the restriction enzyme name (e.g. HindIII).



* Check our [website] (http://wanglab.pcbi.upenn.edu/hippie/) and the [github page] (https://github.com/yihchii/hippie) for instruction of installation and usage of HIPPIE.


If you use HIPPIE for your research, please use the following citation:

> Hwang Y-C, Lin C-F, Valladares O, Malamon J, Kuksa P P, Zheng Q, Gregory B D, and Wang L-S. HIPPIE: A high-throughput identification pipeline for promoter interacting enhancer elements. (2014, under revision)

</html>
