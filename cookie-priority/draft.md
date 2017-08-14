---
title: A Retention Priority Attribute for HTTP Cookies
abbrev: cookie-priority
docname: draft-west-cookie-priority-01
date: 2017
category: std
updates: 6265

ipr: trust200902
area: General
workgroup: HTTPbis
keyword: Internet-Draft

pi: [toc, tocindent, sortrefs, symrefs, strict, compact, comments, inline]

author:
-
  ins: E. Wright
  name: Erik Wright
  organization: Shopify
-
  ins: S. Huang
  name: Samuel Huang
  organization: Google, Inc
  email: huangs@google.com
-
  ins: M. West
  name: Mike West
  organization: Google, Inc
  email: mkwst@google.com

normative:
  RFC2119:
  RFC4790:
  RFC5234:
  RFC6265:

informative:
  Wright2013:
    target: https://docs.google.com/a/google.com/file/d/0B3o1IlTKoADVRllKWGlyWGxIVTg/edit
    title: "A Retention Priority Attribute for HTTP Cookies"
    author:
    -
      ins: E. Wright
      name: Erik Wright
    -
      ins: S. Huang
      name: Samuel Huang

--- abstract

This document defines the `Priority` attribute for HTTP cookies.  This
attribute allows servers to specify a retention priority for HTTP
cookies that will be respected by user agents during cookie eviction.

--- middle

# Introduction

This document defines the `Priority` attribute for HTTP cookies. Using
the `Priority` attribute, servers may indicate that certain cookies
should be protected, and others preferentially deleted. When a user
agent evicts cookies in the enforcement of a per-domain quota, lower
priority cookies will be deleted first, potentially preserving
higher-priority cookies that would otherwise have been deleted
according to the rules of [RFC6265].

# Terminology and notation

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be
interpreted as described in {{RFC2119}}.

This specification uses the Augmented Backus-Naur Form (ABNF) notation of
{{RFC5234}}.

Two sequences of octets are said to case-insensitively match each other if and
only if they are equivalent under the `i;ascii-casemap` collation defined in
{{RFC4790}}.

# Overview

This section outlines a way for an origin server to indicate the
retention priority for individual cookies and for the user agent to
respect retention priorities during cookie eviction.

To indicate a cookie's retention priority, the origin server includes
a `Priority` attribute in the `Set-Cookie` HTTP response header. A value
of "Low" indicates that the cookie should be given lower retention
priority (evicted prior to other cookies). A value of "High" indicates
that a cookie should be given higher retention priority (evicted
after other cookies). The value of "Medium" corresponds to the default
behavior.

In order to prevent starvation of functionality dependent on low- and
medium-priority cookies, a fraction of the cookie quota should be
reserved for them.

{{RFC6265}}, Section 5.3, describes a strategy that user agents must
follow when "removing excess cookies". A user agent implementing the
current specification for a retention priority attribute will
implement an extended priority order, dividing the second priority
("Cookies that share a domain field with more than a predetermined
number of other cookies") into multiple levels corresponding to the
three retention priorities.

As a result, when the cookies for a given domain exceed user agent
limits, cookies with low priority will be evicted first, followed by
medium and high priority cookies.

## Examples

Using the Priority attribute, an origin server may assign a retention
priority to a cookie stored by a user agent. For example, the origin
server may prioritize the retention of session security tokens while
indicating that superficial data such as a user's favorite color
should be discarded in preference to other data.

The following figure illustrates a series of 33 cookies received by a
user-agent from the example.com server during one or more HTTP
responses.  Each cookie is represented by an L, M, or H indicating
low, medium, or high priority, respectively.

~~~
== Least Recently Accessed -> Most Recently Accessed ==

M L H H H H M H L L M M M M M M M L L L L L M M M M M H M M L L M
~~~

Assume that the user agent is configured to evict all but 25 cookies
from a domain when the number of cookies exceeds 31. {{RFC6265}}
specifies the following eviction order. Cookies are separated in the
vertical axis by priority.  Evicted cookies are labeled with a '1'
and retained cookies with an 'X'.

~~~
== Least Recently Accessed -> Most Recently Accessed ==

L    1             X X               X X X X X                 X X
M  1           1       X X X X X X X           X X X X X   X X     X
H      1 1 1 1   1                                       X
~~~

A user agent that implements the current specification, reserving
room for 5 low-, 15 medium-, and 5 high-priority cookies, would
implement a modified eviction order as follows. '1', '2', and '3'
indicate cookies evicted during various phases of the algorithm.

~~~
== Least Recently Accessed -> Most Recently Accessed ==

L    1             1 1               1 1 X X X                 X X
M  2           2       X X X X X X X           X X X X X   X X     X
H      3 X X X   X                                       X
~~~

Of note is that the retention priority does not impact the relative
eviction priority of cookies being evicted due to the global
threshold (i.e., once no domain exceeds the per-domain threshold).
Furthermore, this new attribute has no effect on domains that do not
send it.

# Server Requirements

This section describes the syntax and semantics of the `Priority`
cookie attribute.

## Syntax

The Set-Cookie HTTP response header syntax is defined in {{RFC6265}},
Section 4.1.1.  The grammar defined therein provides for tokens of
type 'extension-av'.  The Priority attribute is a subset of
'extension-av' that may appear zero or one times in a given 'set-
cookie-header'.  If it appears, the 'priority' attribute must conform
to the following grammar:

~~~
priority-av    = "Priority=" priority-value
priority-value = "Low" / "Medium" / "High"
~~~

## Semantics (Non-Normative)

This section describes a simplified semantics of the `Priority`
attribute in the `Set-Cookie` HTTP response header. The full semantics
are described in Section 5.

## The 'Priority' Attribute

The `Priority` attribute indicates a retention priority relative to
other cookies from the same domain as the cookie carrying the
attribute. During cookie eviction in enforcement of per-domain
cookie limits, `Low` priority cookies will be evicted before `Medium` and
`Medium` before `High`. Cookies without a specified priority are
considered to have `Medium` priority.

# User Agent Requirements

{{RFC6265}}, Section 5.2 describes how user agents must parse the value
of the `Set-Cookie` HTTP response header. This specification provides
additional processing steps that user agents must follow when they
encounter a `Priority` attribute.

`Set-Cookie` headers that do not specify the `Priority` attribute MUST be
treated as if the attribute was present and had the value Medium.

## The 'Priority' Attribute

If the `attribute-name` case-insensitively matches the string
"Priority", the user agent MUST process the `cookie-av` as follows:

1.  Let `priority-value` be "Medium".

2.  If the `attribute-value` case-insensitively matches the string "Low",
    set `priority-value` to "Low".

3.  If the `attribute-value` case-insensitively matches the string "High",
    set `priority-value` to "High".

4.  Append an attribute to the `cookie-attribute-list` with an `attribute-name`
    of "Priority", and an `attribute-value` of `priority-value`.

## Storage Model

{{RFC6265}}, Section 6.1 recommends that user agents set limits on the
number of cookies they will store. {{RFC6265}}, Section 5.3, describes
a strategy that user must follow when "removing excess cookies".

A user agent implementing the current specification for a retention
priority attribute will set aside a small portion of its storage
quota for low-priority cookies, and another portion for medium-
priority cookies. During eviction, compatible user agents will
implement an extended priority order, dividing the second priority
("Cookies that share a domain field with more than a predetermined
number of other cookies") into three, according to the retention
priorities and the space reserved for them. Assuming that no other
extensions ammend the rules defined in {{RFC6265}}, a compatible user
agent MUST therefore evict cookies in the following priority order (L
and M refer to the amount of space reserved for low- and medium-
priority cookies respectively, per domain).  As per {{RFC6265}}, within
each category the least-recently accessed cookies should be deleted
first.

1.  Expired cookies.

2.  Cookies with a low retention priority that share a domain field
    with more than a predetermined number of other cookies, excluding
    the first L low-priority cookies from that domain.

3.  Cookies with a low or medium retention priority that share a
    domain field with more than a predetermined number of other
    cookies, excluding the first L + M low- and medium-priority
    cookies from that domain.

4.  Cookies that share a domain field with more than a predetermined
    number of other cookies.

5.  All cookies.

# Implementation Considerations

This specification extends {{RFC6265}} in order to enable improved
behaviour when servers are unable or unwilling to keep the number of
distinct cookies served by their domains within the limits of user
agents. As this specification is unlikely to ever achieve universal
adoption by user agents, servers SHOULD gracefully degrade if their
specifed cookie retention priorities are not respected.

--- back

# Acknowledgements

This document is based heavily on an earlier draft written by Erik Wright and
Samuel Huang {{Wright2013}}, and the experimentation done in cooperation with
Google's login team.
