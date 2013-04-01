xprocspec - XProc testing tool
==============================

This is an experimental tool for testing XProc scripts. It is based on [XSpec](https://code.google.com/p/xspec/) and is implemented in XProc.

Feel free to have a look at the code and give feedback, but note that it is not yet working.

# Draft specification

## x:description
The x:description element must be the root element of an XProcSpec document. It describes one or more test scenarios for an XProc step or a library of XProc steps.

### Required attributes:
script: the URI to the XProc script.

### Optional attributes:
common-attributes
version: version string to aid development over time.
preserve-space: TODO

### Contents:
One or more of the following in any order:
x:import
x:scenario
x:pending

## x:import
An import brings in all the scenarios from the referenced file (which must itself be an XProcSpec description document). All the unshared scenarios in that imported XProcSpec will be run on the XProc script that this XProcSpec document describes. Importing is recursive and may be circular (although only one copy of a given imported document will actually be imported).

### Required attributes:
href: URI to the document to be imported.

### Optional attributes:
common-attributes

### Contents:
Empty.

## x:pending
Anything that is within a <pending> element will remain untested, but will be reported as (eventual) desired behaviour. This is a good way of commenting out a set of behaviours that haven't been implemented yet, or scenarios whose desired behaviour hasn't been determined, or tests for code that you're not currently working on, to make the testing process faster.
An optional label attribute can be used to describe why the scenario or assertion should not be tested.

### Required attributes:
None.

### Optional attributes:
common-attributes
label: describes why the scenario or assertion should not be tested.

### Contents:
Any number of the following elements in any order:
x:scenario
x:expect

## x:scenario
A scenario defines the environment in which a piece of processing takes place.
If a scenario has a pending attribute, this has the same semantics as wrapping the scenario in a <pending> element with a label equal to the value of the pending attribute.
If any scenario has a focus attribute, any scenarios without a focus attribute will be classed as pending.

### Required attributes:
label: description of the scenario.

### Optional attributes:
common-attributes
pending: this has the same semantics as wrapping the scenario in a <pending> element with a label equal to the value of the pending attribute. 
focus: If any scenario has a focus attribute, any scenarios without a focus attribute will be classed as pending. 
shared: "yes" or "no". See "shared scenarios"

### Contents:
In the following order:
x:like
x:call
x:expect
x:scenario
There can be any number of these elements but there must be at least one of x:call or x:scenario present.

## Labels
A scenario's label should describe the context that the scenario sets. Top-level scenarios' labels should be of the form "the square of a number" or "the XHTML for a <P1> element". Nested scenario labels will usually start with the word "with"; it should make sense if the labels of ancestor scenarios are concatenated with this one. For example "with a Type attribute".

## Shared scenarios
There are shared scenarios (shared="yes") and unshared scenarios (shared="no", the default). Shared scenarios are not run directly but can be referenced and reused by other scenarios with the <like> element. Unshared scenarios are simply run.


## x:like
The <like> element pulls a shared scenario into this one (which may be shared or unshared). Any environment set within the shared scenario is merged with this one, and any tests in the shared scenario are run in addition to the ones in this scenario. This allows for modular, reusable sets of tests which can be applied in multiple 
scenarios.

### Optional attributes:
common-attributes
label

## x:call
The <call> element defines the inputs, options and parameters to be used in the step invocation. Child scenarios of the scenario that the x:call element belongs to inherits the ports, options and parameters of this x:call element. Ports, options and parameters inherited from ancestor scenarios, or through x:like, will be overridden by the ones declared in this x:call element.

### Optional attributes:
common-attributes
step: Defines which step in the targeted XProc script will be run. Defaults to the first step defined if not set. (Attribute value can be inherited from ancestor scenarios).

### Contents:
In any number and in any order:
x:input
x:option
x:param
x:params

x:param
A parameter name/value pair to be provided on the primary parameter input port of the step.

### Required attributes:
name: the name of the parameter.

### Optional attributes:
select: XPath expression returning the value of the parameter. It is evaluated the same way as for x:option.
namespace: the namespace of the parameter.
as: TODO
common-attributes

### Contents:
At most one x:document.

## x:params
A document describing a set of parameters to be provided on the primary parameter input port of the step.

### Optional attributes:
common-attributes

### Required attributes:
None.

### Contents:
Any number of x:document elements. Multiple parameter set documents will be merged. If the same parameter is defined multiple times, then the last one is used.

## x:option
An XProc option name/value pair to be provided with the XProc step invocation.

### Required attributes:
name: the name of the option.

### Optional attributes:
common-attributes
as: TODO
select: XPath expression returning the value of the option. If the XPath expression references the context then a x:document child must be provided. If the select attribute is not specified, then it defaults to normalize-space(text(/)) for XProc v1.0 and / for v2.0+ and a x:document must be provided.

### Contents:
At most one x:document.
x:input
Defines what documents will be provided on a steps input port.

### Required attributes:
port: the port that the documents will be provided on.

### Optional attributes:
common-attributes

### Contents:
Any number of x:document elements.

## x:document
Either reference an external document using href, or provide the document inline. The document can optionally be given a custom base URI using xml:base.

### Required attributes:
None.

### Optional attributes:
common-attributes
href: URI to the document that this x:document represents.
select: If present, then the elements matching this expression contained in the referenced document will be returned as a document sequence and used instead of the referenced document itself.

### Contents:
At most one arbitrary child element.

## x:expect
An assertion's test XPath can either return a boolean value, in which case the assertion succeeds only if the test is true; or a node, in which case the assertion succeeds only if the node is equal to the one specified with the href and select attributes or content of the <expect> element.

### Required attributes:
label: description of the assertion.

### Optional attributes:
common-attributes
port: Which output port that should be tested. Defaults to the primary document output port.
error: If you expect the step to throw an error, put the error code here.
test: An XPath expression that is evaluated against every document on the output port. Returns true only if they all succeed.
select: If present, then for each document on the output port, the elements matching this expression will be returned as a document sequence and used instead of the documents on the output port.

### Contents:
Any number of x:document elements.
