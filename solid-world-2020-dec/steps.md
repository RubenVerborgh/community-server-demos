# Authenticated patches with live updates

In this demo, we will use two small apps
to demonstrate new functionality
of [version 0.3.0](https://www.npmjs.com/package/@solid/community-server/v/0.3.0)
of the [Solid Community Server](https://github.com/solid/community-server/).

The instructions below use the deployed server at https://css.verborgh.org/,
so substitute with your own server (for instance `http://localhost:3000/`).


## 1. Create an initial list document

```shell
curl -X PUT -H 'Content-Type: text/turtle' --data '' https://css.verborgh.org/list
```


## 2. Open the list viewer in a browser tab
The **[list viewer](https://rubenverborgh.github.io/solid-list-viewer/)**
([source code](https://github.com/RubenVerborgh/solid-list-viewer))
will display all labels in a given document.

Replace the `http://localhost:3000/list` with your document URL,
for instance `https://css.verborgh.org/list`.


## 3. Patch items into the list
The **[patching tool](https://rubenverborgh.github.io/solid-patch-tool/)**
([source code](https://github.com/RubenVerborgh/solid-patch-tool))
allows you to easily send `PATCH` requests to a document.

In the _Target_ field, put your document URL
(for instance `http://localhost:3000/list`).

When you insert a triple with a label,
you will see the list viewer update.

You can for example use this query:

```sparql
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
INSERT DATA {
  <http://example.org/#item> rdfs:label "My List Item"@en.
}
```

## 4. Log in to the patcher
By pressing the _Log in_ button,
you can log in with an existing WebID.

Remember its URL,
which will be listed when you return to the patcher.
For example:
https://ldp.demo-ess.inrupt.com/107856212222021978379/profile/card#me.


## 5. Limit access to your account
Use the patcher to send the following patch
to your root ACL document
(for instance: `https://css.verborgh.org/.acl`),
substituting your WebID in the agent URL.

```sparql
PREFIX  acl:  <http://www.w3.org/ns/auth/acl#>
PREFIX foaf:  <http://xmlns.com/foaf/0.1/>
INSERT DATA {
<https://css.verborgh.org/.acl#owner>
    a               acl:Authorization;
    acl:agent       <https://ldp.demo-ess.inrupt.com/107856212222021978379/profile/card#me>;
    acl:mode        acl:Read;
    acl:mode        acl:Write;
    acl:mode        acl:Append;
    acl:mode        acl:Delete;
    acl:mode        acl:Control;
    acl:accessTo    <https://css.verborgh.org/>;
    acl:default     <https://css.verborgh.org/>.
}
```

Now remove write permissions for non-authenticated agents:

```sparql
PREFIX  acl:  <http://www.w3.org/ns/auth/acl#>
PREFIX foaf:  <http://xmlns.com/foaf/0.1/>
DELETE DATA {
<https://css.verborgh.org/.acl#authorization>
    acl:mode        acl:Write;
    acl:mode        acl:Append;
    acl:mode        acl:Delete;
    acl:mode        acl:Control.
}
```

## 6. Retry patching items while logged in
Everyone should still be able to see the list update,
but only you can change it when logged into your account.
