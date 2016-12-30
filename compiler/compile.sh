javac preprocessor.java
java preprocessor < ../examples/prog.cmj 
make compiler
./compiler < preprocessed.txt
python assembler.py
../processor/cpu
