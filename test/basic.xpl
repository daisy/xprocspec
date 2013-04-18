<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:ex="http://example.net/ns" type="ex:example-basic" name="main" version="1.0">
    <p:input port="source" primary="true">
        <p:inline>
            <doc>Hello world!</doc>
        </p:inline>
    </p:input>
    <p:input port="input-sequence" sequence="true"/>
    <p:input port="parameter" kind="parameter"/>
    
    <p:output port="result">
        <p:pipe port="result" step="result"/>
    </p:output>
    <p:output port="output-sequence" sequence="true">
        <p:pipe port="input-sequence" step="main"/>
    </p:output>
    
    <p:option name="option-name" select="'option-value'"/>
    
    <p:add-attribute match="/*" attribute-name="attribute">
        <p:with-option name="attribute-value" select="$option-name"/>
    </p:add-attribute>
    <p:identity name="result"/>
    
</p:declare-step>
