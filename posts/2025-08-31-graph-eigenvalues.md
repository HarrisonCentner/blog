----
title: Eigenvalues of Special Graphs
modified: 2025-08-31
meta_description: "This post is to test my MathJax/Typst integration."
tags: Combinatorics
prerequisites: Combinatorics (counting principles), Linear Algebra (eigenvalues)
----

This post is to test my `MathJax`/`Typst` integration.  `MathJax` expects
`LaTeX`. I prefer `Typst`. `Pandoc` stores math expressions as raw text, so 
I walk a function $f : "Typst" -> "LaTeX"$ over the `Pandoc` AST 
then do the remaining compiler passes.


This post is not meant to be informative, interesting, or readable.

## Eigenvalues of a Chain Graph

Let $G$ be the $n$-cycle with one edge removed.
This graph is not regular.
\[ A eq.def A(G) = mat( delim: "[",
    0, 1, , ; \
    1, 0, 1, ;\
     , 1, 0, 1;\
     ,  , , dots.down;\
   )
\]

The eigenvalues of $A_n$ are $2 dot.c cos( frac(pi k, n+1))$.


The characteristic polynomial of $A_n$ is
$T_n(t) = det (t I_n - A_n)$.
It turns out this determinant is
closely related to Chebyshev Polynomials.

<!--more-->

Consider a more general determinant (of Toeplitz Matrices)
\[ h_n (a,b) =
mat( delim: "[",
a+b, -a b, , ; \
-1, a+b, -a b, ;\
    , -1, a+b, -a b;\
    ,  , , dots.down;\
).
\]
Exploring small values we see that
\[
h_1(a,b) &= a+ b \
h_2(a,b) &= a^2 + a b + b^2\
h_3(a,b) &= (a+b)^3 - 2a b (a+b)\
        &= a^3 + a^2 b + a  b^2 + b^3.
\]
This suggests the pattern that
\[ h_n(a,b) = sum_(k=0)^n a^(n-k) b^k =
frac(a^(n+1) - b^(n+1), a-b). \]
We will use a recurrence to prove
this formula. We expand the determinant in the last row
\[ h_n (a,b) =(a+b) h_(n-1) (a,b) - a b dot.c h_(n-2)(a,b). \]

The proof follows from induction on $n$.
All that must be done is to plug the formula into the recurrence and
check that it holds. This trick of expanding the determinant into
a recurrence is common for (tri)-diagonal matrices.

Now set $b := frac(1,a)$. Then

\[ T_n (a+a^(-1)) = h_n (a, a^(-1)) = frac(a^(n+1) - a^(-(n+1)), a -a^(-1)). \]
This vanishes when $a^(2(n+1)) = 1$ but $a^2 eq.not 1$.
That is, 
\[a = e^(frac(2 pi i k, 2(n+1))) = e^(frac(pi i k, n+1)).\]
for $k in [n]$ since $1$ and $n+1$ are forbidden by our vanishing rules.
Summing \[ t = a + a^(-1) = 2 dot.op cos( frac(pi k, n+1)).\]
