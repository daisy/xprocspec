<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" type="px:xprocspec" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="#all"
    version="1.0" xpath-version="2.0" xmlns:pkg="http://expath.org/ns/pkg" pkg:import-uri="http://josteinaj.no/ns/2013/xprocspec/xprocspec.xpl">

    <p:input port="source"/>
    <p:output port="result">
        <p:pipe port="result" step="report"/>
    </p:output>
    <p:option name="temp-dir" select="'file:/tmp/'"/>

    <p:import href="preprocess/preprocess.xpl"/>
    <p:import href="compile/compile.xpl"/>
    <p:import href="run/run.xpl"/>
    <p:import href="evaluate/evaluate.xpl"/>
    <p:import href="report/report.xpl"/>
    
    <p:identity/>
    
    <!-- split the x:description documents into multiple documents; one for each x:scenario with no dependencies between them -->
    <px:test-preprocess name="preprocess"/>

    <!-- make XProc scripts out of each scenario -->
    <px:test-compile name="compile"/>

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
    <px:test-run name="run">
        <p:with-option name="test-runner" select="concat($temp-dir,'test.xpl')">
            <p:pipe port="result" step="depend-on-me"/>
        </p:with-option>
    </px:test-run>

    <!-- compare the results with the expected results -->
    <px:test-evaluate/>

    <!-- make a machine readable report as well as a human readable one -->
    <px:test-report name="report"/>
    <!--<p:store href="file:/tmp/report.html"/>-->

</p:declare-step>
