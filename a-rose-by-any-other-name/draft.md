---
title: Let 'localhost' be localhost.
abbrev: let-localhost-be-localhost
docname: draft-west-let-localhost-be-localhost-02
date: 2016
category: std
updates: 6761

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
  RFC5156:
  RFC5735:
  RFC6761:

informative:
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

This document suggests that we should resolve the confusion by requiring that
DNS resolution work the way that users expect: `localhost` is `localhost`, and
not something other than loopback. Resolver APIs will resolve `.localhost.` to
loopback addresses {{RFC5735}}

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
    available for allocation by registries/registrars.  Attempting to allocate a
    localhost name as if it were a normal DNS domain name will not work as
    desired, for reasons 2, 3, 4, and 5 above.

# Implementation Considerations

This change would make developers sad if they map domain names like
'server1.localhost' to something other than a loopback address. There are
likely other situations in which it might create unexpected behaviors.

--- back

# Acknowledgements

Ryan Sleevi and Emily Stark informed me about the strange state of 'localhost'
resolution. Erik Nygren poked me to take another look at the set of decisions
we made in {{SECURE-CONTEXTS}} around `localhost.`; this document is the result.
