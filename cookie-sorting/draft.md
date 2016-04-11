---
title: Cookie Sorting
abbrev: cookie-sorting
docname: draft-west-cookie-sorting-00
date: 2016
category: std
updates: 6265

ipr: trust200902
area: General
workgroup: HTTPbis
keyword: Internet-Draft

pi: [toc, tocindent, sortrefs, symrefs, strict, compact, comments, inline]

author:
  ins: M. West
  name: Mike West
  organization: Google, Inc
  email: mkwst@google.com

normative:
  RFC2119:
  RFC6265:

informative:
  GitHub2013:
    target: https://github.com/blog/1466-yummy-cookies-across-domains
    title: "Yummy cookies across domains"
    author:
    -
      ins: V. Marti
      name: Vicent Marti

--- abstract

This document updates RFC6265 by redefining the expected order in which
cookies are listed in the `Cookie` header. The new sort order augments the
preference for the "most specific" cookie by taking cookie attributes into
account, giving servers not only the "most specific" but also the "most
authoritative" cookies first.

--- middle

# Introduction

In the beginning, there were two rules for cookie ordering in step 2 of
Section 5.4 of [RFC6265]:

> The user agent SHOULD sort the cookie-list in the following order:
>
> * Cookies with longer paths are listed before cookies with shorter paths.
>
> * Among cookies that have equal-length path fields, cookies with earlier
>   creation-times are listed before cookies with later creation-times.

The lax rules in this ordering are good for compatability, but we could
improve their security properties. For instance, we could make cookie
stuffing [GitHub2013] significantly less effective if we ensured that
the most specific, and most authoritaive cookies for a particular URI were
consistently listed before less reliable, less specific cookies.

Here, we treat cookies set by the root of a host as being more
authoritative than those set by leafs, and lay out a set of rules that
attempts to ensure that this ordering is clearly specified.

# Terminology and notation

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be
interpreted as described in {{RFC2119}}.

# Sorting

This document updates Section 5.4 of [RFC6265] by replacing step 2 of the
current `cookie-string` generation algorthm with the following:

## New Step 2

The user agent MUST sort `cookie-list` in decending order, according to the
following comparison algorithm which, given two cookies, `A` and B, returns
"greater" if `A` is greater than B, and "lesser" if B is greater than `A`.

NOTE: This algorithm produces a strict total ordering of `cookie-list` as
the requirements in Section 5.3 of [RFC6265] ensure that no two cookies can
be equal under the following rules.

1.  If `A`'s `domain` attribute is equal in length to `B`'s `domain`
    attribute:

    1.  If `A`'s `host-only-flag` is set, and `B`'s `host-only-flag` is not
        set, return "greater" (as these cookies could not be set by a subdomain,
        and are therefore more authoritative for the `request-host`).

    2.  If `A`'s `http-only-flag` is set, and `B`'s `http-only-flag` is
        not set, return "greater" (as these cookies can only be set
        by the server, not by XSS, and are therefore more authoritative
        for the `request-host`).

    3.  If `A`'s `path` attribute is equal in length to `B`'s `path`
        attribute:

        1.  If `A`'s `secure-only-flag` is set, and `B`'s `secure-only-flag`
            is not set, return "greater" (as secure cookies are unlikely
            to be the result of meddling middleboxes).

        2.  If `A`'s `creation-date` is prior to `B`'s `creation-date`,
            return "greater".

        3.  Return "lesser".

        Otherwise:

        1. Return "greater" if `A`'s `path` attribute is longer than
           `B`'s `domain` attribute.

           Otherwise return "lesser".

    Otherwise:

    1.  Return "greater" if `A`'s `domain` attribute is longer than
        `B`'s `domain` attribute.

        Otherwise, return "lesser".

# Authoring Considerations

It is entirely possible that this ordering is incompatible with the web.
In particular, applications may depend on existing ordering which
privileges both the most recently set cookies, and the cookies which have
the most specific path. Experimentation is required to determine whether
or not a change is at all possible.

--- back

# Acknowledgements

A conversation with Mark Goodwin initially inspired this draft. Mozilla's
experience with related changes around the time of RFC6265 has been helpful
in evaluating the potential impact of changes.
