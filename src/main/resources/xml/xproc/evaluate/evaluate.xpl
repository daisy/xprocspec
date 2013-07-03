<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" type="pxi:test-evaluate" name="main" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc-internal/xprocspec"
    exclude-inline-prefixes="#all" version="1.0" xpath-version="2.0" xmlns:pkg="http://expath.org/ns/pkg" xmlns:x="http://www.daisy.org/ns/pipeline/xproc/test">

    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="true"/>

    <p:import href="compare.xpl"/>
    <p:import href="../utils/logging-library.xpl"/>
    <p:import href="../utils/document.xpl"/>

    <p:for-each name="current-test">
        <!-- for each scenario -->

        <p:variable name="base" select="base-uri(/*)"/>
        <p:identity>
            <p:log port="result" href="file:/tmp/current.xml"/>
        </p:identity>

        <p:choose>
            <p:when test="/*[self::c:errors]">
                <pxi:message message=" * error document; skipping"/>
                <p:identity name="c-error"/>
            </p:when>
            <p:otherwise>
                <p:variable name="temp-dir" select="/*/@temp-dir"/>
                
                <p:identity name="try.input"/>
                <p:try>
                    <p:group>
                        <p:identity name="description"/>
                        <p:viewport>
                            <!-- for each test in the scenario -->
                            <p:iteration-source select="//x:document"/>
                            <!--<p:iteration-source select="/x:description/x:scenario/x:expect"/>-->
                            
                            <pxi:document>
                                <p:input port="description">
                                    <p:pipe port="result" step="description"/>
                                </p:input>
                            </pxi:document>
                        </p:viewport>
                        
                        <p:add-attribute match="/*" attribute-name="xml:base">
                            <p:with-option name="attribute-value" select="base-uri(/*)"/>
                        </p:add-attribute>
                        <p:xslt>
                            <p:input port="parameters">
                                <p:empty/>
                            </p:input>
                            <p:input port="stylesheet">
                                <p:inline>
                                    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://example.net/" xpath-default-namespace="http://example.net/" version="2.0" xmlns:x="http://www.daisy.org/ns/pipeline/xproc/test">
                                        
                                        <xsl:template match="@*|node()">
                                            <xsl:copy>
                                                <xsl:apply-templates select="@*|node()"/>
                                            </xsl:copy>
                                        </xsl:template>
                                        
                                        <xsl:template match="x:scenario">
                                            <xsl:copy-of select="x:call"/>
                                            <xsl:for-each select="x:context | *[preceding-sibling::x:context]">
                                                <xsl:copy>
                                                    <xsl:for-each-group select="*" group-starting-with="context">
                                                        <x:context-group>
                                                            <xsl:for-each select="current-group()">
                                                                <xsl:copy-of select="."/>
                                                            </xsl:for-each>
                                                        </x:context-group>
                                                    </xsl:for-each-group>
                                                </xsl:copy>
                                            </xsl:for-each>
                                        </xsl:template>
                                        
                                    </xsl:stylesheet>
                                </p:inline>
                            </p:input>
                        </p:xslt>
                        
                        <p:for-each>
                            <p:iteration-source select="/x:description/x:scenario/x:context-group"/>
                            <p:identity name="context-group"/>
                            <p:for-each name="context">
                                <p:output port="result" sequence="true"/>
                                <p:iteration-source select="/x:context-group/x:context/x:document"/>
                                <p:identity/>
                            </p:for-each>
                            <p:for-each name="assertions">
                                <p:iteration-source select="/x:context-group/*[position()&gt;1]">
                                    <p:pipe port="result" step="context-group"/>
                                </p:iteration-source>
                                
                                <p:identity name="assertion"/>
                                <p:choose>
                                    <p:when test="/x:expect[@test]">
                                        
                                    </p:when>
                                    <p:when test="/x:expect[@error]">
                                        
                                    </p:when>
                                    <p:when test="/x:validate[@grammar='relax-ng']">
                                        <!-- skip validation when Relax NG validation is not supported and display a warning instead -->
                                    </p:when>
                                    <p:when test="/x:validate[@grammar='schematron']">
                                        <!-- skip validation when Schematron validation is not supported and display a warning instead -->
                                    </p:when>
                                    <p:when test="/x:validate[@grammar='xml-schema']">
                                        <!-- skip validation when XML Schema validation is not supported and display a warning instead -->
                                    </p:when>
                                </p:choose>
                            </p:for-each>
                        </p:for-each>

                            <!--<p:choose>
                                <p:when test="/*[@test]">
                                    <!-\- evaluate @test against context -\->
                                    <p:variable name="test" select="/*/@test"/>

                                    <!-\- the XPath expression must evalutate to true() for all documents on the output port, and there must be at least one document on the output port -\->
                                    <p:for-each>
                                        <p:iteration-source>
                                            <p:pipe port="result" step="context"/>
                                        </p:iteration-source>
                                        <p:filter>
                                            <p:with-option name="select" select="concat('if (',$test,') then /* else /*[false()]')"/>
                                        </p:filter>
                                        <p:count/>
                                    </p:for-each>
                                    <p:wrap-sequence wrapper="c:result"/>
                                    <p:add-attribute match="/*" attribute-name="result">
                                        <p:with-option name="attribute-value" select="/c:result/c:result and not((for $result in (/c:result/c:result/number(.)) return $result &gt; 0) = false())"/>
                                    </p:add-attribute>
                                    <p:delete match="/c:result/c:result"/>
                                    <p:identity name="test-result"/>

                                    <p:group>
                                        <p:wrap-sequence wrapper="x:was" name="was">
                                            <p:input port="source">
                                                <p:pipe port="result" step="context"/>
                                            </p:input>
                                        </p:wrap-sequence>

                                        <p:string-replace match="/*/text()" name="expected">
                                            <p:with-option name="replace" select="concat('&quot;',$test,'&quot;')"/>
                                            <p:input port="source">
                                                <p:inline>
                                                    <x:expected>EXPECTED</x:expected>
                                                </p:inline>
                                            </p:input>
                                        </p:string-replace>

                                        <p:insert match="/*" position="last-child">
                                            <p:input port="source">
                                                <p:pipe port="result" step="test-result"/>
                                            </p:input>
                                            <p:input port="insertion">
                                                <p:pipe port="result" step="was"/>
                                                <p:pipe port="result" step="expected"/>
                                            </p:input>
                                        </p:insert>
                                    </p:group>

                                    <p:add-attribute match="/*" attribute-name="test-type" attribute-value="xpath"/>
                                </p:when>
                                <p:when test="/*[@error]">
                                    <p:variable name="error" select="/*/@error"/>

                                    <p:choose>
                                        <p:xpath-context>
                                            <p:pipe port="result" step="description"/>
                                        </p:xpath-context>
                                        <p:when test="/x:description/c:errors/c:error[@code=$error]">
                                            <p:identity>
                                                <p:input port="source">
                                                    <p:inline>
                                                        <c:result result="true"/>
                                                    </p:inline>
                                                </p:input>
                                            </p:identity>
                                        </p:when>
                                        <p:otherwise>
                                            <p:identity>
                                                <p:input port="source">
                                                    <p:inline>
                                                        <c:result result="false"/>
                                                    </p:inline>
                                                </p:input>
                                            </p:identity>
                                        </p:otherwise>
                                    </p:choose>
                                    <p:identity name="test-result"/>

                                    <p:group>
                                        <p:wrap-sequence wrapper="x:was" name="was">
                                            <p:input port="source">
                                                <p:pipe port="result" step="context"/>
                                            </p:input>
                                        </p:wrap-sequence>

                                        <p:string-replace match="/*/text()" name="expected">
                                            <p:with-option name="replace" select="concat('&quot;',$error,'&quot;')"/>
                                            <p:input port="source">
                                                <p:inline>
                                                    <x:expected>EXPECTED</x:expected>
                                                </p:inline>
                                            </p:input>
                                        </p:string-replace>

                                        <p:insert match="/*" position="last-child">
                                            <p:input port="source">
                                                <p:pipe port="result" step="test-result"/>
                                            </p:input>
                                            <p:input port="insertion">
                                                <p:pipe port="result" step="was"/>
                                                <p:pipe port="result" step="expected"/>
                                            </p:input>
                                        </p:insert>
                                    </p:group>

                                    <p:add-attribute match="/*" attribute-name="test-type" attribute-value="error"/>
                                </p:when>
                                <p:otherwise>
                                    <p:for-each name="expect">
                                        <p:output port="result" sequence="true"/>
                                        <p:iteration-source select="/x:expect/x:document"/>

                                        <p:choose>
                                            <p:when test="/*/@port">
                                                <p:variable name="position" select="(/*/@position,'all')[1]"/>
                                                <p:filter>
                                                    <p:with-option name="select" select="concat('/x:description/x:output[@port=&quot;',/*/@port,'&quot;]/*')"/>
                                                    <p:input port="source">
                                                        <p:pipe port="result" step="description"/>
                                                    </p:input>
                                                </p:filter>
                                                <p:choose>
                                                    <p:xpath-context>
                                                        <p:inline>
                                                            <doc/>
                                                        </p:inline>
                                                    </p:xpath-context>
                                                    <p:when test="string(number($position))='NaN'">
                                                        <p:identity/>
                                                    </p:when>
                                                    <p:otherwise>
                                                        <p:split-sequence initial-only="true">
                                                            <p:with-option name="test" select="concat('position()=',$position)"/>
                                                        </p:split-sequence>
                                                    </p:otherwise>
                                                </p:choose>
                                            </p:when>
                                            <p:when test="/*/@directory">
                                                <pxi:directory-list>
                                                    <p:with-option name="path" select="resolve-uri(/*/@directory,if (/*/@base-uri='temp-dir') then $temp-dir else base-uri(/*))"/>
                                                    <p:with-option name="depth" select="if (/*/@recursive='true') then '-1' else '0'"/>
                                                </pxi:directory-list>
                                                <p:delete match="//*/@xml:base"/>
                                            </p:when>
                                            <p:when test="/*/@directory-info">
                                                <!-\- TODO: use calabash extension step, possibly rename to non-calabash namespace -\->
                                                <p:identity>
                                                    <p:input port="source">
                                                        <p:inline>
                                                            <c:body>TODO: directory-info</c:body>
                                                        </p:inline>
                                                    </p:input>
                                                </p:identity>
                                            </p:when>
                                            <p:when test="/*/@file">
                                                <pxi:load>
                                                    <p:with-option name="href" select="resolve-uri((/*/@file,/*/@href)[1],if (/*/@base-uri='temp-dir') then $temp-dir else base-uri(/*))"/>
                                                    <p:with-option name="method" select="(/*/@method,'xml')[1]"/>
                                                </pxi:load>
                                            </p:when>
                                            <p:when test="/*/@file-info">
                                                <!-\- TODO: use calabash extension step, possibly rename to non-calabash namespace -\->
                                                <p:identity>
                                                    <p:input port="source">
                                                        <p:inline>
                                                            <c:body>TODO: file-info</c:body>
                                                        </p:inline>
                                                    </p:input>
                                                </p:identity>
                                            </p:when>
                                            <p:otherwise>
                                                <p:for-each>
                                                    <p:iteration-source select="/x:document/*"/>
                                                    <p:identity/>
                                                </p:for-each>
                                            </p:otherwise>
                                        </p:choose>
                                    </p:for-each>

                                    <pxi:compare>
                                        <p:input port="source">
                                            <p:pipe port="result" step="context"/>
                                        </p:input>
                                        <p:input port="alternate">
                                            <p:pipe port="result" step="expect"/>
                                        </p:input>
                                    </pxi:compare>

                                    <p:add-attribute match="/*" attribute-name="test-type" attribute-value="xml"/>
                                </p:otherwise>
                            </p:choose>
                            <p:rename match="/*" new-name="x:test-result"/>
                            <p:set-attributes match="/*">
                                <p:input port="attributes">
                                    <p:pipe port="current" step="test"/>
                                </p:input>
                            </p:set-attributes>
                        </p:viewport>-->
                        <p:identity name="test-results"/>
                        
                        <p:insert match="/*" position="last-child">
                            <p:input port="source">
                                <p:pipe port="result" step="description"/>
                            </p:input>
                            <p:input port="insertion">
                                <p:pipe port="result" step="test-results"/>
                            </p:input>
                        </p:insert>
                        
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
                        <p:add-attribute match="/*" attribute-name="test-base-uri">
                            <p:with-option name="attribute-value" select="$base"/>
                        </p:add-attribute>
                        <p:add-attribute match="/*" attribute-name="error-location" attribute-value="evaluate.xpl - evaluation of assertions"/>
                        
                        <p:identity name="errors-without-was"/>
                        <p:wrap-sequence wrapper="x:was">
                            <p:input port="source">
                                <p:pipe port="result" step="try.input"/>
                            </p:input>
                        </p:wrap-sequence>
                        <p:add-attribute match="/*" attribute-name="xml:base">
                            <p:with-option name="attribute-value" select="base-uri(/*/*)"/>
                        </p:add-attribute>
                        <p:wrap-sequence wrapper="c:error"/>
                        <p:add-attribute match="/*" attribute-name="type" attribute-value="was"/>
                        <p:identity name="was"/>
                        <p:insert match="/*" position="last-child">
                            <p:input port="source">
                                <p:pipe port="result" step="errors-without-was"/>
                            </p:input>
                            <p:input port="insertion">
                                <p:pipe port="result" step="was"/>
                            </p:input>
                        </p:insert>
                        
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

        <!-- validate output grammar -->
        <p:group>
            <p:identity name="try.input"/>
            <p:try>
                <p:group>
                    <p:identity>
                        <p:log port="result" href="file:/tmp/evaluate.validate.in.xml"/>
                    </p:identity>
                    <p:validate-with-relax-ng>
                        <p:input port="schema">
                            <p:document href="../../schema/xprocspec.evaluate.rng"/>
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
                    <p:add-attribute match="/*" attribute-name="test-base-uri">
                        <p:with-option name="attribute-value" select="$base"/>
                    </p:add-attribute>
                    <p:add-attribute match="/*" attribute-name="error-location" attribute-value="evaluate.xpl - validation of output grammar"/>
                    
                    <p:identity name="errors-without-was"/>
                    <p:wrap-sequence wrapper="x:was">
                        <p:input port="source">
                            <p:pipe port="result" step="try.input"/>
                        </p:input>
                    </p:wrap-sequence>
                    <p:add-attribute match="/*" attribute-name="xml:base">
                        <p:with-option name="attribute-value" select="base-uri(/*/*)"/>
                    </p:add-attribute>
                    <p:wrap-sequence wrapper="c:error"/>
                    <p:add-attribute match="/*" attribute-name="type" attribute-value="was"/>
                    <p:identity name="was"/>
                    <p:insert match="/*" position="last-child">
                        <p:input port="source">
                            <p:pipe port="result" step="errors-without-was"/>
                        </p:input>
                        <p:input port="insertion">
                            <p:pipe port="result" step="was"/>
                        </p:input>
                    </p:insert>
                    
                    <p:wrap-sequence wrapper="calabash-issue-102"/>
                </p:catch>
            </p:try>
            <p:for-each>
                <!-- temporary fix for https://github.com/ndw/xmlcalabash1/issues/102 -->
                <p:iteration-source select="/calabash-issue-102/*"/>
                <p:identity/>
            </p:for-each>
        </p:group>

    </p:for-each>

</p:declare-step>
