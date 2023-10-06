# Implementation of a Code Generator

Use ANTLR to implement a code generator for MIPS processors.

1. Use the ANTLR tool to generate the lexer, parser, and code generator java code.
```
antlr4 Cactus.g4
```

2. Compile the generated java code.
```
javac Cactus*.java
```

3. Use the ANTLR tool to execute the code generator.
```
grun Cactus program <input_file> <output_file>
```
