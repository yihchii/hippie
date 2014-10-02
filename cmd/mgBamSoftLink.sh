#!/bin/bash

source $HIPPIE_INI

rm -f $2

ln -s $1 $2

# Check BAM EOF
BAM_28=$(tail -c 28 ${2}|xxd -p)
if [ "$MAGIC28" != "$BAM_28" ]
then
  echo "Error with BAM EOF" 1>&2
  exit 100
fi

$SAMTOOLS index $2

if [ !  -s "${2}.bai" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS
