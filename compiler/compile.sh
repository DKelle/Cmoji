javac preprocessor.java
java preprocessor < simple.cmj 
make lexer
./lexer < preprocessed.txt
make parser
./parser < preprocessed.txt
