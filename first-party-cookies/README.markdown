SameSite Cookies
===================

We can mitigate the risk of CSRF attacks by sending cookies only if they
would have been sent for the active document in the top-level browsing
context.

This is similar to, but not the same as, Mark Goodwin's `SameDomain`
concept: http://people.mozilla.org/~mgoodwin/SameDomain/. That's worth
reading and considering as well.
