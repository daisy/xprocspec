<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" type="px:test-compile" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    exclude-inline-prefixes="#all" version="1.0" xpath-version="2.0" xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils" xmlns:x="http://www.daisy.org/ns/pipeline/xproc/test">

    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="true" primary="true">
        <p:pipe port="result" step="result"/>
    </p:output>
    
    <p:option name="temp-dir" required="true"/>
    <p:variable name="test-temp-dir" select="concat($temp-dir,'xprocspec-',replace(replace(concat(current-dateTime(),''),'\+.*',''),'[^\d]',''),'/')">
        <p:inline>
            <doc/>
        </p:inline>
    </p:variable>
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" use-when="p:system-property('p:product-name') = 'XML Calabash'"/>
    <cxf:mkdir fail-on-error="false" name="mkdir" p:use-when="p:system-property('p:product-name') = 'XML Calabash'">
        <p:with-option name="href" select="$test-temp-dir">
            <p:inline>
                <doc/>
            </p:inline>
        </p:with-option>
    </cxf:mkdir>
    
    <p:for-each cx:depends-on="mkdir">
        <!-- convert each x:description/scenario/x:call to an XProc script -->
        <p:iteration-source>
            <p:pipe port="source" step="main"/>
        </p:iteration-source>
        <p:choose>
            <p:when test="/*[self::c:errors]">
                <p:identity/>
            </p:when>
            <p:otherwise>
                <p:variable name="base" select="base-uri(/*)"/>
                <p:try>
                    <p:group>
                        <p:add-attribute match="/*" attribute-name="temp-dir">
                            <p:with-option name="attribute-value" select="$test-temp-dir"/>
                        </p:add-attribute>
                        <p:xslt>
                            <p:with-param name="name" select="concat('test',p:iteration-position())"/>
                            <p:with-param name="temp-dir" select="$test-temp-dir"/>
                            <p:input port="stylesheet">
                                <p:document href="description-to-invocation.xsl"/>
                            </p:input>
                        </p:xslt>
                        
                        <!-- validate output grammar -->
                        <p:validate-with-relax-ng>
                            <p:input port="schema">
                                <p:document href="../../schema/xprocspec.compile.rng"/>
                            </p:input>
                        </p:validate-with-relax-ng>
                        
                        <p:wrap-sequence wrapper="calabash-issue-102"/>
                    </p:group>
                    <p:catch name="catch">
                        <p:identity>
                            <p:input port="source">
                                <p:pipe port="error" step="catch"/>
                            </p:input>
                        </p:identity>
                        <p:add-attribute match="/*" attribute-name="xml:base">
                            <p:with-option name="attribute-value" select="$base"/>
                        </p:add-attribute>
                        <p:wrap-sequence wrapper="calabash-issue-102"/>
                    </p:catch>
                </p:try>
                <p:for-each>
                    <!-- temporary fix for https://github.com/ndw/xmlcalabash1/issues/102 -->
                    <p:iteration-source select="/calabash-issue-102/*"/>
                    <p:identity/>
                </p:for-each>
            </p:otherwise>
        </p:choose>
    </p:for-each>
    <p:identity name="result"/>

</p:declare-step>
