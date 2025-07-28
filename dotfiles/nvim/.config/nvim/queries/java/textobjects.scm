; extends

;; Capture the entire string (including quotes)
(string_literal) @quote.outer

;; Capture the inner content of the string (excluding quotes)
(string_fragment) @quote.inner
