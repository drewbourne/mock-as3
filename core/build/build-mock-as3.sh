# comile tests to .swf
mxmlc ../test/MockTestRunner.mxml \
 -sp ../src \
 -sp ../../../flexunit/src \
 -output ../bin/MockTestRunner.swf

# compile src to .swc
compc \
 -include-sources ../src \
 -output ../bin/mock-as3.swc

# generate docs
asdoc \
 -doc-sources ../src \
 -source-path ../src \
 -main-title "mock-as3 API Documentation" \
 -window-title "mock-as3 API Documentation" \
 -output ../doc
