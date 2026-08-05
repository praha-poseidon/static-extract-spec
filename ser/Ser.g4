// Static Extract Rule (SER) — structure only.
// Language words after find/from/when/take are free atoms; extractors interpret them.
grammar Ser;

// One rule file = one find + optional value-trace block for that find.
// No standalone trace files: patches live in the same .ser as the rule.
//
// Filter keywords (different roles — not aliases):
//   where = scope / enclosure (class, package, file, annotation on class)
//   when  = conditions on the find anchor itself (method/field/call attributes)
ruleFile
    : ruleDecl ruleTargetDecl findDecl whereDecl* whenDecl* letDecl* buildDecl embeddedTrace? EOF
    ;

ruleDecl
    : RULE STRING
    ;

// Optional value-trace patches for take-value (same file, after build).
embeddedTrace
    : TRACE LBRACE traceEntry* RBRACE
    ;

ruleTargetDecl
    : ENDPOINT freeAtom freeAtom
    | FACT freeAtom
    ;

// find <free atoms…>  (vocabulary; not interpreted by this grammar)
findDecl
    : FIND freeAtom+
    ;

// where = scope: where the match lives (enclosing type/package/file/…)
whereDecl
    : WHERE IF conditionExpr
    | WHERE freeAtom+
    ;

// when = anchor predicates: when the found element itself matches
whenDecl
    : WHEN IF conditionExpr
    | WHEN freeAtom+
    ;

// Optional pipeline after let sources (same steps as build fields).
letDecl
    : LET freeAtom EQ sourceLine+ defaultLine? mapBlock? pipelineStep*
    ;

sourceLine
    : FROM freeAtom+ TAKE freeAtom+
    ;

// 'fallback' avoids clashing with free word "default" (e.g. export default, build field default)
defaultLine
    : FALLBACK freeAtom
    ;

mapBlock
    : MAP LBRACE mapEntry* RBRACE
    ;

mapEntry
    : freeAtom COLON freeAtom
    ;

buildDecl
    : BUILD LBRACE buildField* RBRACE
    ;

buildField
    : freeAtom COLON buildExpr pipelineStep*
    ;

traceEntry
    : FROM freeAtom whenDecl* letDecl* buildDecl
    ;

// --- free atoms (not structure keywords) ---

// Prefer splitting "call" and "[a,b]" into two atoms; use IDENT[...] for argument[0].
// Allow common structure words as free identifiers in free positions (e.g. build field "default").
freeAtom
    : annotationAtom
    | LBRACK freeList RBRACK
    | LPAREN freeAtom* RPAREN
    | freeIdent DOT LBRACK freeList RBRACK
    | freeIdent (DOT freeIdent)+
    | freeIdent LBRACK freeList RBRACK
    | freeIdent
    | STRING
    | INT
    ;

// MAP is structure (mapBlock). DEFAULT is free word (export default, build keys).
// FALLBACK starts defaultLine (was legacy keyword "default").
freeIdent
    : IDENT
    | KEY
    | DEFAULT
    | GROUP
    | IN
    ;

freeList
    : freeAtom (COMMA freeAtom)*
    ;

qualifiedName
    : IDENT (DOT IDENT)*
    ;

annotationAtom
    : AT STAR? IDENT
    ;

// --- conditions (structure for when if) ---

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
    : IDENT conditionPathPart*
    ;

conditionPathPart
    : DOT IDENT
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
    | IDENT
    | INT
    ;

// --- build expressions ---

buildExpr
    : STRING
    | freeAtom
    | CONCAT LPAREN concatList RPAREN
    ;

concatList
    : concatItem (COMMA concatItem)*
    ;

concatItem
    : freeAtom
    | STRING
    ;

pipelineStep
    : PIPE NORMALIZE IDENT
    | PIPE REGEX STRING GROUP INT
    | PIPE REPLACE STRING STRING
    | PIPE MAP LBRACE mapEntry* RBRACE
    ;

// --- structure keywords only ---

RULE: 'rule';
TRACE: 'trace';
ENDPOINT: 'endpoint';
FACT: 'fact';
FIND: 'find';
LET: 'let';
FROM: 'from';
TAKE: 'take';
DEFAULT: 'default';
FALLBACK: 'fallback';
MAP: 'map';
BUILD: 'build';
WHEN: 'when';
WHERE: 'where';
IF: 'if';
AND: 'and';
OR: 'or';
NOT: 'not';
EXISTS: 'exists';
MATCHES: 'matches';
CONTAINS: 'contains';
IN: 'in';
CONCAT: 'concat';
NORMALIZE: 'normalize';
REGEX: 'regex';
REPLACE: 'replace';
GROUP: 'group';
KEY: 'key';

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
