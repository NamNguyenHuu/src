#!/bin/bash

## Syntax: $0 {path}/arm-trusted-firmware build_cfg_number [ rootfs ]
#  Support until arm-trusted-firmware v2.5
##----------------------------------------------------------------##

export PROJECT_BINARY_DIR=$PROJECT_BINARY_DIR
echo "Project binary dir : $PROJECT_BINARY_DIR"
## ------------------ Check arguments   -------------------##
if [[ $# -ne 1 ]]; then
    echo "Syntax to use the script is:"
    echo "Usage: $0 <test_number>"
    exit -1
fi

TESTNO=$1

#defines an array called "check_range" that contains several elements. 
#Each element of the array is a string that defines an array called image_info with four elements. 
#The four elements of the image_info array are:

## [Type 1] Change destination address of BL33
#1.Test number
#2.Destination address for BL33 (LOW)
#3.Destination address for BL33 (HIGH)
#4.Destination size for BL33
#5.Type

## [Type 2] Change source address of BL33
#1.Test number
#2. Source address of BL33
#3. Image size
#4. NA
#5.Type

## [Type 3] Change BL31 image info
#1.Test number
#2. Source address of BL31
#3. Image size
#4. NA
#5.Type

## [Type 4] Change BL32 image info
#1.Test number
#2. Source address of BL32
#3. Image size
#4. NA
#5.Type

## [Type 5] Change BL332 image info
#1.Test number
#2. Source address of BL332
#3. Image size
#4. NA
#5.Type

## [Type 6] Change BL338 image info
#1.Test number
#2. Source address of BL338
#3. Image size
#4. NA
#5.Type


check_range=(
	'image_info=("TC1" "00000000" "00000000"	"00010000" "1")'
	'image_info=("TC2" "3FFFFF00" "00000000"	"00040000" "1")'
	'' #testno.3
	'image_info=("TC4" "43E00000" "00000000"	"00040000" "1")'
	'image_info=("TC5" "43E00001" "00000000"	"00040000" "1")'
	'image_info=("TC6" "43F00000" "00000000"	"00000040" "1")'
	'image_info=("TC7" "43EF0000" "00000000"	"00FC8000" "1")'
	'image_info=("TC8" "47DFFF00" "00000000"	"00040000" "1")'
	'' #testno.9
	'' #testno.10
	'image_info=("TC11" "BFF00001" "00000000"	"00040000" "1")'
	'image_info=("TC12" "C0000000" "00000000"	"00000001" "1")'
	'image_info=("TC13" "40000000" "00000000"	"20000000" "1")'
	'image_info=("TC14" "7FF00000" "00000004"	"00040000" "1")'
	'image_info=("TC15" "F0000000" "00000003"	"00040000" "1")'
	'image_info=("TC16" "FFFFF000" "00000003"	"00040000" "1")'
	'' #testno.17
	'' #testno.18
	'image_info=("TC19" "03E00001" "00000004"	"00040000" "1")'
	'image_info=("TC20" "03F00000" "00000004"	"00000001" "1")'
	'image_info=("TC21" "03EF0000" "00000004"	"00FC8000" "1")'
	'image_info=("TC22" "07DFFF00" "00000004"	"00040000" "1")'
	'' #testno.23
	'image_info=("TC24" "FFF00000" "00000007"	"00040000" "1")'
	'image_info=("TC25" "FFF00001" "00000007"	"00040000" "1")'
	'image_info=("TC26" "00000000" "00000008"	"00000001" "1")'
	'image_info=("TC27" "00000000" "00000004"	"20000000" "1")'
  # [Type 2]
	'image_info=("TC28" "00640000" "00040000"	"00000000" "2")' # [Type 2]
	'' #testno.29
	'image_info=("TC30" "03F00001" "00040000"	"00000000" "2")' # [Type 2]
	'image_info=("TC31" "00000000" "01000000"	"00000000" "2")' # [Type 2]
	'' #testno.32
	'image_info=("TC33" "50000001" "00000000"	"00010000" "1")' # [Type 1]
	'image_info=("TC34" "00640001" "00010000"	"00000000" "2")' # [Type 2]
	'image_info=("TC35" "03FC2000" "0000F800"	"00000000" "3")' # [Type 3]
	'image_info=("TC36" "03FC2001" "0000F800"	"00000000" "3")' # [Type 3]
	'image_info=("TC37" "03F00000" "00040000"	"00000000" "4")' # [Type 4]
	'image_info=("TC38" "03F00001" "00040000"	"00000000" "4")' # [Type 4]
	'image_info=("TC39" "03F00000" "00040000"	"00000000" "5")' # [Type 5]
	'image_info=("TC40" "03F00001" "00040000"	"00000000" "5")' # [Type 5]
	'image_info=("TC41" "03F00000" "00040000"	"00000000" "6")' # [Type 6]
	'image_info=("TC42" "03F00001" "00040000"	"00000000" "6")' # [Type 6]
	'image_info=("TC43" "001C0000" "00000000"	"00000000" "3")' # [Type 3]
	'image_info=("TC44" "00200000" "00000000"	"00000000" "4")' # [Type 4]
	'image_info=("TC45" "50000000" "00000000"	"00000000" "1")'
);


## ------------------ Pre-built setting -------------------##
set +x

export ATFDIR=${PROJECT_BINARY_DIR}/arm-trusted-firmware
export CERT_HEADER=tools/renesas/rcar_layout_create/sa6.c



# ANSI escape sequence for red color
RED='\033[0;31m' 
# ANSI escape sequence to reset color
RESET_COLOR='\033[0m'

function update_cert(){

  type=$4

  echo $type

  # Go to arm-trusted-firmware source code
  cd ${ATFDIR}

  # Clean change files
  git restore .


  # Using switch case to choose type
  case $type in
     "1")
          echo "[Type 1]"
          echo "Change load destination address BL33"
          dest_addr_low=$1
          dest_addr_high=$2
          image_size=$3

          # Change load destination address
          # define RCAR_BL33DST_ADDRESS		(0x50000000U)
          # define RCAR_BL33DST_ADDRESSH		(0x00000000U)
          
          sed -i -e "s/#define RCAR_BL33DST_ADDRESS\s*(.*)/#define RCAR_BL33DST_ADDRESS\t\t(0x${dest_addr_low}U)/" $CERT_HEADER
          sed -i -e "s/#define RCAR_BL33DST_ADDRESSH\s*(.*)/#define RCAR_BL33DST_ADDRESSH\t\t(0x${dest_addr_high}U)/" $CERT_HEADER
          
          # Change Image size
          # define RCAR_BL33DST_SIZE		(0x00040000U)
          sed -i -e "s/#define RCAR_BL33DST_SIZE\s*(.*)/#define RCAR_BL33DST_SIZE\t\t(0x${image_size}U)/"  $CERT_HEADER
          ;;
      "2")
          echo "[Type 2]"
          echo "Change load source address BL33"
          src_addr=$1
          image_size=$2

          #define RCAR_BL33SRC_ADDRESS		(0x00640000U)
          sed -i -e "s/#define RCAR_BL33SRC_ADDRESS		(0x00640000U)/#define RCAR_BL33SRC_ADDRESS\t\t(0x${src_addr}U)/" $CERT_HEADER

          # Change Image size
          # define RCAR_BL33DST_SIZE		(0x00040000U)
          sed -i -e "s/#define RCAR_BL33DST_SIZE\s*(.*)/#define RCAR_BL33DST_SIZE\t\t(0x${image_size}U)/"  $CERT_HEADER
          ;;
      "3")
          echo "[Type 3]"
          echo "Change load source address BL31"
          src_addr=$1
          image_size=$2

          #define RCAR_BL31SRC_ADDRESS		(0x001C0000U)

          sed -i -e "s/#define RCAR_BL31SRC_ADDRESS		(0x001C0000U)/#define RCAR_BL31SRC_ADDRESS\t\t(0x${src_addr}U)/" $CERT_HEADER


          # Change Image size
          #define RCAR_BL31DST_SIZE		(0x0000F800U)
          sed -i -e "s/#define RCAR_BL31DST_SIZE		(0x0000F800U)/#define RCAR_BL31DST_SIZE\t\t(0x${image_size}U)/"  $CERT_HEADER
          ;;
      "4")
          echo "[Type 4]"
          echo "Change load source address BL32"
          src_addr=$1
          image_size=$2

          #define RCAR_BL32SRC_ADDRESS		(0x00200000U)
          sed -i -e "s/#define RCAR_BL32SRC_ADDRESS		(0x00200000U)/#define RCAR_BL32SRC_ADDRESS\t\t(0x${src_addr}U)/" $CERT_HEADER


          # Change Image size
          #define RCAR_BL32DST_SIZE		(0x00080000U)
          sed -i -e "s/#define RCAR_BL32DST_SIZE		(0x00080000U)/#define RCAR_BL32DST_SIZE\t\t(0x${image_size}U)/"  $CERT_HEADER
          ;;
      "5")
          echo "[Type 5]"
          echo "Change load source address BL332"
          src_addr=$1
          image_size=$2

          # Change Number of content cert for Non-secure Target Program(BL33x)
          #define RCAR_IMAGE_NUM			(0x00000001U)
          sed -i -e "s/#define RCAR_IMAGE_NUM			(0x00000001U)/#define RCAR_IMAGE_NUM\t\t\t(0x00000002U)/" $CERT_HEADER

          # Change destination address
          #define RCAR_BL332DST_ADDRESS		(0x00000000U)
          sed -i -e "s/#define RCAR_BL332DST_ADDRESS		(0x00000000U)/#define RCAR_BL332DST_ADDRESS\t\t(0x50000000U)/" $CERT_HEADER

          #define RCAR_BL332SRC_ADDRESS		(0x00000000U)
          sed -i -e "s/#define RCAR_BL332SRC_ADDRESS		(0x00000000U)/#define RCAR_BL332SRC_ADDRESS\t\t(0x${src_addr}U)/" $CERT_HEADER


          # Change Image size
          #define RCAR_BL332DST_SIZE		(0x00000000U)
          sed -i -e "s/#define RCAR_BL332DST_SIZE		(0x00000000U)/#define RCAR_BL332DST_SIZE\t\t(0x${image_size}U)/"  $CERT_HEADER

          ;;
      "6")
          echo "[Type 6]"
          echo "Change load source address BL338"
          src_addr=$1
          image_size=$2

          # Change Number of content cert for Non-secure Target Program(BL33x)
          #define RCAR_IMAGE_NUM			(0x00000001U)
          sed -i -e "s/#define RCAR_IMAGE_NUM			(0x00000001U)/#define RCAR_IMAGE_NUM\t\t\t(0x00000008U)/" $CERT_HEADER

          # Change #define CHECK_IMAGE_AREA_CNT (5U)->9U in drivers/renesas/common/io/io_rcar.c
          sed -i -e "s/#define CHECK_IMAGE_AREA_CNT (5U)/#define CHECK_IMAGE_AREA_CNT (9U)/" drivers/renesas/common/io/io_rcar.c

          # Change Destination Address | Soure address | Image size  BL332-BL338

          # Change Destination Address BL332-BL338
          sed -i -E 's/(#define RCAR_BL33[2-8]DST_ADDRESS\t\t)(\(0x00000000U\))/\1(0x50000000U)/' $CERT_HEADER

          # Change Source Address BL332-BL337
          #define RCAR_BL332SRC_ADDRESS		(0x00000000U)
          sed -i -E 's/(#define RCAR_BL33[2-7]SRC_ADDRESS\t\t)(\(0x00000000U\))/\1(0x00640000U)/' $CERT_HEADER

          # Change Source Address BL338
          sed -i -e "s/#define RCAR_BL338SRC_ADDRESS		(0x00000000U)/#define RCAR_BL338SRC_ADDRESS\t\t(0x${src_addr}U)/" $CERT_HEADER

          # Change Image Size BL332-BL338
          sed -i -E 's/(#define RCAR_BL33[2-8]DST_SIZE\t\t)(\(0x00000000U\))/\1(0x00040000U)/' $CERT_HEADER

          ;;
      *)
          echo "Unknown type."
          ;;
  esac

}


echo "Run with 07_Range_Check_No $TESTNO (${check_range[$TESTNO]})"

for i in "${check_range[@]}"; do
  eval $i
  if [ "${image_info[0]}" == "$TESTNO" ]; then
    echo '+-----------------------------------------------------'
    echo "Creating cert Image for 07_Range_Check_No.${image_info[0]}"
    echo '+-----------------------------------------------------'
    echo "${image_info[0]} ${image_info[1]} ${image_info[2]} ${image_info[3]} ${image_info[4]}"

    # Update certification info
    update_cert "${image_info[1]}" "${image_info[2]}" "${image_info[3]}" "${image_info[4]}"
  fi
done

exit -1

# Open minicom and save log
#cd $LOG_DIR
#minicom -D $TTY_USB -C 07_Range_Check_No.dummy1_M3.log &

