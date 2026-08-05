grammar Ser;

ruleFile
    : ruleDecl ruleTargetDecl findDecl whenDecl* letDecl* buildDecl EOF
    ;

traceFile
    : traceDecl traceEntry* EOF
    ;

ruleDecl
    : RULE STRING
    ;

traceDecl
    : TRACE STRING
    ;

endpointDecl
    : ENDPOINT valueToken valueToken
    ;

factDecl
    : FACT valueToken
    ;

ruleTargetDecl
    : endpointDecl
    | factDecl
    ;

// Prefer generic: find <kind> <selector>?
// Java dialect sugar "find X with annotation @Y" is removed from the public grammar
// (step-C3). static-extract-java desugars that form before parse (step-B2).
findDecl
    : FIND METHOD methodPattern
    | FIND CLASS
    | FIND FIELD fieldName=nameItem
    | FIND genericFindKind=nameItem genericFindName=findName?
    ;

letDecl
    : LET letName=nameItem EQ sourceLine+ defaultLine? mapBlock?
    ;

sourceLine
    : FROM sourceExpr TAKE takeExpr
    ;

// Preferred annotation/decorator order: ref first, then optional on-target
//   from annotation @GetMapping on method take attr(value)
// Legacy Java order (still accepted; Java desugar can rewrite to preferred):
//   from annotation on method @GetMapping take attr(value)
sourceExpr
    : ANNOTATION annotationRef ON elementRef
    | ANNOTATION ON elementRef annotationRef
    | DECORATOR decoratorRef ON elementRef
    | DECORATOR ON elementRef decoratorRef
    | ARGUMENT LBRACK INT RBRACK
    | CALL
    | DECORATOR
    | METHOD
    | CLASS
    | FIELD sourceName=nameItem?
    | PARAMETER sourceName=nameItem?
    | RETURN
    | ASSIGNMENT
    | NEW qualifiedName
    | LITERAL literal
    | genericSourceKind=nameItem genericSourceName=nameItem?
    ;

takeExpr
    : NAME
    | VALUE
    | RAW
    | TYPE
    | OWNER
    | SIGNATURE
    | ATTR LPAREN identList RPAREN
    | genericTake=nameItem
    ;

defaultLine
    : DEFAULT literal
    ;

mapBlock
    : MAP LBRACE mapEntry* RBRACE
    ;

mapEntry
    : valueToken COLON valueToken
    ;

buildDecl
    : BUILD LBRACE buildField* RBRACE
    ;

buildField
    : buildFieldName COLON buildExpr pipelineStep*
    ;

buildFieldName
    : nameItem
    | KEY
    | DEFAULT
    | OWNER
    | SIGNATURE
    ;

traceEntry
    : FROM traceTarget whenDecl* letDecl* buildDecl
    ;

whenDecl
    : WHEN IF conditionExpr
    | WHEN ANNOTATION annotationRef ON elementRef
    | WHEN METHOD methodPattern
    | WHEN CALL methodPattern
    | WHEN FIELD NAME valueToken
    | WHEN FIELD TYPE qualifiedName
    | WHEN PARAMETER NAME valueToken
    | WHEN PARAMETER TYPE qualifiedName
    | WHEN METHOD NAME valueToken
    | WHEN CALL NAME valueToken
    | WHEN CALL OWNER qualifiedName
    | WHEN ASSIGNMENT FIELD valueToken
    ;

conditionExpr
    : conditionOr
    ;

conditionOr
    : conditionAnd (OR conditionAnd)*
    ;

conditionAnd
    : conditionUnary (AND conditionUnary)*
    ;

conditionUnary
    : NOT conditionUnary
    | LPAREN conditionExpr RPAREN
    | conditionAtom
    ;

conditionAtom
    : conditionPath EXISTS
    | conditionPath conditionOp conditionValue
    ;

conditionPath
    : nameItem conditionPathPart*
    ;

conditionPathPart
    : DOT nameItem
    | LBRACK INT RBRACK
    ;

conditionOp
    : EQEQ
    | NEQ
    | MATCHES
    | CONTAINS
    | IN
    ;

conditionValue
    : conditionScalar
    | LBRACK conditionScalar (COMMA conditionScalar)* RBRACK
    ;

conditionScalar
    : STRING
    | valueToken
    | INT
    ;

traceTarget
    : FIELD
    | CALL
    | PARAMETER
    | METHOD
    | RETURN
    | ASSIGNMENT
    ;

buildExpr
    : STRING
    | refName=nameItem
    | CONCAT LPAREN concatList RPAREN
    ;

concatList
    : concatItem (COMMA concatItem)*
    ;

concatItem
    : nameItem
    | STRING
    ;

pipelineStep
    : PIPE NORMALIZE IDENT
    | PIPE REGEX STRING GROUP INT
    | PIPE REPLACE STRING STRING
    | PIPE MAP LBRACE mapEntry* RBRACE
    ;

methodPattern
    : qualifiedName DOT LBRACK identList RBRACK
    | qualifiedName DOT IDENT
    ;

qualifiedName
    : IDENT (DOT IDENT)*
    ;

annotationRef
    : AT IDENT
    | AT STAR IDENT
    ;

decoratorRef
    : AT? IDENT
    ;

elementRef
    : CLASS
    | METHOD
    | FIELD
    | PARAMETER
    ;

identList
    : nameItem (COMMA nameItem)*
    ;

findName
    : nameItem
    | LBRACK identList RBRACK
    ;

nameItem
    : IDENT
    | NAME
    | VALUE
    | RAW
    | TYPE
    | ANNOTATION
    | ARGUMENT
    | METHOD
    | CLASS
    | FIELD
    | CALL
    | PARAMETER
    | RETURN
    | ASSIGNMENT
    | NEW
    | LITERAL
    | DECORATOR
    | KEY
    | DEFAULT
    | OWNER
    | SIGNATURE
    ;

literal
    : STRING
    | valueToken
    ;

valueToken
    : IDENT
    ;

RULE: 'rule';
TRACE: 'trace';
ENDPOINT: 'endpoint';
FACT: 'fact';
FIND: 'find';
WITH: 'with';
LET: 'let';
FROM: 'from';
ON: 'on';
TAKE: 'take';
DEFAULT: 'default';
MAP: 'map';
BUILD: 'build';
EXTERNAL: 'external';
WHEN: 'when';
KEY: 'key';
RESOLVE: 'resolve';

ANNOTATION: 'annotation';
DECORATOR: 'decorator';
ARGUMENT: 'argument';
METHOD: 'method';
CLASS: 'class';
FIELD: 'field';
CALL: 'call';
PARAMETER: 'parameter';
RETURN: 'return';
ASSIGNMENT: 'assignment';
NEW: 'new';
LITERAL: 'literal';

NAME: 'name';
VALUE: 'value';
RAW: 'raw';
TYPE: 'type';
OWNER: 'owner';
SIGNATURE: 'signature';
ATTR: 'attr';

CONCAT: 'concat';
NORMALIZE: 'normalize';
REGEX: 'regex';
REPLACE: 'replace';
GROUP: 'group';
PLAIN: 'plain';
PLACEHOLDER: 'placeholder';
IF: 'if';
AND: 'and';
OR: 'or';
NOT: 'not';
EXISTS: 'exists';
MATCHES: 'matches';
CONTAINS: 'contains';
IN: 'in';

EQEQ: '==';
NEQ: '!=';
EQ: '=';
COLON: ':';
COMMA: ',';
DOT: '.';
PIPE: '|';
AT: '@';
STAR: '*';
LBRACE: '{';
RBRACE: '}';
LBRACK: '[';
RBRACK: ']';
LPAREN: '(';
RPAREN: ')';

STRING
    : '"' ( '\\' . | ~["\\] )* '"'
    ;

IDENT
    : [A-Za-z_][A-Za-z0-9_$-]*
    ;

INT
    : [0-9]+
    ;

HASH_COMMENT
    : '#' ~[\r\n]* -> skip
    ;

SLASH_COMMENT
    : '//' ~[\r\n]* -> skip
    ;

BLOCK_COMMENT
    : '/*' .*? '*/' -> skip
    ;

WS
    : [ \t\r\n]+ -> skip
    ;
