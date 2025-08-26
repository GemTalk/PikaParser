Class {
	#name : 'PikaEndToEndTest',
	#superclass : 'TestCase',
	#instVars : [
		'arithmeticGrammar',
		'java1_8Grammar'
	],
	#category : 'Pika-Tests',
	#package : 'Pika-Tests'
}

{ #category : 'accessing' }
PikaEndToEndTest class >> defaultTimeLimit [

	^ 60 seconds
]

{ #category : 'support' }
PikaEndToEndTest >> arithmeticGrammar [

	arithmeticGrammar ifNil: [
		arithmeticGrammar := PikaMetaGrammar parse:
			                     self arithmeticGrammarSource ].
	^ arithmeticGrammar
]

{ #category : 'support' }
PikaEndToEndTest >> arithmeticGrammarSource [

	^ '
	Program <- Statement+;
	Statement <- var:[a-z]+ ''='' E '';'';
	E[4] <- ''('' E '')'';
	E[3] <- num:[0-9]+ / sym:[a-z]+;
	E[2] <- arith:(op:''-'' E);
	E[1,L] <- arith:(E op:(''*'' / ''/'') E);
	E[0,L] <- arith:(E op:(''+'' / ''-'') E);
'
]

{ #category : 'support' }
PikaEndToEndTest >> java1_8Grammar [

	java1_8Grammar ifNil: [
		java1_8Grammar := PikaMetaGrammar parse:
			                     self java1_8GrammarSource ].
	^ java1_8Grammar
]

{ #category : 'support' }
PikaEndToEndTest >> java1_8GrammarSource [

"// The Java 1.8.peg file included in this project is based on the one for
// Mouse 1.5 - 1.8 by Roman Redziejowski, with some modifications for the
// pika parser. The copyright notice is included below, as comments had to
// be removed from the original version.

//===========================================================================
//
//  Parsing Expression Grammar of Java 1.8 for Mouse 1.5 - 1.8.
//  Based on Java Language Specification, Java SE8 Edition, dated 2014-03-03,
//  obtained from http://docs.oracle.com/javase/specs/jls/se8/html/index.html
//  and parser code from openjdk.8b132.2014.03.03.
//
//---------------------------------------------------------------------------
//
//  Copyright (C) 2014
//  by Roman R Redziejowski(www.romanredz.se).
//
//  The author gives unlimited permission to copy and distribute
//  this file, with or without modifications, as long as this notice
//  is preserved, and any changes are properly documented.
//
//  This file is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
//---------------------------------------------------------------------------
//
//  Latest update 2014-12-11
//
//---------------------------------------------------------------------------
//  Change log
//---------------------------------------------------------------------------
//
//    2014-10-27 Posted on Internet.
//    2014-11-01 Corrected NormalInterfaceDeclaration.
//    2014-11-02 Corrected title comments to JLS 3.10.1 and 3.10.2.
//               Replaced SimpleQualIdent by Identifier
//               in ConstructorDeclarator (JLS 8.8).
//    2014-12-11 Commented out unused definitions: ArrayAccess, FieldAccess,
//               ClassInstanceCreationExpression, MethodInvocation.
//
//===========================================================================
"

^ 'Compilation
    <- Spacing CompilationUnit SUB? EOT;

_ <- [\u0000-\uFFFF] ;
SUB <- ''\u001a'' ;
EOT <- !_ ;
WS <- [ \t\r\n\u000C] ;

Spacing
    <- ( WS+
         / "/**/"
         / "/*" (_ !"*/")* _ "*/"
         / "//" [^\r\n]*
       )* ;

Identifier  <- !Keyword Letter LetterOrDigit* Spacing ;

Letter <- [a-z] / [A-Z] / [_$] ;

LetterOrDigit <- [a-z] / [A-Z] / [0-9] / [_$] ;

Keyword
    <- ( "abstract"
      / "assert"
      / "boolean"
      / "break"
      / "byte"
      / "case"
      / "catch"
      / "char"
      / "class"
      / "const"
      / "continue"
      / "default"
      / "double"
      / "do"
      / "else"
      / "enum"
      / "extends"
      / "false"
      / "finally"
      / "final"
      / "float"
      / "for"
      / "goto"
      / "if"
      / "implements"
      / "import"
      / "interface"
      / "int"
      / "instanceof"
      / "long"
      / "native"
      / "new"
      / "null"
      / "package"
      / "private"
      / "protected"
      / "public"
      / "return"
      / "short"
      / "static"
      / "strictfp"
      / "super"
      / "switch"
      / "synchronized"
      / "this"
      / "throws"
      / "throw"
      / "transient"
      / "true"
      / "try"
      / "void"
      / "volatile"
      / "while"
      ) !LetterOrDigit
    ;

ABSTRACT     <- "abstract"     !LetterOrDigit Spacing ;
ASSERT       <- "assert"       !LetterOrDigit Spacing ;
BOOLEAN      <- "boolean"      !LetterOrDigit Spacing ;
BREAK        <- "break"        !LetterOrDigit Spacing ;
BYTE         <- "byte"         !LetterOrDigit Spacing ;
CASE         <- "case"         !LetterOrDigit Spacing ;
CATCH        <- "catch"        !LetterOrDigit Spacing ;
CHAR         <- "char"         !LetterOrDigit Spacing ;
CLASS        <- "class"        !LetterOrDigit Spacing ;
CONTINUE     <- "continue"     !LetterOrDigit Spacing ;
DEFAULT      <- "default"      !LetterOrDigit Spacing ;
DOUBLE       <- "double"       !LetterOrDigit Spacing ;
DO           <- "do"           !LetterOrDigit Spacing ;
ELSE         <- "else"         !LetterOrDigit Spacing ;
ENUM         <- "enum"         !LetterOrDigit Spacing ;
EXTENDS      <- "extends"      !LetterOrDigit Spacing ;
FALSE        <- "false"        !LetterOrDigit Spacing ;
FINALLY      <- "finally"      !LetterOrDigit Spacing ;
FINAL        <- "final"        !LetterOrDigit Spacing ;
FLOAT        <- "float"        !LetterOrDigit Spacing ;
FOR          <- "for"          !LetterOrDigit Spacing ;
IF           <- "if"           !LetterOrDigit Spacing ;
IMPLEMENTS   <- "implements"   !LetterOrDigit Spacing ;
IMPORT       <- "import"       !LetterOrDigit Spacing ;
INTERFACE    <- "interface"    !LetterOrDigit Spacing ;
INT          <- "int"          !LetterOrDigit Spacing ;
INSTANCEOF   <- "instanceof"   !LetterOrDigit Spacing ;
LONG         <- "long"         !LetterOrDigit Spacing ;
NATIVE       <- "native"       !LetterOrDigit Spacing ;
NEW          <- "new"          !LetterOrDigit Spacing ;
NULL         <- "null"         !LetterOrDigit Spacing ;
PACKAGE      <- "package"      !LetterOrDigit Spacing ;
PRIVATE      <- "private"      !LetterOrDigit Spacing ;
PROTECTED    <- "protected"    !LetterOrDigit Spacing ;
PUBLIC       <- "public"       !LetterOrDigit Spacing ;
RETURN       <- "return"       !LetterOrDigit Spacing ;
SHORT        <- "short"        !LetterOrDigit Spacing ;
STATIC       <- "static"       !LetterOrDigit Spacing ;
STRICTFP     <- "strictfp"     !LetterOrDigit Spacing ;
SUPER        <- "super"        !LetterOrDigit Spacing ;
SWITCH       <- "switch"       !LetterOrDigit Spacing ;
SYNCHRONIZED <- "synchronized" !LetterOrDigit Spacing ;
THIS         <- "this"         !LetterOrDigit Spacing ;
THROWS       <- "throws"       !LetterOrDigit Spacing ;
THROW        <- "throw"        !LetterOrDigit Spacing ;
TRANSIENT    <- "transient"    !LetterOrDigit Spacing ;
TRUE         <- "true"         !LetterOrDigit Spacing ;
TRY          <- "try"          !LetterOrDigit Spacing ;
VOID         <- "void"         !LetterOrDigit Spacing ;
VOLATILE     <- "volatile"     !LetterOrDigit Spacing ;
WHILE        <- "while"        !LetterOrDigit Spacing ;

Literal
    <- FloatLiteral
    / IntegerLiteral
    / BooleanLiteral
    / CharLiteral
    / StringLiteral
    / NullLiteral
    ;

IntegerLiteral
    <- ( HexNumeral
      / BinaryNumeral
      / OctalNumeral
      / DecimalNumeral
      ) [lL]? Spacing
    ;

DecimalNumeral
    <- "0"
    / [1-9]([_]*[0-9])*
    ;

HexNumeral
    <- ("0x" / "0X") HexDigits ;

OctalNumeral
    <- "0" ([_]*[0-7])+ ;

BinaryNumeral
    <- ("0b" / "0B") [01]([_]*[01])* ;

FloatLiteral
    <- ( HexadecimalFloatingPointLiteral
      / DecimalFloatingPointLiteral
      ) Spacing
    ;

DecimalFloatingPointLiteral
    <- Digits "." Digits?  Exponent? [fFdD]?
    / "." Digits Exponent? [fFdD]?
    / Digits Exponent [fFdD]?
    / Digits Exponent? [fFdD]
    ;

Exponent
    <- [eE] [+\-]? Digits ;

HexadecimalFloatingPointLiteral
    <- HexSignificand BinaryExponent [fFdD]? ;

HexSignificand
    <- ("0x" / "0X") HexDigits? "." HexDigits
    / HexNumeral "."?
    ;

HexDigits
    <- HexDigit ([_]*HexDigit)* ;

HexDigit
    <- [a-f] / [A-F] / [0-9] ;

BinaryExponent
    <- [pP] [+\-]? Digits ;

Digits
    <- [0-9]([_]*[0-9])* ;

BooleanLiteral
    <- TRUE
    / FALSE
    ;

CharLiteral
    <- "''" (Escape / ![''\\\n\r] _) "''" Spacing
    ;

StringLiteral
    <- "\"" (Escape / !["\\\n\r] _)* "\"" Spacing
    ;

Escape
    <- "\\" ([btnfr"''\\] / OctalEscape / UnicodeEscape)
    ;

OctalEscape
    <- [0-3][0-7][0-7]
    / [0-7][0-7]
    / [0-7]
    ;

UnicodeEscape
    <- "u"+ HexDigit HexDigit HexDigit HexDigit ;

NullLiteral <- NULL ;

AT              <-   "@"       Spacing ;
COLONCOLON      <-   "::"      Spacing ;
COMMA           <-   ","       Spacing ;
DOT             <-   "."       Spacing ;
ELLIPSIS        <-   "..."     Spacing ;
LPAR            <-   "("       Spacing ;
LBRK            <-   "["       Spacing ;
RBRK            <-   "]"       Spacing ;
RPAR            <-   ")"       Spacing ;
LWING           <-   "{"       Spacing ;
RWING           <-   "}"       Spacing ;
SEMI            <-   ";"       Spacing ;

AND             <-   "&"![=&]  Spacing ;
ANDAND          <-   "&&"      Spacing ;
ANDEQU          <-   "&="      Spacing ;
ARROW           <-   "->"      Spacing ;
BANG            <-   "!" ![=]  Spacing ;
BSR             <-   ">>>"![=] Spacing ;
BSREQU          <-   ">>>="    Spacing ;
COLON           <-   ":" ![:]  Spacing ;
DEC             <-   "--"      Spacing ;
DIV             <-   "/" ![=]  Spacing ;
DIVEQU          <-   "/="      Spacing ;
EQU             <-   "=" ![=]  Spacing ;
EQUAL           <-   "=="      Spacing ;
GE              <-   ">="      Spacing ;
GT              <-   ">"![=>]  Spacing ;
HAT             <-   "^"![=]   Spacing ;
HATEQU          <-   "^="      Spacing ;
INC             <-   "++"      Spacing ;
LE              <-   "<="      Spacing ;
LPOINT          <-   "<"       Spacing ;
LT              <-   "<"![=<]  Spacing ;
MINUS           <-   "-"![=\->]Spacing ;
MINUSEQU        <-   "-="      Spacing ;
MOD             <-   "%"![=]   Spacing ;
MODEQU          <-   "%="      Spacing ;
NOTEQUAL        <-   "!="      Spacing ;
OR              <-   "|"![=|]  Spacing ;
OREQU           <-   "|="      Spacing ;
OROR            <-   "||"      Spacing ;
PLUS            <-   "+"![=+]  Spacing ;
PLUSEQU         <-   "+="      Spacing ;
QUERY           <-   "?"       Spacing ;
RPOINT          <-   ">"       Spacing ;
SL              <-   "<<"![=]  Spacing ;
SLEQU           <-   "<<="     Spacing ;
SR              <-   ">>"![=>] Spacing ;
SREQU           <-   ">>="     Spacing ;
STAR            <-   "*"![=]   Spacing ;
STAREQU         <-   "*="      Spacing ;
TILDE           <-   "~"       Spacing ;

BasicType
    <- BYTE
    / SHORT
    / INT
    / LONG
    / CHAR
    / FLOAT
    / DOUBLE
    / BOOLEAN
    ;

PrimitiveType
    <- Annotation* BasicType ;

ReferenceType
    <- PrimitiveType Dim+
    / ClassType Dim*
    ;

ClassType
    <- Annotation* Identifier TypeArguments?
          (DOT Annotation* Identifier TypeArguments?)* ;

Type
    <- PrimitiveType
    / ClassType
    ;

ArrayType
    <- PrimitiveType Dim+
    / ClassType Dim+
    ;

TypeVariable
    <- Annotation* Identifier ;

Dim
    <- Annotation* LBRK RBRK ;

TypeParameter
    <- TypeParameterModifier* Identifier TypeBound? ;

TypeParameterModifier
    <- Annotation ;

TypeBound
    <- EXTENDS (ClassType AdditionalBound* / TypeVariable) ;

AdditionalBound
    <- AND ClassType ;

TypeArguments
    <- LPOINT TypeArgumentList RPOINT ;

TypeArgumentList
    <- TypeArgument (COMMA TypeArgument)* ;

TypeArgument
    <- ReferenceType
    / Wildcard
    ;

Wildcard
    <- Annotation* QUERY WildcardBounds? ;

WildcardBounds
    <- EXTENDS ReferenceType
    / SUPER ReferenceType
    ;
QualIdent
    <- Identifier (DOT Identifier)* ;

CompilationUnit
    <- PackageDeclaration? ImportDeclaration* TypeDeclaration* ;

PackageDeclaration
    <- PackageModifier* PACKAGE Identifier (DOT Identifier)* SEMI ;

PackageModifier
    <- Annotation ;

ImportDeclaration
    <- IMPORT STATIC? QualIdent (DOT STAR)? SEMI
    / SEMI
    ;

TypeDeclaration
    <- ClassDeclaration
    / InterfaceDeclaration
    / SEMI
    ;

ClassDeclaration
    <- NormalClassDeclaration
    / EnumDeclaration
    ;

NormalClassDeclaration
    <- ClassModifier* CLASS Identifier TypeParameters?
          Superclass? Superinterfaces? ClassBody
    ;

ClassModifier
    <- Annotation
    / PUBLIC
    / PROTECTED
    / PRIVATE
    / ABSTRACT
    / STATIC
    / FINAL
    / STRICTFP
    ;

TypeParameters
    <- LPOINT TypeParameterList RPOINT ;

TypeParameterList
    <- TypeParameter (COMMA TypeParameter)* ;

Superclass
    <- EXTENDS ClassType ;

Superinterfaces
    <- IMPLEMENTS InterfaceTypeList ;

InterfaceTypeList
    <- ClassType (COMMA ClassType)* ;

ClassBody
    <- LWING ClassBodyDeclaration* RWING ;

ClassBodyDeclaration
    <- ClassMemberDeclaration
    / InstanceInitializer
    / StaticInitializer
    / ConstructorDeclaration
    ;

ClassMemberDeclaration
    <- FieldDeclaration
    / MethodDeclaration
    / ClassDeclaration
    / InterfaceDeclaration
    / SEMI
    ;

FieldDeclaration
    <- FieldModifier* UnannType VariableDeclaratorList SEMI ;

VariableDeclaratorList
    <- VariableDeclarator (COMMA VariableDeclarator)* ;

VariableDeclarator
    <- VariableDeclaratorId (EQU VariableInitializer)? ;

VariableDeclaratorId
    <- Identifier Dim* ;

VariableInitializer
    <- Expression
    / ArrayInitializer
    ;

UnannClassType
    <- Identifier TypeArguments?
          (DOT Annotation* Identifier TypeArguments?)*  ;

UnannType
    <- BasicType Dim*
    / UnannClassType Dim*
    ;

FieldModifier
    <- Annotation
    / PUBLIC
    / PROTECTED
    / PRIVATE
    / STATIC
    / FINAL
    / TRANSIENT
    / VOLATILE
    ;

MethodDeclaration
    <- MethodModifier* MethodHeader MethodBody ;

MethodHeader
    <- Result MethodDeclarator Throws?
    / TypeParameters Annotation* Result MethodDeclarator Throws?
    ;

MethodDeclarator
    <- Identifier LPAR FormalParameterList? RPAR Dim* ;

FormalParameterList
    <- (ReceiverParameter / FormalParameter)(COMMA FormalParameter)* ;

FormalParameter
    <- VariableModifier* UnannType VariableDeclaratorId
    / VariableModifier* UnannType Annotation* ELLIPSIS VariableDeclaratorId !COMMA
    ;

VariableModifier
    <- Annotation
    / FINAL
    ;

ReceiverParameter
    <- VariableModifier* UnannType (Identifier DOT)? THIS ;

Result
    <- UnannType
    / VOID
    ;

MethodModifier
    <- Annotation
    / PUBLIC
    / PROTECTED
    / PRIVATE
    / ABSTRACT
    / STATIC
    / FINAL
    / SYNCHRONIZED
    / NATIVE
    / STRICTFP
    ;

Throws
    <- THROWS ExceptionTypeList ;

ExceptionTypeList
    <- ExceptionType (COMMA ExceptionType)* ;

ExceptionType
    <- ClassType
    / TypeVariable
    ;

MethodBody
    <- Block
    / SEMI
    ;

InstanceInitializer
    <- Block ;

StaticInitializer
    <- STATIC Block ;

ConstructorDeclaration
    <- ConstructorModifier* ConstructorDeclarator Throws? ConstructorBody ;

ConstructorDeclarator
    <- TypeParameters? Identifier LPAR FormalParameterList? RPAR ;

ConstructorModifier
    <- Annotation
    / PUBLIC
    / PROTECTED
    / PRIVATE
    ;

ConstructorBody
    <- LWING ExplicitConstructorInvocation? BlockStatements? RWING ;

ExplicitConstructorInvocation
    <- TypeArguments? THIS Arguments SEMI
    / TypeArguments? SUPER Arguments SEMI
    / Primary DOT TypeArguments? SUPER Arguments SEMI
    / QualIdent DOT TypeArguments? SUPER Arguments SEMI
    ;

EnumDeclaration
    <- ClassModifier* ENUM Identifier Superinterfaces? EnumBody ;

EnumBody
    <- LWING EnumConstantList? COMMA? EnumBodyDeclarations? RWING ;

EnumConstantList
    <- EnumConstant (COMMA EnumConstant)* ;

EnumConstant
    <- EnumConstantModifier* Identifier Arguments? ClassBody? ;

EnumConstantModifier
    <- Annotation ;

EnumBodyDeclarations
    <- SEMI ClassBodyDeclaration* ;

InterfaceDeclaration
    <- NormalInterfaceDeclaration
    / AnnotationTypeDeclaration
    ;

NormalInterfaceDeclaration
    <- InterfaceModifier* INTERFACE Identifier TypeParameters?
          ExtendsInterfaces? InterfaceBody ;

InterfaceModifier
    <- Annotation
    / PUBLIC
    / PROTECTED
    / PRIVATE
    / ABSTRACT
    / STATIC
    / STRICTFP
    ;

ExtendsInterfaces
    <- EXTENDS InterfaceTypeList ;

InterfaceBody
    <- LWING InterfaceMemberDeclaration* RWING ;

InterfaceMemberDeclaration
    <- ConstantDeclaration
    / InterfaceMethodDeclaration
    / ClassDeclaration
    / InterfaceDeclaration
    / SEMI
    ;

ConstantDeclaration
    <- ConstantModifier* UnannType VariableDeclaratorList SEMI ;

ConstantModifier
    <- Annotation
    / PUBLIC
    / STATIC
    / FINAL
    ;

InterfaceMethodDeclaration
    <- InterfaceMethodModifier* MethodHeader MethodBody ;

InterfaceMethodModifier
    <- Annotation
    / PUBLIC
    / ABSTRACT
    / DEFAULT
    / STATIC
    / STRICTFP
    ;

AnnotationTypeDeclaration
    <- InterfaceModifier* AT INTERFACE Identifier AnnotationTypeBody ;

AnnotationTypeBody
    <- LWING AnnotationTypeMemberDeclaration* RWING ;

AnnotationTypeMemberDeclaration
    <- AnnotationTypeElementDeclaration
    / ConstantDeclaration
    / ClassDeclaration
    / InterfaceDeclaration
    / SEMI
    ;

AnnotationTypeElementDeclaration
    <- AnnotationTypeElementModifier* UnannType Identifier LPAR RPAR Dim*
         DefaultValue? SEMI ;

AnnotationTypeElementModifier
    <- Annotation
    / PUBLIC
    / ABSTRACT
    ;

DefaultValue
    <- DEFAULT ElementValue ;

Annotation
    <- AT
      ( NormalAnnotation
      / SingleElementAnnotation
      / MarkerAnnotation
      )
    ;

NormalAnnotation
    <- QualIdent LPAR ElementValuePairList* RPAR ;

ElementValuePairList
    <- ElementValuePair (COMMA ElementValuePair)* ;

ElementValuePair
    <- Identifier EQU ElementValue ;

ElementValue
    <- ConditionalExpression
    / ElementValueArrayInitializer
    / Annotation
    ;

ElementValueArrayInitializer
    <- LWING ElementValueList? COMMA? RWING ;

ElementValueList
    <- ElementValue (COMMA ElementValue)* ;

MarkerAnnotation
    <- QualIdent ;

SingleElementAnnotation
    <- QualIdent LPAR ElementValue RPAR ;

ArrayInitializer
    <- LWING VariableInitializerList? COMMA? RWING ;

VariableInitializerList
    <- VariableInitializer (COMMA VariableInitializer)* ;
Block
    <- LWING BlockStatements? RWING ;

BlockStatements
    <- BlockStatement BlockStatement* ;

BlockStatement
    <- LocalVariableDeclarationStatement
    / ClassDeclaration
    / Statement
    ;

LocalVariableDeclarationStatement
    <- LocalVariableDeclaration SEMI ;

LocalVariableDeclaration
    <- VariableModifier* UnannType VariableDeclaratorList ;

Statement
    <- Block
    / IF ParExpression Statement (ELSE Statement)?
    / BasicForStatement
    / EnhancedForStatement
    / WHILE ParExpression Statement
    / DO Statement WHILE ParExpression SEMI
    / TryStatement
    / SWITCH ParExpression SwitchBlock
    / SYNCHRONIZED ParExpression Block
    / RETURN Expression? SEMI
    / THROW Expression SEMI
    / BREAK Identifier? SEMI
    / CONTINUE Identifier? SEMI
    / ASSERT Expression (COLON Expression)? SEMI
    / SEMI
    / StatementExpression SEMI
    / Identifier COLON Statement
    ;

StatementExpression
    <- Assignment
    / (INC / DEC)(Primary / QualIdent)
    / (Primary / QualIdent)(INC / DEC)
    / Primary
    ;

SwitchBlock
    <- LWING SwitchBlockStatementGroup* SwitchLabel* RWING ;

SwitchBlockStatementGroup
    <- SwitchLabels BlockStatements ;

SwitchLabels
    <- SwitchLabel SwitchLabel* ;

SwitchLabel
    <- CASE (ConstantExpression / EnumConstantName) COLON
    / DEFAULT COLON
    ;

EnumConstantName
    <- Identifier ;

BasicForStatement
    <- FOR LPAR ForInit? SEMI Expression? SEMI ForUpdate? RPAR Statement ;

ForInit
    <- LocalVariableDeclaration
    / StatementExpressionList
    ;

ForUpdate
    <- StatementExpressionList ;

StatementExpressionList
    <- StatementExpression (COMMA  StatementExpression)* ;

EnhancedForStatement
    <- FOR LPAR VariableModifier* UnannType VariableDeclaratorId COLON
          Expression RPAR Statement ;

TryStatement
    <- TRY
      ( Block (CatchClause* Finally / CatchClause+)
      / ResourceSpecification Block CatchClause* Finally?
      )
    ;

CatchClause
    <- CATCH LPAR CatchFormalParameter RPAR Block ;

CatchFormalParameter
    <- VariableModifier* CatchType VariableDeclaratorId ;

CatchType
    <- UnannClassType (OR ClassType)* ;

Finally
    <- FINALLY Block ;

ResourceSpecification
    <- LPAR ResourceList SEMI? RPAR ;

ResourceList
    <- Resource (SEMI Resource)* ;

Resource
    <- VariableModifier* UnannType VariableDeclaratorId EQU Expression ;

Expression
    <- LambdaExpression
    / AssignmentExpression
    ;

Primary
    <- PrimaryBase PrimaryRest* ;

PrimaryBase
    <- THIS
    / Literal
    / ParExpression
    / SUPER
      ( DOT TypeArguments? Identifier Arguments
      / DOT Identifier
      / COLONCOLON TypeArguments? Identifier
      )
    / NEW
      ( ClassCreator
      / ArrayCreator
      )
    / QualIdent
      ( LBRK Expression RBRK
      / Arguments
      / DOT
        ( THIS
        / NEW ClassCreator
        / TypeArguments Identifier Arguments
        / SUPER DOT TypeArguments? Identifier Arguments
        / SUPER DOT Identifier
        / SUPER COLONCOLON TypeArguments? Identifier
        )
      / (LBRK RBRK)* DOT CLASS
      / COLONCOLON TypeArguments? Identifier
      )
    / VOID DOT CLASS
    / BasicType (LBRK RBRK)* DOT CLASS
    / ReferenceType COLONCOLON TypeArguments? Identifier
    / ClassType COLONCOLON TypeArguments? NEW
    / ArrayType COLONCOLON NEW
    ;

PrimaryRest
    <- DOT
      ( TypeArguments? Identifier Arguments
      / Identifier
      / NEW ClassCreator
      )
    / LBRK Expression RBRK
    / COLONCOLON TypeArguments? Identifier
    ;

ParExpression
    <- LPAR Expression RPAR ;

ClassCreator
    <- TypeArguments? Annotation* ClassTypeWithDiamond
          Arguments ClassBody? ;

ClassTypeWithDiamond
    <- Annotation* Identifier TypeArgumentsOrDiamond?
          (DOT Annotation* Identifier TypeArgumentsOrDiamond?)* ;

TypeArgumentsOrDiamond
    <- TypeArguments
    / LPOINT RPOINT !DOT
    ;

ArrayCreator
    <- Type DimExpr+ Dim*
    / Type Dim+ ArrayInitializer
    ;

DimExpr
    <- Annotation* LBRK Expression RBRK ;


Arguments
    <- LPAR ArgumentList? RPAR ;

ArgumentList
    <- Expression (COMMA Expression)* ;

UnaryExpression
    <- (INC / DEC)(Primary / QualIdent)
    / PLUS UnaryExpression
    / MINUS UnaryExpression
    / UnaryExpressionNotPlusMinus
    ;

UnaryExpressionNotPlusMinus
    <- TILDE UnaryExpression
    / BANG UnaryExpression
    / CastExpression
    / (Primary / QualIdent) (INC / DEC)?
    ;

CastExpression
    <- LPAR PrimitiveType RPAR UnaryExpression
    / LPAR ReferenceType AdditionalBound* RPAR LambdaExpression
    / LPAR ReferenceType AdditionalBound* RPAR UnaryExpressionNotPlusMinus
    ;

InfixExpression
    <- UnaryExpression
          ((InfixOperator UnaryExpression) / (INSTANCEOF ReferenceType))* ;

InfixOperator
    <- OROR
    / ANDAND
    / OR
    / HAT
    / AND
    / EQUAL
    / NOTEQUAL
    / LT
    / GT
    / LE
    / GE
    / SL
    / SR
    / BSR
    / PLUS
    / MINUS
    / STAR
    / DIV
    / MOD
    ;

ConditionalExpression
    <- InfixExpression (QUERY Expression COLON Expression)* ;

AssignmentExpression
    <- Assignment
    / ConditionalExpression
    ;

Assignment
    <- LeftHandSide AssignmentOperator Expression ;

LeftHandSide
    <- Primary
    / QualIdent
    ;

AssignmentOperator
    <- EQU
    / STAREQU
    / DIVEQU
    / MODEQU
    / PLUSEQU
    / MINUSEQU
    / SLEQU
    / SREQU
    / BSREQU
    / ANDEQU
    / HATEQU
    / OREQU
    ;

LambdaExpression
    <- LambdaParameters ARROW LambdaBody ;

LambdaParameters
    <- Identifier
    / LPAR FormalParameterList? RPAR
    / LPAR InferredFormalParameterList RPAR
    ;

InferredFormalParameterList
    <- Identifier (COMMA Identifier)* ;

LambdaBody
    <- Expression
    / Block
    ;

ConstantExpression
    <- Expression ;
'
]

{ #category : 'support' }
PikaEndToEndTest >> javaTestSource [ 

"A Java file to test parsing, from the Pika Parser project"

^ '//
// This file is part of the pika parser reference implementation:
//
//     https://github.com/lukehutch/pikaparser
//
// The pika parsing algorithm is described in the following paper: 
//
//     Pika parsing: reformulating packrat parsing as a dynamic programming algorithm solves the left recursion
//     and error recovery problems. Luke A. D. Hutchison, May 2020.
//     https://arxiv.org/abs/2005.06444
//
// This software is provided under the MIT license:
//
// Copyright 2020 Luke A. D. Hutchison
//  
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
// and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions
// of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
// TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
package pikaparser.parser.utils;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import pikaparser.ast.LabeledClause;
import pikaparser.clause.Clause;
import pikaparser.clause.aux.RuleRef;
import pikaparser.clause.nonterminal.First;
import pikaparser.clause.terminal.Terminal;
import pikaparser.grammar.Rule;
import pikaparser.grammar.Rule.Associativity;

/** Grammar utils. */
public class GrammarUtils {
    /** Find reachable clauses, and bottom-up (postorder), find clauses that always match in every position. */
    private static void findTerminals(Clause clause, HashSet<Clause> visited, List<Clause> terminalsOut) {
        if (visited.add(clause)) {
            if (clause instanceof Terminal) {
                terminalsOut.add(clause);
            } else {
                for (var labeledSubClause : clause.labeledSubClauses) {
                    var subClause = labeledSubClause.clause;
                    findTerminals(subClause, visited, terminalsOut);
                }
            }
        }
    }

    /** Find reachable clauses, and bottom-up (postorder), find clauses that always match in every position. */
    private static void findReachableClauses(Clause clause, HashSet<Clause> visited, List<Clause> revTopoOrderOut) {
        if (visited.add(clause)) {
            for (var labeledSubClause : clause.labeledSubClauses) {
                var subClause = labeledSubClause.clause;
                findReachableClauses(subClause, visited, revTopoOrderOut);
            }
            revTopoOrderOut.add(clause);
        }
    }

    /** Find the {@link Clause} nodes that complete a cycle in the grammar. */
    private static void findCycleHeadClauses(Clause clause, Set<Clause> discovered, Set<Clause> finished,
            Set<Clause> cycleHeadClausesOut) {
        if (clause instanceof RuleRef) {
            throw new IllegalArgumentException(
                    "There should not be any " + RuleRef.class.getSimpleName() + " nodes left in grammar");
        }
        discovered.add(clause);
        for (var labeledSubClause : clause.labeledSubClauses) {
            var subClause = labeledSubClause.clause;
            if (discovered.contains(subClause)) {
                // Reached a cycle
                cycleHeadClausesOut.add(subClause);
            } else if (!finished.contains(subClause)) {
                findCycleHeadClauses(subClause, discovered, finished, cycleHeadClausesOut);
            }
        }
        discovered.remove(clause);
        finished.add(clause);
    }

    /** Topologically sort all clauses into bottom-up order, from terminals up to the toplevel clause. */
    public static List<Clause> findClauseTopoSortOrder(List<Rule> allRules, List<Clause> lowestPrecedenceClauses) {
        // Find toplevel clauses (clauses that are not a subclause of any other clause)
        var allClausesUnordered = new ArrayList<Clause>();
        var topLevelVisited = new HashSet<Clause>();
        for (var rule : allRules) {
            findReachableClauses(rule.labeledClause.clause, topLevelVisited, allClausesUnordered);
        }
        var topLevelClauses = new HashSet<>(allClausesUnordered);
        for (var clause : allClausesUnordered) {
            for (var labeledSubClause : clause.labeledSubClauses) {
                topLevelClauses.remove(labeledSubClause.clause);
            }
        }
        var topLevelClausesOrdered = new ArrayList<>(topLevelClauses);

        // Add to the end of the list of toplevel clauses all lowest-precedence clauses, since
        // top-down precedence climbing should start at each lowest-precedence clause
        topLevelClausesOrdered.addAll(lowestPrecedenceClauses);

        // Finally, in case there are cycles in the grammar that are not part of a precedence
        // hierarchy, add to the end of the list of toplevel clauses the set of all "head clauses"
        // of cycles (the set of all clauses reached twice in some path through the grammar)
        var cycleDiscovered = new HashSet<Clause>();
        var cycleFinished = new HashSet<Clause>();
        var cycleHeadClauses = new HashSet<Clause>();
        for (var clause : topLevelClauses) {
            findCycleHeadClauses(clause, cycleDiscovered, cycleFinished, cycleHeadClauses);
        }
        for (var rule : allRules) {
            findCycleHeadClauses(rule.labeledClause.clause, cycleDiscovered, cycleFinished, cycleHeadClauses);
        }
        topLevelClausesOrdered.addAll(cycleHeadClauses);

        // Topologically sort all clauses into bottom-up order, starting with terminals (so that terminals are
        // all grouped together at the beginning of the list)
        var terminalsVisited = new HashSet<Clause>();
        var terminals = new ArrayList<Clause>();
        for (var rule : allRules) {
            findTerminals(rule.labeledClause.clause, terminalsVisited, terminals);
        }
        var allClauses = new ArrayList<Clause>(terminals);
        var reachableVisited = new HashSet<Clause>();
        reachableVisited.addAll(terminals);
        for (var topLevelClause : topLevelClausesOrdered) {
            findReachableClauses(topLevelClause, reachableVisited, allClauses);
        }

        // Give each clause an index in the topological sort order, bottom-up
        for (int i = 0; i < allClauses.size(); i++) {
            allClauses.get(i).clauseIdx = i;
        }
        return allClauses;
    }

    // -------------------------------------------------------------------------------------------------------------

    /**
     * Check there are no cycles in the clauses of rules, before {@link RuleRef} instances are resolved to direct
     * references.
     */
    public static void checkNoRefCycles(Clause clause, String selfRefRuleName, Set<Clause> visited) {
        if (visited.add(clause)) {
            for (var labeledSubClause : clause.labeledSubClauses) {
                var subClause = labeledSubClause.clause;
                checkNoRefCycles(subClause, selfRefRuleName, visited);
            }
        } else {
            throw new IllegalArgumentException(
                    "Rules should not contain cycles when they are created: " + selfRefRuleName);
        }
        visited.remove(clause);
    }

    // -------------------------------------------------------------------------------------------------------------

    /** Count number of self-references among descendant clauses. */
    private static int countRuleSelfReferences(Clause clause, String ruleNameWithoutPrecedence) {
        if (clause instanceof RuleRef && ((RuleRef) clause).refdRuleName.equals(ruleNameWithoutPrecedence)) {
            return 1;
        } else {
            var numSelfRefs = 0;
            for (var labeledSubClause : clause.labeledSubClauses) {
                var subClause = labeledSubClause.clause;
                numSelfRefs += countRuleSelfReferences(subClause, ruleNameWithoutPrecedence);
            }
            return numSelfRefs;
        }
    }

    /** Rewrite self-references into precedence-climbing form. */
    private static int rewriteSelfReferences(Clause clause, Associativity associativity, int numSelfRefsSoFar,
            int numSelfRefs, String selfRefRuleName, String currPrecRuleName, String nextHighestPrecRuleName) {
        // Terminate recursion when all self-refs have been replaced
        if (numSelfRefsSoFar < numSelfRefs) {
            for (int i = 0; i < clause.labeledSubClauses.length; i++) {
                var labeledSubClause = clause.labeledSubClauses[i];
                var subClause = labeledSubClause.clause;
                if (subClause instanceof RuleRef) {
                    if (((RuleRef) subClause).refdRuleName.equals(selfRefRuleName)) {
                        if (numSelfRefs >= 2) {
                            // Change name of self-references to implement precedence climbing:
                            // For leftmost operand of left-recursive rule:
                            // E[i] <- E X E  =>  E[i] = E[i] X E[i+1]
                            // For rightmost operand of right-recursive rule:
                            // E[i] <- E X E  =>  E[i] = E[i+1] X E[i]
                            // For non-associative rule:
                            // E[i] = E E  =>  E[i] = E[i+1] E[i+1]
                            clause.labeledSubClauses[i].clause = new RuleRef( //
                                    (associativity == Associativity.LEFT && numSelfRefsSoFar == 0)
                                            || (associativity == Associativity.RIGHT
                                                    && numSelfRefsSoFar == numSelfRefs - 1) //
                                                            ? currPrecRuleName
                                                            : nextHighestPrecRuleName);
                        } else /* numSelfRefs == 1 */ {
                            // Move subclause (and its AST node label, if any) inside a First clause that
                            // climbs precedence to the next level:
                            // E[i] <- X E Y  =>  E[i] <- X (E[i] / E[(i+1)%N]) Y
                            ((RuleRef) subClause).refdRuleName = currPrecRuleName;
                            clause.labeledSubClauses[i].clause = new First(subClause,
                                    new RuleRef(nextHighestPrecRuleName));
                        }
                        numSelfRefsSoFar++;
                    }
                    // Else don''t rewrite the RuleRef, it is not a self-ref
                } else {
                    numSelfRefsSoFar = rewriteSelfReferences(subClause, associativity, numSelfRefsSoFar,
                            numSelfRefs, selfRefRuleName, currPrecRuleName, nextHighestPrecRuleName);
                }
            }
        }
        return numSelfRefsSoFar;
    }

    /** Rewrite self-references in a precedence hierarchy into precedence-climbing form. */
    public static void handlePrecedence(String ruleNameWithoutPrecedence, List<Rule> rules,
            ArrayList<Clause> lowestPrecedenceClauses,
            Map<String, String> ruleNameToLowestPrecedenceLevelRuleName) {
        // Rewrite rules
        // 
        // For all but the highest precedence level:
        //
        // E[0] <- E (Op E)+  =>  E[0] <- (E[1] (Op E[1])+) / E[1] 
        // E[0,L] <- E Op E   =>  E[0] <- (E[0] Op E[1]) / E[1] 
        // E[0,R] <- E Op E   =>  E[0] <- (E[1] Op E[0]) / E[1]
        // E[3] <- ''-'' E      =>  E[3] <- ''-'' (E[3] / E[4]) / E[4]
        //
        // For highest precedence level, next highest precedence wraps back to lowest precedence level:
        //
        // E[5] <- ''('' E '')''  =>  E[5] <- ''('' (E[5] / E[0]) '')''

        // Check there are no duplicate precedence levels
        var precedenceToRule = new TreeMap<Integer, Rule>();
        for (var rule : rules) {
            if (precedenceToRule.put(rule.precedence, rule) != null) {
                throw new IllegalArgumentException("Multiple rules with name " + ruleNameWithoutPrecedence
                        + (rule.precedence == -1 ? "" : " and precedence " + rule.precedence));
            }
        }
        // Get rules in ascending order of precedence
        var precedenceOrder = new ArrayList<>(precedenceToRule.values());

        // Rename rules to include precedence level
        var numPrecedenceLevels = rules.size();
        for (int precedenceIdx = 0; precedenceIdx < numPrecedenceLevels; precedenceIdx++) {
            // Since there is more than one precedence level, update rule name to include precedence
            var rule = precedenceOrder.get(precedenceIdx);
            rule.ruleName += "[" + rule.precedence + "]";
        }

        // Transform grammar rule to handle precence
        for (int precedenceIdx = 0; precedenceIdx < numPrecedenceLevels; precedenceIdx++) {
            var rule = precedenceOrder.get(precedenceIdx);

            // Count the number of self-reference operands
            var numSelfRefs = countRuleSelfReferences(rule.labeledClause.clause, ruleNameWithoutPrecedence);

            var currPrecRuleName = rule.ruleName;
            var nextHighestPrecRuleName = precedenceOrder.get((precedenceIdx + 1) % numPrecedenceLevels).ruleName;

            // If a rule has 2+ self-references, and rule is associative, need rewrite rule for associativity
            if (numSelfRefs >= 1) {
                // Rewrite self-references to higher precedence or left- and right-recursive forms.
                // (the toplevel clause of the rule, rule.labeledClause.clause, can''t be a self-reference,
                // since we already checked for that, and IllegalArgumentException would have been thrown.)
                rewriteSelfReferences(rule.labeledClause.clause, rule.associativity, 0, numSelfRefs,
                        ruleNameWithoutPrecedence, currPrecRuleName, nextHighestPrecRuleName);
            }

            // Defer to next highest level of precedence if the rule doesn''t match, except at the highest level of
            // precedence, which is assumed to be a precedence-breaking pattern (like parentheses), so should not
            // defer back to the lowest precedence level unless the pattern itself matches
            if (precedenceIdx < numPrecedenceLevels - 1) {
                // Move rule''s toplevel clause (and any AST node label it has) into the first subclause of
                // a First clause that fails over to the next highest precedence level
                var first = new First(rule.labeledClause.clause, new RuleRef(nextHighestPrecRuleName));
                // Move any AST node label down into first subclause of new First clause, so that label doesn''t
                // apply to the final failover rule reference
                first.labeledSubClauses[0].astNodeLabel = rule.labeledClause.astNodeLabel;
                rule.labeledClause.astNodeLabel = null;
                // Replace rule clause with new First clause
                rule.labeledClause.clause = first;
            }
        }

        // Map the bare rule name (without precedence suffix) to the lowest precedence level rule name
        var lowestPrecRule = precedenceOrder.get(0);
        lowestPrecedenceClauses.add(lowestPrecRule.labeledClause.clause);
        ruleNameToLowestPrecedenceLevelRuleName.put(ruleNameWithoutPrecedence, lowestPrecRule.ruleName);
    }

    // -------------------------------------------------------------------------------------------------------------

    /**
     * Recursively call toString() on the clause tree for this {@link Rule}, so that toString() values are cached
     * before {@link RuleRef} objects are replaced with direct references, and so that shared subclauses are only
     * matched once.
     */
    public static Clause intern(Clause clause, Map<String, Clause> toStringToClause) {
        // Call toString() on (and intern) subclauses, bottom-up
        for (int i = 0; i < clause.labeledSubClauses.length; i++) {
            clause.labeledSubClauses[i].clause = intern(clause.labeledSubClauses[i].clause, toStringToClause);
        }
        // Call toString after recursing to child nodes
        var toStr = clause.toString();

        // Intern the clause based on the toString value
        var prevInternedClause = toStringToClause.putIfAbsent(toStr, clause);

        // Return the previously-interned clause, if present, otherwise the clause, if it was just interned
        return prevInternedClause != null ? prevInternedClause : clause;
    }

    // -------------------------------------------------------------------------------------------------------------

    /** Resolve {@link RuleRef} clauses to a reference to the named rule. */
    public static void resolveRuleRefs(LabeledClause labeledClause, Map<String, Rule> ruleNameToRule,
            Map<String, String> ruleNameToLowestPrecedenceLevelRuleName, Set<Clause> visited) {
        if (labeledClause.clause instanceof RuleRef) {
            // Follow a chain of from name in RuleRef objects until a non-RuleRef is reached
            var currLabeledClause = labeledClause;
            var visitedClauses = new HashSet<Clause>();
            while (currLabeledClause.clause instanceof RuleRef) {
                if (!visitedClauses.add(currLabeledClause.clause)) {
                    throw new IllegalArgumentException(
                            "Reached toplevel RuleRef cycle: " + currLabeledClause.clause);
                }
                // Follow a chain of from name in RuleRef objects until a non-RuleRef is reached
                var refdRuleName = ((RuleRef) currLabeledClause.clause).refdRuleName;

                // Check if the rule is the reference to the lowest precedence rule of a precedence hierarchy
                var lowestPrecRuleName = ruleNameToLowestPrecedenceLevelRuleName.get(refdRuleName);

                // Look up Rule based on rule name
                var refdRule = ruleNameToRule.get(lowestPrecRuleName == null ? refdRuleName : lowestPrecRuleName);
                if (refdRule == null) {
                    throw new IllegalArgumentException("Unknown rule name: " + refdRuleName);
                }
                currLabeledClause = refdRule.labeledClause;
            }

            // Set current clause to a direct reference to the referenced rule
            labeledClause.clause = currLabeledClause.clause;

            // Copy across AST node label, if any
            if (labeledClause.astNodeLabel == null) {
                labeledClause.astNodeLabel = currLabeledClause.astNodeLabel;
            }
            // Stop recursing at RuleRef
        } else {
            if (visited.add(labeledClause.clause)) {
                var labeledSubClauses = labeledClause.clause.labeledSubClauses;
                for (var subClauseIdx = 0; subClauseIdx < labeledSubClauses.length; subClauseIdx++) {
                    var labeledSubClause = labeledSubClauses[subClauseIdx];
                    // Recurse through subclause tree if subclause was not a RuleRef 
                    resolveRuleRefs(labeledSubClause, ruleNameToRule, ruleNameToLowestPrecedenceLevelRuleName,
                            visited);
                }
            }
        }
    }
}
'
]

{ #category : 'tests' }
PikaEndToEndTest >> testArithmetic [

	| input memoTable allClauses firstClause matches firstMatch sixteenthMatch lastClause topLevelMatch firstSubclauseMatchOfLastMatch subClauseString |
	input := 'discriminant=b*b-4*a*c;'.
	memoTable := self arithmeticGrammar parse: input.

	"(PikaParserInfo
		 parseResultOfTopLevelRule: 'Program'
		 memoTable: memoTable
		 syntaxCoverageRuleNames: { 'Program'. 'Statement' }
		 showAllMatches: false) inspect."


	allClauses := memoTable grammar allClauses.
	self assert: allClauses size equals: 26.

	firstClause := allClauses first.
	matches := memoTable allMatchesForClause: firstClause.
	self assert: matches size equals: 16.

	firstMatch := matches first.
	self assert: firstMatch len equals: 1.
	self assert: firstMatch memoKey startPos equals: 1.
	self
		assert: firstMatch memoKey printStringWithRuleNames
		equals: '[a-z] : 1'.

	sixteenthMatch := matches last.
	self assert: sixteenthMatch len equals: 1.
	self assert: sixteenthMatch memoKey startPos equals: 22.
	self
		assert: sixteenthMatch memoKey printStringWithRuleNames
		equals: '[a-z] : 22'.

	lastClause := allClauses last.
	matches := memoTable allMatchesForClause: lastClause.

	topLevelMatch := matches first.
	self assert: topLevelMatch len equals: 23.
	self assert: topLevelMatch memoKey startPos equals: 1.
	self
		assert: topLevelMatch printStringWithRuleNames
		equals: '1+23 ''' , input , ''' : Program <- Statement+'.

	self assert: topLevelMatch subClauseMatches size equals: 1.

	firstSubclauseMatchOfLastMatch := topLevelMatch getSubClauseMatches
		                                  first.
	self assert: firstSubclauseMatchOfLastMatch key equals: nil.

	subClauseString := firstSubclauseMatchOfLastMatch value
		                   printStringWithRuleNames.
	self
		assert: subClauseString
		equals:
		'1+23 ''' , input , ''' : Statement <- var:[a-z]+ ''='' E '';'''
]

{ #category : 'tests' }
PikaEndToEndTest >> testJava [

	| input grammar memoTable topRuleName recoveryRuleNames syntaxErrors |
	grammar := self java1_8Grammar.
	input := self javaTestSource.
	memoTable := grammar parse: input.
	topRuleName := 'Compilation'.
	recoveryRuleNames := {
		                     topRuleName.
		                     'CompilationUnit' }.

	"Huge output; only do this if you have a big buffer.
	It also takes quite a while."
	"PikaParserInfo
		printParseResultOfTopLevelRule: topRuleName
		memoTable: memoTable
		syntaxCoverageRuleNames: recoveryRuleNames
		showAllMatches: false."

	syntaxErrors := memoTable syntaxErrorsForRuleNames: recoveryRuleNames.
	syntaxErrors ifNotEmpty: [
		PikaParserInfo printSyntaxErrors: syntaxErrors ].
	self assert: syntaxErrors isEmpty
]
