---
title: Increase Mortality Rate for Non-secure Origins' Cookies
abbrev: cookie-mortality-rate
docname: draft-west-cookie-mortality-rate-00
date: 2016
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
  SECURE-CONTEXTS:
    target: https://w3c.github.io/webappsec-secure-contexts/
    title: "Secure Contexts"
    author:
      ins: M. West
      name: Mike West
  RFC2119:
  RFC6265:
  RFC7258:

informative:
  POWERFUL-FEATURES:
    target: https://www.chromium.org/Home/chromium-security/prefer-secure-origins-for-powerful-new-features
    title: "Prefer Secure Origins for Powerful New Features"
    author:
      ins: C. Palmer
      name: Chris Palmer

  DEPRECATING-HTTP:
    target: https://blog.mozilla.org/security/2015/04/30/deprecating-non-secure-http/
    title: "Deprecating Non-Secure HTTP"
    author:
      ins: R. Barnes
      name: Richard Barnes

  NSA-COOKIES:
    target: https://www.washingtonpost.com/news/the-switch/wp/2013/12/10/nsa-uses-google-cookies-to-pinpoint-targets-for-hacking/
    title: "NSA uses Google cookies to pinpoint targets for hacking"
    author:
    -
      ins: A. Soltani
      name: Ashkan Soltani
    -
      ins: A. Peterson
      name: Andrea Peterson
    -
      ins: B. Gellman
      name: Barton Gellman

  Bugzilla1160368:
    target: https://bugzilla.mozilla.org/show_bug.cgi?id=1160368
    title: "Bug 1160368: Do not persist cookie without HTTPS 'secure' flag, i.e. treat HTTP cookies as session cookies."
    author:
      ins: C. Peterson
      name: Chris Peterson

--- abstract

This document updates RFC6265 with the goal of increasing the rate at which
cookies set from non-secure origins are evicted from the cookie store.

--- middle

# Introduction

Something something user agents, powerful features, and secure transport
(see {{SECURE-CONTEXTS}}, {{POWERFUL-FEATURES}}, and {{DEPRECATING-HTTP}}).

Something something NSA {{NSA-COOKIES}}.

Something something pervasive monitoring {{RFC7258}}.

## Example

Assume `http://example.com/` sends the following header in 2016 (attempting to
set a cookie which expires after a few years):

~~~
Set-Cookie: A=B; expires=Thu, 31-Dec-2020 01:01:01 GMT;
~~~

This header will result in the creation of a cookie named `A` that expires
either when the user agent determines that "the current session is over"
(see Section 5.3 of {{RFC6265}}), or after XXX has passed.

If `https://example.com/` had sent the same header, the cookie would be stored
with the desired expiration date (though the browser would still be free to
remove it earlier than that as discussed in Section 7.3 of {{RFC6265}}.

# Terminology and notation

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be
interpreted as described in {{RFC2119}}.

# Recommendations

This document updates Section 5.3 of {{RFC6265}} as follows:

1.  Add a new field to each cookie: `created-from-secure-context`.

2.  After step 9 of the current algorithm (which finishes setting the current
    cookie fields), execute the following steps:

    10. If the origin of 'request-uri' is not "potentially trustworthy"
        {{SECURE-CONTEXTS}}:

        1.  Set the cookie's `created-from-secure-context` flag to `false`.

        2.  Set the cookie's `persistent-flag` to `false`.
  
        3.  If the cookie's `expiry-time` is more than XXX in the future,
            set the cookie's `expiry-time` to the current date and time, plus
            XXX.

        Otherwise:

        1. Set the cookie's `created-from-secure-context` to `true`.

3.  Change the eviction order at the bottom of the section to ensure that
    cookies whose `created-from-secure-context` flag is `true` are evicted
    only after all cookies whose `created-from-secure-context` flag is
    `false`.

# Implementation Considerations

## Expiring Session Cookies

User agents may currently assume that it isn't possible to have both a
meaningful `expiry-time` and `persistent-flag` of `false`. Chrome, for
instance, toggles a cookie's `IsPersistent` property by checking that
`!expiry_date_.is_null()`. To implement the recommendations here, these flags
should be accessible independently.

--- back

# Acknowledgements

Mozilla's discussion (and, in particular, Chris Peterson's experimentation) at
{{Bugzilla1160368}} has been instrumental in informing this proposal.
