---
title: Cookie Prefixes
abbrev: cookie-prefixes
docname: draft-west-cookie-prefixes-01
date: 2015
category: std
updates: 6265

ipr: trust200902
area: General
workgroup: HTTPbis
keyword: Internet-Draft

pi: [toc, tocindent, sortrefs, symrefs, strict, compact, comments, inline]

author:
-
  ins: M. West
  name: Mike West
  organization: Google, Inc
  email: mkwst@google.com
  uri: https://mikewest.org/

normative:
  RFC2119:
  RFC3986:
  RFC6265:

--- abstract

This document updates RFC6265 by adding a set of restrictions upon the names
which may be used for cookies with specific properties. These restrictions
enable user agents to smuggle cookie state to the server within the confines
of the existing `Cookie` request header syntax, and limits the ways in which
cookies may be abused in a conforming user agent.

--- middle

# Introduction

Section 8.5 and Section 8.6 of {{RFC6265}} spell out some of the drawbacks of
cookies' implementation: due to historical accident, it is impossible for a
server to have confidence that a cookie set in a secure way (e.g., as a
domain cookie with the `Secure` (and possibly `HttpOnly`) flags set) remains
intact and untouched by non-secure subdomains.

We can't alter the syntax of the `Cookie` request header, as that would likely
break a number of implementations. This rules out sending a cookie's flags along
with the cookie directly, but we can smuggle information along with the cookie
if we reserve certain name prefixes for cookies with certain properties.

This document describes such a scheme, which enables servers to set cookies
which conforming user agents will ensure are `Secure`, and locked to a domain.

# Terminology and notation

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be
interpreted as described in {{RFC2119}}.

The `scheme` component of a URI is defined in Section 3 of {{RFC3986}}.

# Prefixes

## The "$Secure-" prefix

If a cookie's name begins with "$Secure-", the cookie MUST be set with a
`Secure` attribute.

The following cookie would be rejected:

    Set-Cookie: $Secure-SID=12345; Domain=example.com

While the following would be accepted:

    Set-Cookie: $Secure-SID=12345; Secure; Domain=example.com

## The "$Origin-" prefix

If a cookie's name begins with "$Origin-", the cookie MUST be:

1.  Sent only to hosts which are identical to the host which set the cookie.
    That is, a cookie named "$Origin-cookie1" set from `https://example.com`
    MUST NOT contain a `Domain` attribute (and will therefore sent only to
    `example.com`, and not to `subdomain.example.com`).

2.  Sent to every request for a host. That is, a cookie named "$Origin-cookie1"
    MUST contain a `Path` attribute with a value of "/".

3.  Sent only to secure origins, if set from a secure origin. That is, a cookie
    named "$Origin-cookie1" set from `https://example.com` MUST contain a
    `Secure` attribute, as it was set from a URI whose `scheme` is considered
    "secure" by the user agent.

The following cookies would always be rejected:

    Set-Cookie: $Origin-SID=12345
    Set-Cookie: $Origin-SID=12345; Secure
    Set-Cookie: $Origin-SID=12345; Domain=example.com
    Set-Cookie: $Origin-SID=12345; Secure; Domain=example.com

The following would be rejected, if set from a secure origin, but accepted if
set from a non-secure origin:

    Set-Cookie: $Origin-SID=12345; Path=/

While the following would be accepted, if set from a secure origin:

    Set-Cookie: $Origin-SID=12345; Secure; Path=/

# User Agent Requirements

This document updates Section 5.3 of {{RFC6265}} as follows:

After step 10 of the current algorithm, the cookies flags are set. Insert the
following steps to perform the prefix checks this document specifies:

11. If the `cookie-name` begins with the string "$Origin-", then:

    1.  If the `scheme` component of the `request-uri` denotes a "secure"
        protocol (as determined by the user agent), and the cookie's
        `secure-only-flag` is `false`, abort these steps and ignore the cookie
        entirely.

    2.  If the cookie's `host-only-flag` is `false`, abort these steps and
        ignore the cookie entirely.

    3.  If the cookie's `path` is not "/", abort these steps and ignore the
        cookie entirely.

12. If the `cookie-name` begins with the string "$Secure-", and the cookie's
    `secure-only-flag` is `false`, abort these steps and ignore the cookie
    entirely.

# Aesthetic Considerations

Prefixes are ugly. :(

# Security Considerations

This scheme gives no assurance to the server that the restrictions on cookie
names are enforced. Servers could certainly probe the user agent's functionality
to determine support, or sniff based on the `User-Agent` request header, if
such assurances were deemed necessary.

--- back

# Acknowledgements

Eric Lawrence had this idea a million years ago. Devdatta Akhawe helped justify
the potential impact of the scheme on real-world websites.
