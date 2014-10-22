---
title: Origin Cookies
abbrev: Origin-Cookies
docname: draft-west-origin-cookies-00
date: 2014
category: std
updates: 6265

stand_alone: yes
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
  RFC4790:
  RFC5234:
  RFC6265:
  RFC6454:

informative:
  RFC3864:
  draft-abarth-cake-01:
    target: https://tools.ietf.org/html/draft-abarth-cake-01
    title: Origin Cookies
    author:
     -
       ins: A. Barth
       name: Adam Barth
    date: 2011-09-06
  origin-cookies-w2sp:
    target: http://w2spconf.com/2011/papers/session-integrity.pdf
    title: "Origin Cookies: Session Integrity for Web Applications"
    author:
    -
      ins: A. Bortz,
      name: Andrew Bortz
    -
      ins: A. Barth
      name: Adam Barth
    -
      ins: A. Czeskis
      name: Alexei Czeskis
    date: 2011

--- abstract

This document updates RFC6265, defining the `origin` attribute for cookies
and the `Origin-Cookie` header field, which together allow servers to choose
to harmonize the security policy of their cookies with the same-origin policy
which governs other available client-side storage mechanisms.

--- middle

# Introduction

Cookies, as defined by {{RFC6265}}, diverge from the web's general security
policy in a number of ways which may be surprising to implementers and authors
who haven't carefully read that document's discussion of "domain matching", and
"path matching", or who ignored the admonitions regarding "Weak Confidentiality"
and "Weak Integrity".

This document updates {{RFC6265}}, describing a mechanism by which servers can
opt-in to harmonizing cookies' security policy with the same-origin policy, as
described in {{RFC6454}}. User agents that support these "origin cookies" will
ignore a `Set-Cookie` header's value's `Path`, `Domain`, and `Secure`
attributes if an `Origin` attribute is present, instead tying the cookie to the
origin that set it. These "origin cookies" will be returned in a new
`Origin-Cookie` header field (see {{origin-cookie-header-field}} for detail),
separating them from non-origin cookies in a way a server can easily
distinguish.

Harmonizing with the same-origin policy mitigates the confidentiality and
integrity risks noted above by ensuring that origin cookies are not influenced
by malicious code running on a server's subdomain or a non-standard port or
scheme.

Note that the mechanism outlined here is backwards compatible with the existing
cookie syntax. Servers may serve origin cookies to all user agents; those that
do not support the "Origin" attribute will simply store a non-origin cookie,
just as they do today.

## Examples

Origin cookies are set via the `Origin` attribute in the `Set-Cookie` header
field. That is, given a server's response to a user agent which contains the
following header field:

    Set-Cookie: SID=31d4d96e407aad42; Origin

Subsequent requests from that user agent can be expected to contain the
following header field:

    Origin-Cookie: SID=31d4d96e407aad42

Non-origin cookies are returned in the `Cookie` header field as usual. If both
non-origin and origin cookies are present for an origin, then both a `Cookie`
and `Origin-Cookie` header field will be present. That is, given a server's
response to a user agent which contains the following header fields:

    Set-Cookie: SID=31d4d96e407aad42; Origin
    Set-Cookie: lang=en-US; Path=/; Domain=example.com

Subsequent requests from that user agent can be expected to contain the
following header fields:

    Cookie: lang=en-US
    Origin-Cookie: SID=31d4d96e407aad42

# Terminology and notation

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be
interpreted as described in {{RFC2119}}.

This specification uses the Augmented Backus-Naur Form (ABNF) notation of
{{RFC5234}}.

Two sequences of octets are said to case-insensitively match each other if and
only if they are equivalent under the `i;ascii-casemap` collation defined in
{{RFC4790}}.

# User Agent Requirements

This section describes extensions to {{RFC6265}} necessary in order to implement
the client-side requirements of the `Origin` attribute and `Origin-Cookie`
header field.

## Grammar

Replace the `cookie-av` token definition in {{RFC6265}} with the following ABNF
grammar:

    cookie-av         = expires-av / max-age-av / domain-av /
                        path-av / secure-av / httponly-av /
                        origin-av / extension-av
    origin-av         = "Origin"

## The "Origin" attribute

The following attribute definition should be considered part of the the
`Set-Cookie` algorithm as described in Section 5.2 of {{RFC6265}}:

If the attribute-name case-insensitively matches the string "Origin", the
user agent MUST append an attribute to the cookie-attribute-list with an
attribute-name of `Origin` and an empty attribute-value.

## Monkey-patching the Storage Model

Note: There's got to be a better way to specify this. Until I figure out
what that is, monkey-patching!

Alter Section 5.3 of {{RFC6265}} as follows:

1.  Add `origin` and `origin-flag` to the list of fields stored about each
    cookie.

2.  Before step 11 of the current algorithm, add the following:

    11. If the `cookie-attribute-list` contains an attribute with an
        `attribute-name` of "Origin":

        1.  Set the cookie's `domain` attribute to the empty string.
        2.  Set the cookie's `http-only-flag` to true.
        3.  Set the cookie's `host-only-flag` to true.
        4.  Set the cookie's `origin` to the origin of `request-uri`, as
            defined by Section 4 of {{RFC6454}}.
        5.  Set the cookie's `origin-flag` to true.
        6.  Set the cookie's `path` attribute to the empty string.
        7.  Set the cookie's `secure-only-flag` to false.

        Otherwise: set the cookie's `origin-flag` to false, and its `origin`
        to `null`.

    12. If the newly created cookie's `origin-flag` is set to true, and the
        cookie store contains a cookie with the same`name`, `origin`, and
        `origin-flag` as the newly created cookie:

        1.  Let `old-cookie` be the existing cookie with the same
            `name`, `origin`, and `origin-flag` as the newly created cookie.
        2.  Update the `creation-time` of the newly created cookie to match the
            `creation-time` of `old-cookie`.
        3.  Remove `old-cookie` from the cookie store.

3.  Change the priority order for excess cookie removal to the following:

    1. Expired cookies.
    2.  Cookies whose `origin-flag` is false that share a `domain` field with
        more than a predetermined number of other cookies.
    3.  Cookies whose `origin-flag` is true that share a  `domain` field with
        more than a predetermined number of other cookies.
    4.  Cookies whose `origin-flag` is false.
    5.  All cookies.

## Monkey-patching the "Cookie" header

Note: There's got to be a better way to specify this. Until I figure out
what that is, monkey-patching!

Alter Section 5.4 of {{RFC6265}} as follows:

1. Add the following requirement to the list in step 1:

   * The cookie's `origin-flag` is false.

## The "Origin-Cookie" header field     {#origin-cookie-header-field}

The user agent includes stored cookies whose `origin-flag` is set in the
`Origin-Cookie` request header. When the user agent generates an HTTP request,
it MUST NOT attach more than one `Origin-Cookie` header field.

A user agent MAY omit the `Origin-Cookie` header in its entirety. For example,
the user agent may wish to block sending cookies during "third-party" requests.

If the user agent does attach an `Origin-Cookie` header field to an HTTP
request, the user agent MUST send the `cookie-string` as defined below as the
value of the header field.

The user agent MUST use an algorithm equivalent to the following algorithm to
compute the `cookie-string` from a cookie store and a `request-uri`:

1.  Let `cookie-list` be the set of cookies from the cookie store that meets all
    the following requirements:

    *   The cookie's `origin-flag` is true.
    *   The cookie's `origin` matches the origin of `request-uri`. {{RFC6454}}
    *   The `cookie-string` is not being generated for a "non-HTTP" API (as
        defined by the user agent).

2.  The user agent SHOULD sort the `cookie-list` in the following order:

    *   Cookies with earlier `creation-time`s are listed before cookies with
        later `creation-time`s.

3.  Update the `last-access-time` of each cookie in the `cookie-list` to the
    current date and time.

4.  Serialize the `cookie-list` into a `cookie-string` by processing each cookie
    in the `cookie-list` in order:

    1.  Output the cookie's `name`, the %x3D ("=") character, and the cookie's
        `value`.

    2.  If there is an unprocessed cookie in the `cookie-list`, output the
        characters %x3B and %x20 ("; ").

# Security Considerations

The security considerations listed in Section 8 of {{RFC6265}} apply equally
to origin cookies, with the exceptions of Sections 8.6 ("Weak
Confidentiality") and Sections 8.7 ("Weak Isolation"), both of which are
substantially improved if the `Origin` attribute is set. Further:

## "HttpOnly"

Note that origin cookies are only accessible via HTTP. "Non-HTTP" APIs like
HTML's `document.cookie` cannot read these cookies' values.

## Paths are ignored

Origin cookies will break the (flawed) `Path`-based isolation strategy which
some servers may be attempting to implement. If a server has used the `Path`
attribute to limit cookies to specific areas of a site (say `/admin`), then
they may be surprised by origin cookies' pathless behavior.

That said, paths offer little to no protection against malicious code. The
origin is the only security boundry enforced rigorously by user agents; it is
therefore the only security boundry that server operators ought to rely on for
isolation.

# IANA Considerations

The permanent message header field registry (see {{RFC3864}}) shall be updated
with the following registration:

## Origin-Cookie

- Header field name: Origin-Cookie
- Applicable protocol: http
- Status: standard
- Author/Change controller: IETF
- Specification document: This specification (see {{origin-cookie-header-field}})

# Acknowledgements

The origin cookie concept documented here is heavily indebted to and based upon
Adam Barth's {{draft-abarth-cake-01}} document, as well as Andrew Bortz, Adam
Barth, and Alexei Czeskis' paper {{origin-cookies-w2sp}}.

--- back

#  Open Issues

*   Should origin cookies be settable via `document.cookie`? Does that weaken
    the guarantees in any way we care about?
