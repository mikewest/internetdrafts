---
title: Non-HTTP Cookies
docname: draft-west-nonhttp-cookies-00
date: 2017
category: std
updates: 6265

ipr: trust200902
area: General
workgroup: HTTPbis
keyword: Internet-Draft

stand_alone: yes
pi: [toc, tocindent, sortrefs, symrefs, strict, comments, inline]

author:
-
  ins: M. West
  name: Mike West
  organization: Google, Inc
  email: mkwst@google.com
  uri: https://mikewest.org/

normative:
  RFC2119:
  RFC6265:


--- abstract

This document updates RFC6265 by defining a `NonHttp` attribute which ensures
that a given cookie is available only to "non-HTTP" APIs. Yes, it is a little
strange for "HTTP State Management" to support exclusively non-HTTP use cases,
but the internet is a strange place. So it goes.

--- middle

# Introduction

Cookies violate the same-origin policy in well-understood ways, outlined in
Sections 8.5 and 8.6 of {{RFC6265}}. For better or worse, developers rely on
this behavior in a number of ways. In particular, it is quite common for
developers to use cookies as a cross-origin storage mechanism, allowing state
to be shared across all origins in a given registrable domain. A user who
signs into `https://m.example.com/` might expect to also be signed into
`https://www.example.com/`, and vice-versa. Servers can support this expectation
by setting a cookie at the apex domain: `uid=1234567;Secure;Domain=example.com`.
The cookie will be sent along with HTTP requests to both origins, and the user's
state can be maintained.

Often, though, the fact that a cookie is sent over the wire is an unindended
side-effect. Developers may simply desire the ability to easily share
client-side state between related origins, and have pressed cookies into this
service.

For example, web analytics packages might use a user agent's `document.cookie`
API to set first-party cookies on a client's site that retain a user's state.
This gives them the information they need to do analytics work, but has the very
unfortunate side-effect of sending those cookies along with first-party HTTP
requests to the client's server. This has a substantially negative impact on
request size (and therefore performance), but also has privacy implications, as
these cookies are often sent in plaintext over the network.

This document aims to reduce both impacts by allowing developers to specify
specific cookies as `NonHttp`. These cookies cannot be modified via `Set-Cookie`
HTTP response headers, nor will they be included in `Cookie` HTTP request
headers. They are only accessible via "non-HTTP" APIs.

## Examples

Non-HTTP cookies are only accessible via "non-HTTP" APIs. For example, a
developer might use HTML's `document.cookie` to set a non-HTTP cookie as
follows:

    document.cookie = "name=value; Secure; NonHttp";

That cookie would be available via subsequent calls to `document.cookie`, but
will not be included in HTTP requests to the developer's server.

# Terminology and notation

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be
interpreted as described in {{RFC2119}}.

# Recommendations

This section describes extensions to {{RFC6265}} necessary to implement the
`NonHttp` attribute.

1.  Extend the `cookie-av` grammar in Section 4.1.1 of {{RFC6265}} as follows:

    ~~~ abnf
    cookie-av      = expires-av / max-age-av / domain-av /
                     path-av / secure-av / httponly-av /
                     nohttp-av / extension-av
    nohttp-av      = "NoHttp"
    ~~~

2.  Add a section to Section 4.1.2 of {{RFC6265}} describing the semantics of
    the `NonHttp` attribute as follows:

    The `NonHttp` attribute limits the scope of the cookie to "non-HTTP" APIs.
    That is, the attribute instructs the user agent to omit the cookie when
    constructing a `Cookie` header for an HTTP request.

    If both the `NonHttp` and `HttpOnly` attributes are present when setting a
    cookie, the cookie will be ignored, regardless of its delivery mechanism.

3.  Alter the storage model defined in Section 5.3 of {{RFC6265}} as follows:

    1.  Add `no-http-flag` as a field to be stored on each cookie.

    2.  Insert the following two steps after the current step 10:

        11. If the `cookie-attribute-list` contains an attribute with an
            `attribute-name` of "NoHttp", set the cookie's `no-http-flag` to
            `true`. Otherwise, set the cookie's `no-http-flag` to `false`.

        12. If the cookie was not received from a "non-HTTP" API, and the
            cookie's `no-http-flag` is `true`, abort these steps and ignore
            the cookie entirely.

    3.  Insert the following step after the current step 11.2:

        3.  If the newly created cookie was not received from a "non-HTTP" API,
            and the `old-cookie`'s `no-http-flag` is `true`, abort these steps
            and ignore the newly created cookie entirely.

4.  Add a section to Section 5.2 of {{RFC6265}} describing the processing 
    requirements for the `NonHttp` attribute as follows:

    If the `attribute-name` case-insensitively matches the string "NonHttp",
    the user agent MUST append an attribute to the `cookie-attribute-list` with
    an `attribute-name` of `NonHttp` and an empty `attribute-value`.

5.  Alter the `Cookie` header generation in Section 5.4 of {{RFC6265}} as
    follows:

    1.  Add the following requirement to the list of requirements in the current
        step 1:

        *   If the cookie's `no-http-flag` is `true`, then exclude the cookie if
            the `cookie-string` is not being generated for a "non-HTTP" API (as
            defined by the user agent).

# Security and Privacy Considerations

There's a risk that allowing developers to suppress cookies from HTTP requests
might lead to increased usage of cookies as a cross-origin storage mechanism.
Given existing usage, however, the worst case seems to be an increase from a
high number to a marginally higher number.

## Fewer Cookies on the Wire

Non-HTTP cookies are never sent directly by the user agent over the network,
which reduces their exposure to both active and passive network attackers. It
seems reasonable to expect that adoption of the `NonHttp` attribute by popular
analytics packages could result in a substantial reduction in the usefulness of
those packages' cookies when attempting to correlate a given user's activities
over time and across networks.

--- back

# Acknowledgements

Michael Nordman suggested this approach during a conversation about cross-origin
storage mechanisms. Brad Townsend helped me understand the potential positive
impact on traffic levels for analytics customers.
