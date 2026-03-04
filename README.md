# Flex Automata and Grammar Parser

A lexical analyzer built with **Flex** and **C++** designed to parse and validate definitions of
Finite Automata and Grammars from input files. The tool identifies structural components,
determines types (deterministic/non-deterministic for automata),
and handles both local and global variables.

## Features

* **Automata Parsing**: Extracts the name, input alphabet, state set, initial state,
final states, and transition functions.
* **Grammar Analysis**: Identifies non-terminals, terminals, start symbols, and production rules.
* **Chomsky Hierarchy Classification**: Automatically determines if a grammar is Type 0 (GFR),
Type 1 (GDC), Type 2 (GIC), or Type 3 (GR) based on its production rules.
* **Variable Management**: Supports global and local variables that define sets of symbols (domains)
to simplify transition and production definitions.
* **Comment Handling**: Supports both single-line (`%`) and multi-line (`/* ... */`) comments, ensuring
they are ignored during parsing.

## Logic and Implementation

### State Machine Architecture
The project utilizes Flex exclusive start conditions to manage different parsing contexts:
* **INITIAL**: The entry point used to detect global variable declarations, automata headers or grammar headers.
* **AUTOMAT / GRAMATICA**: Contexts for parsing the internal definitions of these structures.
* **VARIABLE / LOCAL_VARIABLE**: Handles the definition of symbol domains.
* **TRANZITIE / REGULA**: Specific states for parsing the "right-hand side" of transitions or production rules.
* **IN_SINGLE_COMMENT / IN_MULTIPLE_COMMENT**: States used to ignore text within comment blocks.



### Automata Logic
The parser identifies whether an automaton is a **Finite Automaton (FA)** and distinguishes between types:
* **Deterministic (DFA)**: Verified if there is a single transition for each state-symbol pair.
* **Non-deterministic (NFA)**: Triggered by the presence of epsilon transitions (`e`) or
multiple transitions from the same state with the same input symbol.
Variables used in transitions are expanded internally to verify all resulting transitions against these rules.


### Grammar Classification Logic
The grammar type is determined by applying the most restrictive classification possible:
* **GR (Regular)**: Right-hand sides must follow regular grammar constraints (at most one non-terminal).
* **GIC (Context-Free)**: The left-hand side contains a single non-terminal.
* **GDC (Context-Sensitive)**: The number of symbols on the left side of a rule is less
than or equal to those on the right.
* **GFR (Unrestricted)**: The default classification for any grammar that does not meet
the criteria of the types above.



### Variable Scoping
Variables can be defined globally (visible to all subsequent structures) or locally
(visible only within a specific automaton or grammar). Global variables are
processed and displayed before the structures that use them.

## Installation and Usage

### Prerequisites
* Flex (Fast Lexical Analyzer Generator)
* G++ Compiler

### Setup
1. Generate the lexical analyzer and compile:
   ```
   make build
   ```

2. Run the parser with input files:
    ```
    ./parser 1 input_file.txt
    ```


## Controls and Input Format

 - Variables: 
    ```
    variable name ::= { values };
    ```

 - Automata:
    ```
    name ::= FiniteAutomaton ( ... ) ;;
    ```
 
 - Grammars: 
    ```
    name ::= Grammar ( ... ) ;;
    ```

