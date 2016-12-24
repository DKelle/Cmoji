javac preprocessor.java
java preprocessor < cmj/prog.cmj 
make compiler
./compiler < preprocessed.txt
python assembler.py
../processor/cpu
