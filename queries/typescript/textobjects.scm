; extends

;; --------------------TYPESCRIPT--------------------
(object_type) @brackets.outer
((object_type) @brackets.inner (#offset! @brackets.inner 0 1 0 -1))

(tuple_type) @brackets.outer
((tuple_type) @brackets.inner (#offset! @brackets.inner 0 1 0 -1))

;; ----------------------------------------
;; Textobject for angle brackets (e.g., type parameters in TypeScript)
(type_parameters) @brackets.outer
((type_parameters) @brackets.inner (#offset! @brackets.inner 0 1 0 -1))

(type_arguments) @brackets.outer
((type_arguments) @brackets.inner (#offset! @brackets.inner 0 1 0 -1))

