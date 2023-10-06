grammar Cactus;

// Parser rules
program : MAIN LP RP LB 
          { System.out.println("\t" + ".data"); }
          declarations
          {
            System.out.println("\t" + ".text");
            System.out.println("main:");
          }
          statements[0, 1] RB;

declarations:
    a = type list[$a.t] SE declarations
    |;
type returns [String t]: INT { $t = "integer"; };
list [String t]:
    ID
    {
      if ($t == "integer")
        System.out.println($ID.text + ":\t.word\t0");
    }
    list1[$t];
list1 [String t]:
    COMMA ID
    {
      if ($t == "integer")
        System.out.println($ID.text + ":\t.word\t0");
    }
    list1[$t]
    |;

statements [int reg, int label] returns [int nreg, int nlabel]:
    a = statement[$reg, $label]
    b = statements[$a.nreg, $a.nlabel]
    {
      $nreg = $reg;
      $nlabel = $label;
    }
    |
    {
      $nreg = $reg;
      $nlabel = $label;
    }
    ;
statement [int reg, int label] returns [int nreg, int nlabel]:
    ID ASS
    a = arith_expression[$reg] SE
    {
      System.out.println("\tla\t\$t" + $a.nreg + ",\t" + $ID.text);
      System.out.println("\tsw\t\$t" + $a.place + ",\t0(\$t" + $a.nreg + ")");
      $nreg = $a.nreg - 1;
      $nlabel = $label;
    }
    |
    READ ID SE
    {
      System.out.println("\tli\t\$v0,\t5");
      System.out.println("\tsyscall");
      System.out.println("\tla\t\$t" + $reg + ",\t" + $ID.text);
      System.out.println("\tsw\t\$v0,\t0(\$t" + $reg + ")");
      $nreg = $reg;
      $nlabel = $label;
    }
    |
    WRITE a = arith_expression[$reg] SE
    {
      System.out.println("\tmove\t\$a0,\t\$t" + $a.place);
      System.out.println("\tli\t\$v0,\t1");
      System.out.println("\tsyscall");
      $nreg = $a.nreg - 1;
      $nlabel = $label;
    }
    |
    RETURN SE
    {
      System.out.println("\tli\t\$v0,\t10");
      System.out.println("\tsyscall");
      $nreg = $reg;
      $nlabel = $label;
    }
    |
    IF LP
    {
      $label = $label + 2;
    }
    b = bool_expression[$reg, $label, ($label - 2), ($label - 1)] RP LB
    {
      System.out.println("L" + ($label - 2) + ":");
    }
    c = statements[$b.nreg, $b.nlabel]
    {
      System.out.println("L" + ($label - 1) + ":");
      $nreg = $c.nreg;
      $nlabel = $c.nlabel;
    } RB FI
    |
    IF LP
    {
      $label = $label + 3;
    }
    d = bool_expression[$reg, $label, ($label - 3), ($label - 2)] RP LB
    {
      System.out.println("L" + ($label - 3) + ":");
    }
    e = statements[$d.nreg, $d.nlabel] RB ELSE LB
    {
      System.out.println("\tb\tL" + ($label - 1));
      System.out.println("L" +($label - 2) + ":");
    }
    f = statements[$e.nreg, $e.nlabel]
    {
      System.out.println("L" + ($label - 1) + ":");
      $nreg = $f.nreg;
      $nlabel = $f.nlabel;
    } RB FI
    |
    WHILE LP
    {
      $label = $label + 3;
      System.out.println("L" + ($label - 3) + ":");
    }
    g = bool_expression[$reg, $label, ($label - 2), ($label - 1)] RP LB
    {
      System.out.println("L" + ($label - 2) + ":");
    }
    statements[$g.nreg, $g.nlabel]
    {
      System.out.println("\tb\tL" + ($label - 3));
      System.out.println("L" + ($label - 1) + ":");
      $nreg = $g.nreg;
      $nlabel = $g.nlabel;
    } RB;

arith_expression [int reg] returns [int nreg, int place]:
    a = arith_term[$reg] b = arith_expression1[$a.place, $a.nreg]
    {
      $nreg = $b.nreg;
      $place = $b.place;
    };
arith_expression1 [int left, int reg] returns [int nreg, int place]:
    ADD a = arith_term[$reg]
    {
      System.out.println("\tadd\t\$t" + $left + ",\t\$t" + $left + ",\t\$t" + $a.place);
      $a.nreg = $a.nreg - 1;
    }
    b = arith_expression1[$left, $a.nreg]
    {
      $nreg = $b.nreg;
      $place = $b.place;
    }
    |
    SUB a = arith_term[$reg]
    {
      System.out.println("\tsub\t\$t" + $left + ",\t\$t" + $left + ",\t\$t" + $a.place);
      $a.nreg = $a.nreg - 1;
    }
    b = arith_expression1[$left, $a.nreg]
    {
      $nreg = $b.nreg;
      $place = $b.place;
    }
    |
    {
      $nreg = $reg;
      $place = $left;
    };

arith_term [int reg] returns [int nreg, int place]:
    a = arith_factor[$reg] b = arith_term1[$a.place, $a.nreg]
    {
      $nreg = $b.nreg;
      $place = $b.place;
    };
arith_term1 [int left, int reg] returns [int nreg, int place]:
    MUL a = arith_factor[$reg]
    {
      System.out.println("\tmul\t\$t" + $left + ",\t\$t" + $left + ",\t\$t" + $a.place);
      $a.nreg = $a.nreg - 1;
    }
    b = arith_term1[$left, $a.nreg]
    {
      $nreg = $b.nreg;
      $place = $b.place;
    }
    |
    DIV a = arith_factor[$reg]
    {
      System.out.println("\tdiv\t\$t" + $left + ",\t\$t" + $left + ",\t\$t" + $a.place);
      $a.nreg = $a.nreg - 1;
    }
    b = arith_term1[$left, $a.nreg]
    {
      $nreg = $b.nreg;
      $place = $b.place;
    }
    |
    MOD a = arith_factor[$reg]
    {
      System.out.println("\tmod\t\$t" + $left + ",\t\$t" + $left + ",\t\$t" + $a.place);
      $a.nreg = $a.nreg - 1;
    }
    b = arith_term1[$left, $a.nreg]
    {
      $nreg = $b.nreg;
      $place = $b.place;
    }
    |
    {
      $nreg = $reg;
      $place = $left;
    };

arith_factor [int reg] returns [int nreg, int place]:
    SUB a = arith_factor[$reg]
    {
      System.out.println("\tneg\t\$t" + $a.place + ",\t\$t" + $a.place);
      $nreg = $a.nreg;
      $place = $a.place;
    }
    |
    b = primary_expression[$reg]
    {
      $nreg = $b.nreg;
      $place = $b.place;
    };
primary_expression [int reg] returns [int nreg, int place]:
    CONST
    {
      System.out.println("\tli\t\$t" + $reg + ",\t" + $CONST.text);
      $place = $reg;
      $nreg = $reg + 1;
    }
    |
    ID
    {
      System.out.println("\tla\t\$t" + $reg + ",\t" + $ID.text);
      System.out.println("\tlw\t\$t" + $reg + ",\t0(\$t" + $reg + ")");
      $place = $reg;
      $nreg = $reg + 1;
    }
    |
    LP a = arith_expression[$reg]
    {
      $nreg = $a.nreg;
      $place = $a.place;
    }
    RP;

bool_expression [int reg, int label, int tt, int ff] returns [int nreg, int nlabel]:
    { $label = $label + 1; }
    a = bool_term[$reg, $label, $tt, $label - 1]
    { System.out.println("L" + ($label - 1) + ":"); }
    b = bool_expression1[$a.nreg, $a.nlabel, $tt, $ff]
    {
      $nreg = $b.nreg;
      $nlabel = $b.nlabel;
    };
bool_expression1 [int reg, int label, int tt, int ff] returns [int nreg, int nlabel]:
    OR { $label = $label + 1; }
    a = bool_term[$reg, $label, $tt, $label - 1]
    { System.out.println("L" + ($label - 1) + ":"); }
    b = bool_expression1[$a.nreg, $a.nlabel, $tt, $ff]
    {
      $nreg = $b.nreg;
      $nlabel = $b.nlabel;
    }
    |
    {
      System.out.println("\tb\tL" + $ff);
      $nreg = $reg;
      $nlabel = $label;
    };

bool_term [int reg, int label, int tt, int ff] returns [int nreg, int nlabel]:
    { $label = $label + 1; }
    a = bool_factor[$reg, $label, $label - 1, $ff]
    { System.out.println("L" + ($label - 1) + ":"); }
    b = bool_term1[$a.nreg, $a.nlabel, $tt, $ff]
    {
      $nreg = $b.nreg;
      $nlabel = $b.nlabel;
    };
bool_term1 [int reg, int label, int tt, int ff] returns [int nreg, int nlabel]:
    AND
    { $label = $label + 1; }
    a = bool_factor[$reg, $label, $label - 1, $ff]
    { System.out.println("L" + ($label - 1) + ":"); }
    b = bool_term1[$a.nreg, $a.nlabel, $tt, $ff]
    {
      $nreg = $b.nreg;
      $nlabel = $b.nlabel;
    }
    |
    {
      System.out.println("\tb\tL" + $tt);
      $nreg = $reg;
      $nlabel = $label;
    };

bool_factor [int reg, int label, int tt, int ff] returns [int nreg, int nlabel]:
    NOT a = bool_factor[$reg, $label, $ff, $tt]
    {
      $nreg = $a.nreg;
      $nlabel = $a.nlabel;
    }
    |
    LP b = rel_expression[$reg, $label, $tt, $ff] RP
    {
      $nreg = $b.nreg;
      $nlabel = $label;
    } 
    |
    b = rel_expression[$reg, $label, $tt, $ff]
    {
      $nreg = $b.nreg;
      $nlabel = $label;
    };

rel_expression [int reg, int label, int tt, int ff] returns [int nreg]:
    a = arith_expression[$reg] EQ b = arith_expression[$a.nreg]
    {
      System.out.println("\tbeq\t\$t" + $a.place + ",\t\$t" + $b.place + ",\tL" + $tt);
      System.out.println("\tb\tL" + $ff);
      $nreg = $b.nreg - 2;
    }
    |
    a = arith_expression[$reg] NE b = arith_expression[$a.nreg]
    {
      System.out.println("\tbne\t\$t" + $a.place + ",\t\$t" + $b.place + ",\tL" + $tt);
      System.out.println("\tb\tL" + $ff);
      $nreg = $b.nreg - 2;
    }
    |
    a = arith_expression[$reg] GT b = arith_expression[$a.nreg]
    {
      System.out.println("\tbgt\t\$t" + $a.place + ",\t\$t" + $b.place + ",\tL" + $tt);
      System.out.println("\tb\tL" + $ff);
      $nreg = $b.nreg - 2;
    }
    |
    a = arith_expression[$reg] GE b = arith_expression[$a.nreg]
    {
      System.out.println("\tbge\t\$t" + $a.place + ",\t\$t" + $b.place + ",\tL" + $tt);
      System.out.println("\tb\tL" + $ff);
      $nreg = $b.nreg - 2;
    }
    |
    a = arith_expression[$reg] EQ b = arith_expression[$a.nreg]
    {
      System.out.println("\tbeq\t\$t" + $a.place + ",\t\$t" + $b.place + ",\tL" + $tt);
      System.out.println("\tb\tL" + $ff);
      $nreg = $b.nreg - 2;
    }
    |
    a = arith_expression[$reg] LT b = arith_expression[$a.nreg]
    {
      System.out.println("\tblt\t\$t" + $a.place + ",\t\$t" + $b.place + ",\tL" + $tt);
      System.out.println("\tb\tL" + $ff);
      $nreg = $b.nreg - 2;
    }
    |
    a = arith_expression[$reg] LE b = arith_expression[$a.nreg]
    {
      System.out.println("\tble\t\$t" + $a.place + ",\t\$t" + $b.place + ",\tL" + $tt);
      System.out.println("\tb\tL" + $ff);
      $nreg = $b.nreg - 2;
    };

// Lexer rules
MAIN : 'main';
ELSE : 'else';
IF : 'if';
FI : 'fi';
INT : 'int';
RETURN : 'return';
WHILE : 'while';
READ : 'read';
WRITE : 'write';
ID : [a-zA-Z_] [a-zA-Z0-9_]*;
CONST : [0-9]+;
ADD : '+';
SUB : '-';
MUL : '*';
DIV : '/';
MOD : '%';
EQ : '==';
NE : '!=';
GT : '>';
GE : '>=';
LT : '<';
LE : '<=';
AND : '&&';
OR : '||';
NOT : '!';
ASS : '=';
LP : '(';
RP : ')';
LB : '{';
RB : '}';
SE : ';';
COMMA : ',';
WHITESPACE : [ \t\r\n]+ -> skip;
COMMENT : '/*' .*? '*/' -> skip;
