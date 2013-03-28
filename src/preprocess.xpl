<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" type="j:test-preprocess" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:j="http://josteinaj.no/ns" exclude-inline-prefixes="#all"
    version="1.0" xpath-version="2.0" xmlns:pkg="http://expath.org/ns/pkg" pkg:import-uri="http://josteinaj.no/ns/2013/xprocspec/preprocess.xpl" xmlns:x="http://www.josteinaj.no/ns/xprocspec">

    <p:input port="source"/>
    <p:output port="result" sequence="true">
        <p:pipe port="result" step="scenarios"/>
    </p:output>

    <p:declare-step type="x:perform-imports" name="perform-imports">
        <p:input port="source"/>
        <p:output port="result" sequence="true">
            <p:pipe port="source" step="perform-imports"/>
            <p:pipe port="result" step="perform-imports.imports"/>
        </p:output>
        <p:for-each>
            <p:iteration-source select="/*/x:import"/>
            <p:load>
                <p:with-option name="href" select="resolve-uri(/*/@href,base-uri(/*))"/>
            </p:load>
        </p:for-each>
        <p:identity name="perform-imports.imports"/>
    </p:declare-step>

    <x:perform-imports/>
    <p:for-each>
        <p:output port="result" sequence="true"/>

        <!-- create a new x:description document for each x:scenario element with inferred inputs, options and parameters -->
        <p:add-attribute match="/*" attribute-name="script">
            <p:with-option name="attribute-value" select="resolve-uri(/*/@script,base-uri(/*))"/>
        </p:add-attribute>
        <p:viewport match="//x:call[@step]">
            <p:add-attribute match="/*" attribute-name="x:step">
                <p:with-option name="attribute-value" select="concat('{',namespace-uri-from-QName(resolve-QName(/*/@step,/*)),'}',tokenize(/*/@step,':')[last()])"/>
            </p:add-attribute>
        </p:viewport>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="infer-scenarios.xsl"/>
            </p:input>
        </p:xslt>
        <p:for-each>
            <p:iteration-source select="/*/*"/>
            <p:variable name="step" select="//x:call/@x:step"/>
            <p:insert match="/*" position="first-child">
                <p:input port="insertion">
                    <p:pipe port="result" step="step-declarations"/>
                </p:input>
            </p:insert>
            <p:delete>
                <p:with-option name="match" select="concat('/*/x:script-declaration/*[not(@x:type=&quot;',$step,'&quot;)]')"/>
            </p:delete>
        </p:for-each>
    </p:for-each>
    <p:identity name="scenarios"/>
    <p:sink/>

    <p:identity>
        <p:input port="source">
            <p:pipe port="source" step="main"/>
        </p:input>
    </p:identity>
    <p:group>
        <p:variable name="script-uri" select="resolve-uri(/*/@script,base-uri(/*))"/>
        <p:for-each>
            <p:iteration-source select="//x:call"/>
            <p:add-attribute match="/*" attribute-name="step">
                <p:with-option name="attribute-value" select="concat('{',namespace-uri-from-QName(resolve-QName(/*/@step,/*)),'}',tokenize(/*/@step,':')[last()])"/>
            </p:add-attribute>
            <p:delete match="/*/*"/>
        </p:for-each>
        <p:wrap-sequence wrapper="wrapper"/>
        <p:delete match="x:call[concat(@step-namespace,@step-name)=preceding::x:call/concat(@step-namespace,@step-name)]"/>
        <p:for-each>
            <p:iteration-source select="/*/*"/>
            <p:identity/>
        </p:for-each>
        <p:identity name="calls"/>

        <p:load>
            <p:with-option name="href" select="$script-uri"/>
        </p:load>
        <p:viewport match="//p:declare-step">
            <p:add-attribute match="/*" attribute-name="x:type">
                <p:with-option name="attribute-value" select="concat('{',namespace-uri-from-QName(resolve-QName(/*/@type,/*)),'}',tokenize(/*/@type,':')[last()])"/>
            </p:add-attribute>
        </p:viewport>
        <p:identity name="script"/>

        <p:for-each>
            <p:iteration-source>
                <p:pipe port="result" step="calls"/>
            </p:iteration-source>
            <p:variable name="step" select="/*/@step"/>
            <p:for-each>
                <p:iteration-source select="//p:declare-step[@x:type=$step]">
                    <p:pipe port="result" step="script"/>
                </p:iteration-source>
                <p:identity/>
            </p:for-each>
            <p:identity name="step-declaration"/>
            <p:count/>
            <p:choose>
                <p:when test="number(.)=0">
                    <!-- TODO: step not found; throw error? -->
                    <p:identity>
                        <p:input port="source">
                            <p:empty/>
                        </p:input>
                    </p:identity>
                </p:when>
                <p:otherwise>
                    <p:identity>
                        <p:input port="source">
                            <p:pipe port="result" step="step-declaration"/>
                        </p:input>
                    </p:identity>
                    <p:delete match="/*/*[not(self::p:input or self::p:output or self::p:option)]"/>
                </p:otherwise>
            </p:choose>
        </p:for-each>
        <p:wrap-sequence wrapper="x:step-declaration"/>
    </p:group>
    <p:identity name="step-declarations"/>
    <p:sink/>

</p:declare-step>
