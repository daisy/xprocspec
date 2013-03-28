<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" type="j:test-run" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:j="http://josteinaj.no/ns" exclude-inline-prefixes="#all" version="1.0"
    xpath-version="2.0" xmlns:pkg="http://expath.org/ns/pkg" pkg:import-uri="http://josteinaj.no/ns/2013/xprocspec/run.xpl" xmlns:x="http://www.josteinaj.no/ns/xprocspec">

    <p:output port="result" sequence="true" primary="true"/>
    <p:option name="test-runner"/>
    
    <!-- This version of run.xpl depends on Calabash and its cx:eval. Hopefully dynamic evaluation of pipelines will be included in XProc 2.0. -->
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

    <p:load name="test-runner">
        <p:with-option name="href" select="$test-runner"/>
    </p:load>
    <cx:eval>
        <p:log port="result" href="file:/tmp/eval.out.xml"/>
        <p:input port="pipeline">
            <p:pipe port="result" step="test-runner"/>
        </p:input>
        <p:input port="source">
            <p:empty/>
        </p:input>
        <p:input port="options">
            <p:empty/>
        </p:input>
    </cx:eval>
    <p:for-each>
        <p:iteration-source select="/x:wrapper/*"/>
        <p:identity/>
    </p:for-each>

</p:declare-step>
