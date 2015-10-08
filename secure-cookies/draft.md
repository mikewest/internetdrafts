---
title: Deprecate modification of 'secure' cookies from non-secure origins
abbrev: leave-secure-cookies-alone
docname: draft-west-leave-secure-cookies-alone-01
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

informative:
  COOKIE-INTEGRITY:
    target: https://www.usenix.org/system/files/conference/usenixsecurity15/sec15-paper-zheng.pdf
    title: "Cookies Lack Integrity: Real-World Implications"
    author:
    -
      ins: X. Zheng
      name: Xiaofeng Zheng
      organization: Tsinghua University and Tsinghua National Laboratory for Information Science and Technology
    -
      ins: J. Jiang
      name: Jian Jiang
      organization: University of California, Berkeley
    -
      ins: J. Liang
      name: Jinjin Liang
      organization: Tsinghua University and Tsinghua National Laboratory for Information Science and Technology;
    -
      ins: H. Duan
      name: Haixin Duan
      organization: Tsinghua University, Tsinghua National Laboratory for Information Science and Technology, and International Computer Science Institute;
    -
      ins: S. Chen
      name: Shuo Chen
      organization: Microsoft Research Redmond;
    -
      ins: T. Wan
      name: Tao Wan
      organization: Huawei Canada
    -
      ins: N. Weaver
      name: Nicholas Weaver
      organization: International Computer Science Institute and University of California, Berkeley
  RFC6797:

--- abstract

This document updates RFC6265 by removing the ability for a non-secure origin
to set cookies with a 'secure' flag, and to overwrite cookies whose 'secure'
flag is set. This deprecation improves the isolation between HTTP and HTTPS
origins, and reduces the risk of malicious interference.

--- middle

# Introduction

Section 8.5 and Section 8.6 of {{RFC6265}} spell out some of the drawbacks of
cookies' implementation: due to historical accident, non-secure origins can set
cookies which will be delivered to secure origins in a manner indistinguishable
from cookies set by that origin itself. This enables a number of attacks, which
have been recently spelled out in some detail in {{COOKIE-INTEGRITY}}.

We can mitigate the risk of these attacks by making it more difficult for
non-secure origins to influence the state of secure origins. Accordingly, this
document recommends the deprecation and removal of non-secure origins' ability
to write cookies with a 'secure' flag, and their ability to overwrite cookies
whose 'secure' flag is set.

# Terminology and notation

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be
interpreted as described in {{RFC2119}}.

The `scheme` component of a URI is defined in Section 3 of {{RFC3986}}.

# Recommendations

This document updates Section 5.3 of {{RFC6265}} as follows:

1.  After step 8 of the current algorithm, which sets the cookie's
    `secure-only-flag`, execute the following step:

    9.  If the `scheme` component of the `request-uri` does not denote a
        "secure" protocol (as defined by the user agent), and the cookie's
        `secure-only-flag` is `true`, then abort these steps and ignore the
        newly created cookie entirely.

2.  Before step 3 of step 11 of the current algorithm, execute the following
    step:

    3.  If the `scheme` component of the `request-uri` does not denote a
        "secure" protocol (as defined by the user agent), and the
        `old-cookie`'s `secure-only-flag` is set, then abort these steps and
        ignore the newly create cookie entirely.

# Security Considerations

This specification increases a site's confidence that secure cookies it sets
will remain unmodified by insecure pages on hosts which it domain-matches.
Ideally, sites would use HSTS as described in {{RFC6797}} to defend more
robustly against the dangers of non-secure transport in general, but until
adoption of that protection becomes ubiquitous, this deprecation this document
recommends will mitigate a number of risks.

--- back

# Acknowledgements

Richard Barnes encouraged a formalization of the deprecation proposal.
{{COOKIE-INTEGRITY}} was a useful exploration of the issues {{RFC6265}}
described.
