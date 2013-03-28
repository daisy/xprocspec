<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" type="j:xprocspec" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:j="http://josteinaj.no/ns" exclude-inline-prefixes="#all"
    version="1.0" xpath-version="2.0" xmlns:pkg="http://expath.org/ns/pkg" pkg:import-uri="http://josteinaj.no/ns/2013/xprocspec/xprocspec.xpl">

    <p:input port="source"/>
    <p:output port="result"/>
    <p:option name="temp-dir" select="'file:/tmp/'"/>

    <p:import href="preprocess.xpl"/>
    <p:import href="compile.xpl"/>
    <p:import href="run.xpl"/>
    <p:import href="evaluate.xpl"/>
    <p:import href="report.xpl"/>

    <!-- split the x:description documents into multiple documents; one for each x:scenario -->
    <j:test-preprocess name="preprocess"/>

    <!-- make XProc scripts out of each scenario -->
    <j:test-compile name="compile"/>

    <!-- store the XProc scripts (just in case there is a lot of tests - it could optionally be done in-memory) -->
    <p:for-each name="test-store">
        <p:output port="result">
            <p:pipe port="result" step="store"/>
        </p:output>
        <p:store name="store">
            <p:with-option name="href" select="concat($temp-dir,tokenize(/*/@type,':')[last()],'.xpl')"/>
        </p:store>
    </p:for-each>
    <p:store name="test-runner-store">
        <p:with-option name="href" select="concat($temp-dir,'test.xpl')">
            <p:inline>
                <doc/>
            </p:inline>
        </p:with-option>
        <p:input port="source">
            <p:pipe port="test-runner" step="compile"/>
        </p:input>
    </p:store>
    <p:wrap-sequence wrapper="wrapper" name="depend-on-me">
        <p:input port="source">
            <p:pipe port="result" step="test-store"/>
            <p:pipe port="result" step="test-runner-store"/>
        </p:input>
    </p:wrap-sequence>

    <!-- run the XProc scripts -->
    <j:test-run name="run">
        <p:with-option name="test-runner" select="concat($temp-dir,'test.xpl')">
            <p:pipe port="result" step="depend-on-me"/>
        </p:with-option>
    </j:test-run>

    <!-- compare the results with the expected results -->
    <j:test-evaluate/>

    <!-- make a machine readable report as well as a human readable one -->
    <j:test-report name="report"/>

</p:declare-step>
