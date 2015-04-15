---
title: First-Party-Only Cookies
abbrev: first-party-cookies
docname: draft-west-first-party-cookies-02
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
  HTML:
    target: https://html.spec.whatwg.org/
    title: HTML Living Standard
    author:
    -
      ins: I. Hickson
      name: Ian Hickson
      organization: Google, Inc.
  SERVICE-WORKERS:
    target: http://www.w3.org/TR/service-workers/
    title: Service Workers
    author:
    -
      ins: A. Russell
      name: Alex Russell
    -
      ins: J. Song
      name: Jungkee Song
    -
      ins: J. Archibald
      name: Jake Archibald
  WORKERS:
    target: http://www.w3.org/TR/workers/
    title: Web Workers
    author:
    -
      ins: I. Hickson
      name: Ian Hickson
  RFC2119:
  RFC4790:
  RFC5234:
  RFC6265:
  RFC6454:
  RFC7034:

informative:
  samedomain-cookies:
    target: http://people.mozilla.org/~mgoodwin/SameDomain/samedomain-latest.txt
    title: SameDomain Cookie Flag
    author:
    -
      ins: M. Goodwin
      name: Mark Goodwin
    -
      ins: J. Walker
      name: Joe Walker
    date: 2011
  pixel-perfect:
    target: http://www.contextis.com/documents/2/Browser_Timing_Attacks.pdf
    title: Pixel Perfect Timing Attacks with HTML5
    author:
    -
      ins: P. Stone
      name: Paul Stone
  app-isolation:
    target: http://www.collinjackson.com/research/papers/appisolation.pdf
    title: App Isolation - Get the Security of Multiple Browsers with Just One
    author:
    -
      ins: E. Chen
      name: Eric Y. Chen
    -
      ins: J. Bau
      name: Jason Bau
    -
      ins: C. Reis
      name: Charles Reis
    -
      ins: A. Barth
      name: Adam Barth
    -
      ins: C. Jackson
      name: Collin Jackson
  prerendering:
    target: https://www.chromium.org/developers/design-documents/prerender
    title: Chrome Prerendering
    author:
    -
      ins: C. Bentzel
      name: Chris Bentzel

--- abstract

This document updates RFC6265 by defining a `First-Party-Only` attribute which
allows servers to assert that a cookie ought to be sent only in a "first-party"
context. This assertion allows user agents to mitigate the risk of cross-origin
information leakage, and provides some minimal protection against cross-site
request forgery attacks.

--- middle

# Introduction

Section 8.2 of {{RFC6265}} eloquently notes that cookies are a form of ambient
authority, attached by default to requests the user agent sends on a user's
behalf. Even when an attacker doesn't know the contents of a user's cookies,
she can still execute commands on the user's behalf (and with the user's
authority) by asking the user agent to send HTTP requests to unwary servers.

Here, we update {{RFC6265}} with a simple mitigation strategy that allows
servers to declare certain cookies as "First-party-only", meaning they should be
attached to requests if and only if those requests occur in a first-party
context (as defined in section 2.1).

Note that the mechanism outlined here is backwards compatible with the existing
cookie syntax. Servers may serve first-party cookies to all user agents; those
that do not support the `First-Party-Only` attribute will simply store a cookie
which is returned in all applicable contexts, just as they do today.

## Goals

These first-party-only cookies are intended to provide a solid layer of
defense-in-depth against attacks which require embedding an authenticated
request into an attacker-controlled context:

1. Timing attacks which yield cross-origin information leakage (such as those
   detailed in {{pixel-perfect}}) can be substantially mitigated by setting
   the `First-Party-Only` attribute on authentication cookies. The attacker will
   only be able to embed unauthenticated resources, as embedding mechanisms such
   as `<iframe>` will not create first-party contexts.

2. Cross-site script inclusion (XSSI) attacks are likewise mitigated by setting
   the `First-Party-Only` attribute on authentication cookies. The attacker
   will not be able to include authenticated resources via `<script>` or
   `<link>`, as these embedding mechanisms will not create first-party contexts.

First-party-only cookies also mitigate one specific kind of cross-site request
forgery (CSRF) attack by treating cross-origin `POST` requests (including
navigations) as as third-party requests.

Aside from these attack mitigations, first-party-only cookies can also be useful
for policy or regulatory purposes. That is, it may be valuable for an origin to
assert that its cookies should not be sent along with third-party requests in
order to limit its exposure to non-technical risk.

## Limitations

First-party-only cookies provide limited defense against one kind of naïve
cross-site request forgery attack (CSRF). It does not offer a robust defense
against CSRF as a general category of attack:

1. Attackers can still pop up new windows or trigger top-level navigations in
   order to create a first-party context (as described in section 2.1), which is
   only a speedbump along the road to exploitation.

2. Features like `<link rel='prerender'>` {{prerendering}} can be exploited
   to create first-party contexts without the risk of user detection.

In addition to the usual server-side defenses (CSRF tokens, etc), client-side
techniques such as those described in {{app-isolation}} may prove effective
against CSRF, and are certainly worth exploring in combination with
first-party-only cookies. First-party-only cookies on their own, however, are
not a substantial barrier to CSRF attacks.

## Examples

First-party-only cookies are set via the `First-Party-Only` attribute in the
`Set-Cookie` header field. That is, given a server's response to a user agent
which contains the following header field:

    Set-Cookie: SID=31d4d96e407aad42; First-Party-Only

Subsequent requests from that user agent can be expected to contain the
following header field if and only if both the requested resource and the
resource in the top-level browsing context match the cookie.

# Terminology and notation

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be
interpreted as described in {{RFC2119}}.

This specification uses the Augmented Backus-Naur Form (ABNF) notation of
{{RFC5234}}.

Two sequences of octets are said to case-insensitively match each other if and
only if they are equivalent under the `i;ascii-casemap` collation defined in
{{RFC4790}}.

The terms "active document", "ancestor browsing context", "browsing context",
"document", "iframe srcdoc document", "parent browsing context", and "top-level
browsing context" are defined in the HTML Living Standard {{HTML}}.

"Web Workers", "dedicated workers", "owner document", "list of relevant
documents", and "shared workers" are defined in the Web Workers specification
{{WORKERS}}.

"Service Workers" are defined in the Service Workers specification
{{SERVICE-WORKERS}}.

The term "origin", the mechanism of deriving an origin from a URI, and the "the
same" matching algorithm for origins are defined in {{RFC6454}}.

## First-party and Third-party Requests  {#first-and-third-party}

### Document-based requests

When considering a request generated while parsing a document, or executing
script in its context, we need to consider the document's origin as well as
the origin of each of it's ancestors, in order to determine whether the
request should be considered "first-party".

For this kind of request, the URI displayed in a user agent's address bar is
the only security context directly exposed to users, and therefore the only
signal users can reasonably rely upon to determine whether or not they trust
a particular website. The origin of that URI is, therefore, the "first-party
origin".

In order to prevent the kinds of "multiple-nested scenarios" described in
Section 4 of {{RFC7034}}, we must check the first-party origin against the
origins of each of a document's ancestor browsing contexts' active documents.
A document is considered a "first-party context" if and only if the origin
of its URI is the same as the first-party origin, **and** if each of the
active documents in its ancestors' browsing contexts' is a first-party context.

This definition has a few implications:

*  New windows create new first-party contexts (as the active document is
   rendered into a top-level browsing context).

*  Full-page navigations create new first-party contexts. Notably, this
   includes both HTTP and `<meta>`-driven redirects.

*  `<iframe>`s do not create new first-party contexts; their requests MUST
   be considered in the context of the origin of the URL the user actually
   sees in the user agent's address bar.

To be more precise, given an HTTP request `request`, the following algorithm
returns `First-Party` if `request` is a first-party request, and `Third-Party`
otherwise:

1.  Let `document` be the document responsible for `request`.

2.  If `document` is a first-party context, and `request`'s URI's origin is
    the same as the origin of the URI of the active document in the top-level
    browsing context of `document`, then return `First-Party`.

3.  Return `Third-Party`.

Given a Document `document`, the following algorithm returns `First-Party` if
`document` is a first-party context, and `Third-Party` otherwise:

1.  Let `top-origin` be the origin of the URI of the active document in the
    top-level browsing context of the document responsible for `request`.

2.  If `document`'s URI's origin is not `top-origin`, return `Third-Party`.

3.  While `document` has a parent browsing context:

    1.  Let `document` be `document`'s parent browsing context's active
        document.

    2.  If `document`'s URI's origin is not `top-origin` and `document` is not
        an iframe srcdoc document, return `Third-Party`.

4.  Return `First-Party`.

Note that we deal with the document's location in steps 2, 3, and 4.2 above, not
with the document's origin. For example, a top-level document from
`https://example.com` which has been sandboxed into a unique origin still
creates a non-unique first-party context for subsequent requests.

### Worker-based requests

Worker-driven requests aren't as clear-cut as document-driven requests, as
there isn't a clear link between a top-level browsing context and a worker.
This is especially true for Service Workers {{SERVICE-WORKERS}}, which may
execute code in the background, without any document visible at all.

Note: The descriptions below assume that workers must be same-origin with
the documents that instantiate them. If this invariant changes, we'll need to
take the worker's script's URI into account when determining their status.

#### Dedicated Workers

Dedicated workers are fairly straightforward to categorize, as each dedicated
worker is bound to one and only one Document. Requests generated from a
dedicated worker (via `importScripts`, `XMLHttpRequest`, `fetch()`, and so on)
are first-party requests if and only if the worker's owner document is a
first-party context.

To be more precise, given an HTTP request `request`, the following algorithm
returns `First-Party` if `request` is a first-party request, and `Third-Party`
otherwise:

1.  Let `worker` be the dedicated worker responsible for `request`.

2.  Let `document` be `worker`'s owner document.

3.  If `document` is a first-party context, and `request`'s URI's origin is
    the same as the origin of the URI of the active document in the top-level
    browsing context of `document`, then return `First-Party`.

4.  Return `Third-Party`.

#### Shared Workers

Shared Workers introduce the complexity of bindings to multiple Documents. As
it is quite possible for a shared worker to be bound at the same time to one
Document that is a first-party context, and another that isn't, we'll need to
walk through all the documents associated with the worker to determine its
status. If and only if all associated documents are first-party contexts, then
the worker is a first-party context.

To be more precise, given an HTTP request `request`, the following algorithm
returns `First-Party` if `request` is a first-party request, and `Third-Party`
otherwise:

1.  Let `worker` be the dedicated worker responsible for `request`.

2.  For each `document` in `worker`'s list of relevant Documents:

    1. Return `Third-Party` if `document` is not a first-party context (as
       defined in section 2.1.1).

    2. Return `Third-Party` if `request`'s URI's origin is not the same as the
       origin of the URI of the active document in the top-level browsing
       context of `document`.

3.  Return `First-Party`.

#### Service Workers

Service Workers are more complex still, as they act as a completely separate
execution context, with very little relationship to the Document which
registered them.

Until we have more implementation experience, we will consider Service Workers
as third-party contexts in all cases.

Note: Requests which simply pass through a service worker will be handled as described
above; the only requests which will be effected by this categorization are those which
the service worker itself initiates (via `fetch()`, for instance).

# Server Requirements

This section describes extensions to {{RFC6265}} necessary to implement the
server-side requirements of the `First-Party-Only` attribute.

## Grammar

Add `First-Party-Only` to the list of accepted attributes in the `Set-Cookie`
header field's value by replacing the `cookie-av` token definition in Section
4.1.1 of {{RFC6265}} with the following ABNF grammar:

    cookie-av           = expires-av / max-age-av / domain-av /
                          path-av / secure-av / httponly-av /
                          first-party-only-av / extension-av
    first-party-only-av = "First-Party-Only"

## Semantics of the "First-Party-Only" Attribute (Non-Normative)

The "First-Party-Only" attribute limits the scope of the cookie such that it
will only be attached to requests if those requests are "first-party", as
described in {{first-and-third-party}}. For example, requests for
`https://example.com/sekrit-image` will attach first-party-only cookies if and
only if the top-level browsing context is currently displaying a document from
`https://example.com`.

The changes to the `Cookie` header field suggested in {{cookie-header}} provide
additional detail.

# User Agent Requirements

This section describes extensions to {{RFC6265}} necessary in order to implement
the client-side requirements of the `First-Party-Only` attribute.

## The "First-Party" attribute

The following attribute definition should be considered part of the the
`Set-Cookie` algorithm as described in Section 5.2 of {{RFC6265}}:

If the attribute-name case-insensitively matches the string "First-Party-Only",
the user agent MUST append an attribute to the `cookie-attribute-list` with an
`attribute-name` of "First-Party-Only" and an empty `attribute-value`.

## Monkey-patching the Storage Model

Note: There's got to be a better way to specify this. Until I figure out
what that is, monkey-patching!

Alter Section 5.3 of {{RFC6265}} as follows:

1.  Add `first-party-only-flag` to the list of fields stored for each cookie.

2.  Before step 11 of the current algorithm, add the following:

    11.  If the `cookie-attribute-list` contains an attribute with an
         `attribute-name` of "First-Party-Only", set the cookie's
         `first-party-only-flag` to true. Otherwise, set the cookie's
         `first-party-only-flag` to false.

    12.  If the cookie's `first-party-only-flag` is set to true, and the request
         which generated the cookie is not a first-party request (as defined
         in {{first-and-third-party}}), then abort these steps and ignore the
         newly created cookie entirely.

## Monkey-patching the "Cookie" header {#cookie-header}

Note: There's got to be a better way to specify this. Until I figure out
what that is, monkey-patching!

Alter Section 5.4 of {{RFC6265}} as follows:

1.  Add the following requirements to the list in step 1:

    * If the cookie's `first-party-only-flag` is true, then exclude the cookie
      if the HTTP request is a third-party request (see
      {{first-and-third-party}}).

    * If the cookie's `first-party-only-flag` is true, then exclude the cookie
      if the HTTP request's method is not `GET` and the origin of the document
      which originated the request is not the same as the origin of the HTTP
      request's URI.

Note that the modifications suggested here concern themselves only with the
origins of ancestor browsing contexts and the origin of the resource being
requested. The cookie's `domain`, `path`, and `secure` attributes do not come
into play for these comparisons.

# Authoring Considerations

## Mashups and Widgets

The `First-Party-Only` attribute is inappropriate for some important use-cases.
In particular, note that content intended for embedding in a third-party context
(social networking widgets or commenting services, for instance) will not have
access to first-party-only cookies. Non-first-party cookies may be required in
order to provide seamless functionality that relies on a user's state.

Likewise, some forms of Single-Sign On might require authentication in a
third-party context; these mechanisms will not function as intended with
first-party-only cookies.

# Privacy Considerations

First-party-only cookies in and of themselves don't do anything to address the
general privacy concerns outlined in Section 7.1 of {{RFC6265}}. The attribute
is set by the server, and serves to mitigate the risk of certain kinds of
attacks that the server is worried about. The user is not involved in this
decision. Moreover, a number of side-channels exist which could allow a server
to link distinct requests even in the absence of cookies. Connection and/or
socket pooling, Token Binding, and Channel ID all offer explicit methods of
identification that servers could take advantage of.

--- back

# Acknowledgements

The first-party cookie concept documented here is indebited to Mark Goodwin's
and Joe Walker's {{samedomain-cookies}}. Michal Zalewski, Artur Janc, and Ryan
Sleevi provided particularly valuable feedback on this document.
