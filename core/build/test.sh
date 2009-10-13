# comile tests to .swf
mxmlc ../test/MockTestRunner.mxml \
 -debug=true \
 -sp ../src \
 -sp ../test \
 -library-path+=../libs \
 -output ../bin/MockTestRunner.swf