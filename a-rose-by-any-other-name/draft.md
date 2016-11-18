---
title: Let 'localhost' be localhost.
abbrev: let-localhost-be-localhost
docname: draft-west-let-localhost-be-localhost-04
date: 2016
category: std
updates: 6761

ipr: trust200902
area: General
workgroup: DNSOP
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
  RFC5156:
  RFC5735:
  RFC6761:

informative:
  RFC3397:
  draft-ietf-sunset4-gapanalysis:
    target: http://tools.ietf.org/html/draft-ietf-sunset4-gapanalysis
    title: "Gap Analysis for IPv4 Sunset"
    author:
    -
      ins: S. Perreault
      name: Simon Perreault
      organization: Jive Communications
    -
      ins: T. Tsou
      name: Tina Tsou
      organization: Huawei Technologies (USA)
    -
      ins: C. Zhou
      name: Cathy Zhou
      organization: Huawei Technologies
    -
      ins: P. Fan
      name: Peng Fan
      organization: China Mobile
  SECURE-CONTEXTS:
    target: http://w3c.github.io/webappsec-secure-contexts/
    title: "Secure Contexts"
    author:
    -
      ins: M. West
      name: Mike West
      organization: Google, Inc

--- abstract

This document updates RFC6761 by requiring that the domain "localhost." and any
names falling within ".localhost." resolve to loopback addresses. This would
allow other specifications to join regular users in drawing the common-sense
conclusions that "localhost" means "localhost", and doesn't resolve to somewhere
else on the network.

--- middle

# Introduction

Section 6.3 of {{RFC6761}} invites developers to "assume that IPv4 and IPv6
address queries for localhost names will always resolve to the respective
IP loopback address". That suggestion, unfortunately, doesn't match reality.
Client software is empowered to send localhost names to DNS resolvers, and
resolvers are empowered to return unexpected results in various cases. This
has several impacts.

One of the clearest is that the {{SECURE-CONTEXTS}} specification declines
to treat `localhost` as "secure enough", as it might not actually be the
`localhost` that developers are expecting. This exclusion has (rightly)
surprised some developers.

Following on from that, the lack of confidence that `localhost` actually
resolves to the loopback interface may encourage application developers to
hard-code IP addresses, which causes problems in the transition from IPv4
to IPv6 (see problem 8 in {{draft-ietf-sunset4-gapanalysis}}).
{{SECURE-CONTEXTS}} excluding `localhost` would exacerbate this risk, giving
developers positive encouragement to use the loopback address rather than a
localhost name.

This document suggests that we should resolve the confusion by requiring that
DNS resolution work the way that users expect: `localhost` is the loopback
interface on the local host. Resolver APIs will resolve `localhost.` and any
names falling within `.localhost.` to loopback addresses {{RFC5735}}

# Terminology and notation

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be
interpreted as described in {{RFC2119}}.

IPv4 loopback addresses are defined in Section 2.1 of {{RFC5735}} as
`127.0.0.0/8`.

IPv6 loopback addresses are defined in Section 3 of {{RFC5156}} as `::1/128`.

# Recommendations

This document updates Section 6.3 of {{RFC6761}} in the following ways:

1.  Item #3 is changed to read as follows:

    Name resolution APIs and libraries MUST recognize localhost names as
    special, and MUST always return an IP loopback address for address queries
    and negative responses for all other query types. Name resolution APIs MUST
    NOT send queries for localhost names to their configured caching DNS
    server(s).

    Note that any loopback address is acceptable: `subdomain.localhost` could
    resolve to `127.0.0.1`, `127.0.0.2`, `127.127.127.127`, etc.

2.  Item #4 is changed to read as follows:

    Caching DNS servers MUST recognize localhost names as special, and MUST NOT
    attempt to look up NS records for them, or otherwise query authoritative DNS
    servers in an attempt to resolve localhost names. Instead, caching DNS
    servers MUST generate an immediate negative response.

3.  Item #5 is changed to replace "SHOULD" with "MUST":

    Authoritative DNS servers MUST recognize localhost names as special and
    handle them as described above for caching DNS servers.

4.  Item #7 is changed to remove "probably" from the last sentence:

    DNS Registries/Registrars MUST NOT grant requests to register localhost
    names in the normal way to any person or entity. Localhost names are
    defined by protocol specification and fall outside the set of names
    available for allocation by registries/registrars. Attempting to allocate a
    localhost name as if it were a normal DNS domain name will not work as
    desired, for reasons 2, 3, 4, and 5 above.

5.  Item #8 is added to the list, reading as follows:

    Name resolution APIs, libraries, and application software MUST NOT use a
    searchlist to resolve a localhost name. That is, even if DHCP's domain
    search option {{RFC3397}} is used to specify a searchlist of `example.com`
    for a given network, the name `localhost` will not be resolved as
    `localhost.example.com`, and `subdomain.localhost` will not be resolved as
    `subdomain.localhost.example.com`.

# Implementation Considerations

## Non-DNS usage of localhost names

Some application software differentiates between the hostname `localhost` and
the IP address `127.0.0.1`. MySQL, for example, uses a unix domain socket for
the former, and a TCP connection to the loopback address for the latter. The
constraints on name resolution APIs above do not preclude this kind of
differentiation.

--- back

# Acknowledgements

Ryan Sleevi and Emily Stark informed me about the strange state of localhost
name resolution. Erik Nygren poked me to take another look at the set of
decisions we made in {{SECURE-CONTEXTS}} around `localhost.`; this document is
the result, and his feedback has been very helpful.
