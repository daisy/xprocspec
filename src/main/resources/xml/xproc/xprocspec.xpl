<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" type="px:xprocspec" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:px="http://www.daisy.org/ns/xprocspec"
    xmlns:pxi="http://www.daisy.org/ns/xprocspec/xproc-internal/" exclude-inline-prefixes="#all" version="1.0" xpath-version="2.0" xmlns:pkg="http://expath.org/ns/pkg" pkg:import-uri="http://www.daisy.org/ns/xprocspec/xprocspec.xpl">

    <p:input port="source"/>

    <p:output port="result">
        <p:pipe port="result" step="report"/>
    </p:output>
    <p:output port="html">
        <p:pipe port="html" step="report"/>
    </p:output>
    <p:output port="junit">
        <p:pipe port="junit" step="report"/>
    </p:output>

    <p:option name="temp-dir" select="'file:/tmp/'"/>

    <p:import href="preprocess/preprocess.xpl"/>
    <p:import href="compile/compile.xpl"/>
    <p:import href="run/run.xpl"/>
    <p:import href="evaluate/evaluate.xpl"/>
    <p:import href="report/report.xpl"/>
    <p:import href="utils/logging-library.xpl"/>

    <!--
        * Converts any other XProc test syntaxes (currently supported: XProc Test Suite).
        * Splits the x:description documents into multiple documents; one for each x:scenario with no dependencies between them.
    -->
    <pxi:message message="#### $1 ####">
        <p:with-option name="param1" select="base-uri(/*)"/>
    </pxi:message>
    <pxi:message message="preprocessing..."/>
    <pxi:test-preprocess name="preprocess">
        <p:with-option name="temp-dir" select="$temp-dir"/>
    </pxi:test-preprocess>

    <!-- make XProc scripts out of each scenario -->
    <pxi:message message="compiling..."/>
    <pxi:test-compile name="compile">
        <p:with-option name="temp-dir" select="$temp-dir">
            <p:inline>
                <doc/>
            </p:inline>
        </p:with-option>
    </pxi:test-compile>

    <!-- store the XProc scripts (just in case there is a lot of tests - it could optionally be done in-memory) -->
    <pxi:message message="storing..."/>
    <p:for-each name="test-store">
        <p:output port="result">
            <p:pipe port="result" step="store"/>
        </p:output>
        <p:add-attribute match="/*" attribute-name="xml:base">
            <p:with-option name="attribute-value" select="base-uri(/*)"/>
        </p:add-attribute>
        <p:choose name="store">
            <p:when test="/*[self::c:errors]">
                <p:output port="result">
                    <p:pipe port="result" step="store-error"/>
                </p:output>
                <p:store name="store-error">
                    <p:with-option name="href" select="concat($temp-dir,'error',p:iteration-position(),'.xml')"/>
                </p:store>
            </p:when>
            <p:otherwise>
                <p:output port="result">
                    <p:pipe port="result" step="store-step"/>
                </p:output>
                <p:store name="store-step">
                    <p:with-option name="href" select="concat($temp-dir,tokenize(/*/@type,':')[last()],'.xpl')"/>
                </p:store>
            </p:otherwise>
        </p:choose>
    </p:for-each>
    <p:wrap-sequence wrapper="wrapper" name="depend-on-me">
        <p:input port="source">
            <p:pipe port="result" step="test-store"/>
        </p:input>
    </p:wrap-sequence>
    <p:identity>
        <p:input port="source">
            <p:pipe port="result" step="test-store"/>
        </p:input>
    </p:identity>

    <!-- run the XProc scripts -->
    <pxi:message message="running..."/>
    <pxi:test-run name="run">
        <p:with-option name="depend-on-stored-files" select="''">
            <p:pipe port="result" step="depend-on-me"/>
        </p:with-option>
    </pxi:test-run>

    <!-- compare the results with the expected results -->
    <pxi:message message="evaluating..."/>
    <pxi:test-evaluate/>

    <!-- make a machine readable report as well as a human readable one -->
    <pxi:message message="reporting..."/>
    <pxi:test-report name="report"/>

    <p:identity>
        <p:input port="source">
            <p:pipe port="junit" step="report"/>
        </p:input>
    </p:identity>
    <pxi:message message="Results: tests: $1, errors: $2, failures: $3">
        <p:with-option name="param1" select="/*/@tests"/>
        <p:with-option name="param2" select="/*/@errors"/>
        <p:with-option name="param3" select="/*/@failures"/>
    </pxi:message>
    <p:sink/>

</p:declare-step>
