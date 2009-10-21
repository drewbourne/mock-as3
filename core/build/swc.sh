# compile src to .swc
FLEX_HOME="${FLEX_HOME:?'FLEX_HOME must be set'}"
PROJECT_DIR=$(unset CDPATH; cd `dirname $0`/..; pwd)
COMPC="${FLEX_HOME}/bin/compc"
"$COMPC" \
 -source-path $PROJECT_DIR/src \
 -include-sources $PROJECT_DIR/src \
 -compiler.include-libraries \
 $PROJECT_DIR/libs/Floxy.swc \
 $PROJECT_DIR/libs/FlexUnit4.swc \
 $PROJECT_DIR/libs/FlexUnit4UIRunner.swc \
 $PROJECT_DIR/libs/asx.swc \
 $PROJECT_DIR/libs/hamcrest.swc \
 -output $PROJECT_DIR/bin/mock-as3.swc
