; extends

;; matching props assignment in jsx
(jsx_attribute) @jsxa

;; expression inside jsx (e.g., inside curly braces)
(jsx_expression) @brackets.outer
(jsx_expression (_) @brackets.inner) 

(jsx_opening_element) @brackets.outer
((jsx_opening_element) @brackets.inner (#offset! @brackets.inner 0 1 0 -1))

(jsx_self_closing_element) @brackets.outer
((jsx_self_closing_element) @brackets.inner (#offset! @brackets.inner 0 1 0 -2))

(jsx_closing_element) @brackets.outer
(jsx_closing_element
  name: (member_expression) @brackets.inner)

;; ----------------------------------------
;; Select both opening and closing tags (excluding the <> and content)
; (jsx_element
;   open_tag: (jsx_opening_element
;     name: (identifier) @jsx_pair_tag)
;   close_tag: (jsx_closing_element
;     name: (identifier) @jsx_pair_tag)
; )

