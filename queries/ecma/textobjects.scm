; extends

;; Capture the entire string (including quotes)
(string) @quote.outer
(template_string) @quote.outer

;; Capture the inner content of the string (excluding quotes)
(string_fragment) @quote.inner
((template_string) @quote.inner (#offset! @quote.inner 0 1 0 -1))

;; ----------------------------------------
;; Textobject for blocks surrounded by {}
;; Match blocks (e.g., function bodies, loops, conditionals)
(statement_block) @brackets.outer
((statement_block) @brackets.inner (#offset! @brackets.inner 0 1 0 -1))

;; Match import blocks
(named_imports) @brackets.outer
(named_imports
  (_) @brackets.inner)

;; Match destructuring object
(object_pattern) @brackets.outer
((object_pattern) @brackets.inner (#offset! @brackets.inner 0 1 0 -1))

;; Match destructuring array
(array_pattern) @brackets.outer
((array_pattern) @brackets.inner (#offset! @brackets.inner 0 1 0 -1))

;; Match object literals
(object) @brackets.outer
((object) @brackets.inner (#offset! @brackets.inner 0 1 0 -1))

;; Match array literals
(array) @brackets.outer
((array) @brackets.inner (#offset! @brackets.inner 0 1 0 -1))
 
;; ----------------------------------------
;; Textobject for parenthesized expressions ()
(parenthesized_expression) @brackets.outer
(parenthesized_expression
  (_) @brackets.inner)

;; arguments of function call: example(arguments)
(arguments) @brackets.outer
((arguments) @brackets.inner (#offset! @brackets.inner 0 1 0 -1))

;; similar to argument but for function definitions
(formal_parameters) @brackets.outer
((formal_parameters) @brackets.inner (#offset! @brackets.inner 0 1 0 -1))

