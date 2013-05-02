<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" type="px:test-compile" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="#all"
    version="1.0" xpath-version="2.0" xmlns:pkg="http://expath.org/ns/pkg" pkg:import-uri="http://josteinaj.no/ns/2013/xprocspec/compile.xpl" xmlns:x="http://www.daisy.org/ns/pipeline/xproc/test">

    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="true" primary="true">
        <p:pipe port="result" step="result"/>
    </p:output>
    <p:output port="test-runner">
        <p:pipe port="result" step="test-runner"/>
    </p:output>
    
    <p:for-each>
        <!-- convert each x:description/scenario/x:call to an XProc script -->
        <p:xslt>
            <p:log port="result" href="file:/tmp/tmp2.xml"/>
            <p:with-param name="name" select="concat('test',p:iteration-position())"/>
            <p:input port="stylesheet">
                <p:document href="description-to-invocation.xsl"/>
            </p:input>
        </p:xslt>
    </p:for-each>
    <p:identity name="result"/>
    
    <p:wrap-sequence wrapper="wrapper"/>
    <p:xslt>
        <!-- create a XProc script that runs all the scripts generated above in sequence -->
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="invocations-to-test-runner.xsl"/>
        </p:input>
    </p:xslt>
    <p:identity name="test-runner"/>

</p:declare-step>
