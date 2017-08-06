---
title: Let 'localhost' be localhost.
abbrev: let-localhost-be-localhost
docname: draft-west-let-localhost-be-localhost-05
date: 2017
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
  RFC1537:
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

The `127.0.0.0/8` IPv4 address block and `::1/128` IPv6 address block are
reserved as loopback addresses. Traffic to this block is assured to remain
within a single host, and can not legitimately appear on any network
anywhere. This turns out to be a very useful property in a number of
circumstances; useful enough to label explicitly and interoperably as
`localhost`. {{RFC1537}} suggests that this special-use top-level domain name
has been implicitly mapped to loopback addresses for decades at this point, and
that {{RFC6761}}'s assertion that developers may "assume that IPv4 and IPv6
address queries for localhost names will always resolve to the respective
IP loopback address" is well-founded.

Unfortunately, the rest of that latter document's requirements undercut the
assumption it suggests. Client software is empowered to send localhost names to
DNS servers, and resolvers are empowered to return unexpectedly non-loopback
results. This divide between theory and practice has a few impacts:

First, the lack of confidence that `localhost` actually resolves to the loopback
interface encourages application developers to hard-code IP addresses like
`127.0.0.1` in order to obtain certainty regarding routing. This causes problems
in the transition from IPv4 to IPv6 (see problem 8 in
{{draft-ietf-sunset4-gapanalysis}}).

Second, HTTP user agents sometimes distinguish certain contexts as
"secure"-enough to make certain features available. Given the certainty that
`127.0.0.1` cannot be maliciously manipulated or monitored, {{SECURE-CONTEXTS}}
treats it as such a context. Since `localhost` might not actually map to the
loopback address, that document declines to give it the same treatment. This
exclusion has (rightly) surprised some developers, and exacerbates the risks
of hard-coded IP addresses by giving developers positive encouragement to use
an explicit loopback address rather than a localhost name.

This document hardens {{RFC6761}}'s recommendations regarding `localhost` by
requiring that DNS resolution work the way that users assume: `localhost` is the
loopback interface on the local host. Resolver APIs will resolve `localhost.` and
any names falling within `.localhost.` to loopback addresses, and traffic to
those hosts will never traverse a remote network.

# Terminology and notation

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be
interpreted as described in {{RFC2119}}.

IPv4 loopback addresses are defined in Section 2.1 of {{RFC5735}} as
`127.0.0.0/8`.

IPv6 loopback addresses are defined in Section 3 of {{RFC5156}} as `::1/128`.

# The "localhost." Special-Use Domain Name

The domain `localhost.`, and any names falling within `.localhost.`, are known
as "localhost names". Localhost names are special in the following ways:

1.  Users are free to use localhost names as they would any other domain names.
    Users may assume that IPv4 and IPv6 address queries for localhost names will
    always resolve to the respective IP loopback address.

2.  Application software MAY recognize localhost names as special, or MAY pass
    them to name resolution APIs as they would for other domain names.

    Application software MUST NOT use a searchlist to resolve a localhost name.
    That is, even if DHCP's domain search option {{RFC3397}} is used to specify
    a searchlist of `example.com` for a given network, the name `localhost` will
    not be resolved as `localhost.example.com`, and `subdomain.localhost` will
    not be resolved as `subdomain.localhost.example.com`.

3.  Name resolution APIs and libraries MUST recognize localhost names as
    special, and MUST always return an appropriate IP loopback address for
    IPv4 and IPv6 address queries and negative responses for all other query
    types. Name resolution APIs MUST NOT send queries for localhost names to
    their configured caching DNS server(s).
    
    Name resolution APIs and libraries MUST NOT use a searchlist to resolve a
    localhost name.

4.  Caching DNS servers MUST respond to queries for localhost names with
    NXDOMAIN.

5.  Authoritative DNS servers MUST respond to queries for localhost names with
    NXDOMAIN.

6.  DNS server operators SHOULD be aware that the effective RDATA for localhost
    names is defined by protocol specification and cannot be modified by local
    configuration.

7.  DNS Registries/Registrars MUST NOT grant requests to register localhost
    names in the normal way to any person or entity. Localhost names are
    defined by protocol specification and fall outside the set of names
    available for allocation by registries/registrars. Attempting to allocate a
    localhost name as if it were a normal DNS domain name will not work as
    desired, for reasons 2, 3, 4, and 5 above.

# IANA Considerations

IANA is requested to update the `localhost.` registration in the registry of
Special-Use Domain Names {{RFC6761}} to reference this document.

# Implementation Considerations

## Security Decisions

If application software wishes to make security decisions based upon the fact
that localhost names resolve to loopback addresses (e.g. if it wishes to ensure
that a context meets the requirements laid out in {{SECURE-CONTEXTS}}), then it
SHOULD avoid relying upon name resolution APIs, instead performing the
resolution itself. If it chooses to rely on name resolution APIs, it MUST verify
that the resulting IP address is a loopback address before making a decision
about its security properties.

## Non-DNS usage of localhost names

Some application software differentiates between the hostname `localhost` and
the IP address `127.0.0.1`. MySQL, for example, uses a unix domain socket for
the former, and a TCP connection to the loopback address for the latter. The
constraints on name resolution APIs above do not preclude this kind of
differentiation.

--- back

# Changes from RFC 6761

Section 3 of this document updates the requirements in section 6.3 of
{{RFC6761}} in a few substantive ways:

1.  Application software and name resolution APIs and libraries are prohibited
    from using searchlists when resolving localhost names.

2.  Name resolution APIs and libraries are required to resolve localhost names
    to loopback addresses, without sending the query on to caching DNS servers.

3.  Caching and authoritative DNS servers are required to respond to resolution
    requests for localhost names with NXDOMAIN.

# Acknowledgements

Ryan Sleevi and Emily Stark informed me about the strange state of localhost
name resolution. Erik Nygren poked me to take another look at the set of
decisions we made in {{SECURE-CONTEXTS}} around `localhost.`; this document is
the result, and his feedback has been very helpful.
