<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" type="pxi:test-evaluate" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:pxi="http://www.daisy.org/ns/xprocspec/xproc-internal/"
    exclude-inline-prefixes="#all" version="1.0" xpath-version="2.0" xmlns:x="http://www.daisy.org/ns/xprocspec">

    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="true"/>

    <p:import href="compare.xpl"/>
    <p:import href="../utils/logging-library.xpl"/>
    <p:import href="../utils/document.xpl"/>
    
    <p:for-each name="current-test">
        <!-- for each scenario -->

        <p:variable name="base" select="base-uri(/*)"/>

        <p:choose>
            <p:when test="/*[self::c:errors]">
                <pxi:message message=" * error document; skipping"/>
                <p:identity name="c-error"/>
            </p:when>
            <p:otherwise>
                <p:variable name="temp-dir" select="/*/@temp-dir"/>
                <p:variable name="skip-scenario" select="if (/x:description/x:scenario[@pending]) then 'true' else 'false'"/>

                <p:identity name="try.input"/>
                <p:try>
                    <p:group>
                        <p:identity name="description.pre-document-resolution"/>
                        <p:delete match="//x:document[ancestor::*[@pending]]"/>
                        <p:viewport match="//x:document">
                            <!-- resolve all x:documents in the description -->
                            <pxi:document>
                                <p:input port="description">
                                    <p:pipe port="result" step="description.pre-document-resolution"/>
                                </p:input>
                            </pxi:document>
                        </p:viewport>
                        <p:identity name="description"/>

                        <p:add-attribute match="/*" attribute-name="xml:base">
                            <!-- since it won't be preserved through XSLT transforms (see this thread: http://lists.w3.org/Archives/Public/xproc-dev/2013Mar/0013.html) -->
                            <p:with-option name="attribute-value" select="base-uri(/*)"/>
                        </p:add-attribute>
                        <p:xslt>
                            <!-- group elements; there's no good way to do it in pure xproc afaik -->
                            <p:input port="parameters">
                                <p:empty/>
                            </p:input>
                            <p:input port="stylesheet">
                                <p:document href="group-assertions-with-context.xsl"/>
                            </p:input>
                        </p:xslt>

                        <p:for-each>
                            <p:iteration-source select="/x:description/x:scenario/x:context-group"/>
                            <p:identity name="context-group"/>
                            <p:for-each name="context">
                                <p:output port="result" sequence="true"/>
                                <p:iteration-source select="/x:context-group/x:context/x:document/*"/>
                                <p:identity/>
                            </p:for-each>
                            <p:for-each name="assertions">
                                <p:iteration-source select="/x:context-group/*[position()&gt;1]">
                                    <p:pipe port="result" step="context-group"/>
                                </p:iteration-source>

                                <p:identity name="assertion"/>
                                <p:choose>

                                    <p:when test="/x:expect[@pending] or $skip-scenario='true'">
                                        <p:identity>
                                            <p:input port="source">
                                                <p:inline>
                                                    <x:test-result result="skipped"/>
                                                </p:inline>
                                            </p:input>
                                        </p:identity>
                                    </p:when>

                                    <p:when test="/x:expect[@type='xpath']">
                                        <!-- evaluate @test against context -->
                                        <p:variable name="test" select="/*/@test"/>

                                        <!-- the XPath expression must evalutate to true() for all documents on the output port, and there must be at least one document on the output port -->
                                        <p:for-each>
                                            <p:iteration-source>
                                                <p:pipe port="result" step="context"/>
                                            </p:iteration-source>
                                            <p:filter>
                                                <p:with-option name="select" select="concat('if (',$test,') then /* else /*[false()]')"/>
                                            </p:filter>
                                            <p:count/>
                                        </p:for-each>
                                        <p:wrap-sequence wrapper="x:test-result"/>
                                        <p:add-attribute match="/*" attribute-name="result">
                                            <p:with-option name="attribute-value" select="if (not(some $result in (/x:test-result/c:result/number(.)) satisfies $result = 0)) then 'passed' else 'failed'"/>
                                        </p:add-attribute>
                                        <p:delete match="/x:test-result/c:result"/>
                                        <p:identity name="test-result"/>

                                        <p:group>
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
                                                    <p:pipe port="result" step="expected"/>
                                                </p:input>
                                            </p:insert>
                                        </p:group>
                                    </p:when>

                                    <p:when test="/x:expect[@type='compare']">
                                        <p:for-each name="expect">
                                            <p:output port="result" sequence="true"/>
                                            <p:iteration-source select="/x:expect/x:document/*"/>
                                            <p:identity/>
                                        </p:for-each>

                                        <pxi:compare>
                                            <p:input port="source">
                                                <p:pipe port="result" step="context"/>
                                            </p:input>
                                            <p:input port="alternate">
                                                <p:pipe port="result" step="expect"/>
                                            </p:input>
                                        </pxi:compare>
                                        <p:rename match="/*" new-name="x:test-result"/>
                                        <p:add-attribute match="/*" attribute-name="result">
                                            <p:with-option name="attribute-value" select="if (/*/@result='true') then 'passed' else 'failed'"/>
                                        </p:add-attribute>
                                    </p:when>
                                    
                                    <p:when test="/x:expect[@type='count']">
                                        <!-- the minimum amount of documents -->
                                        <p:variable name="min" select="/*/@min"/>
                                        
                                        <!-- the maximum amount of documents -->
                                        <p:variable name="max" select="/*/@max"/>
                                        
                                        <p:count name="count">
                                            <p:input port="source">
                                                <p:pipe port="result" step="context"/>
                                            </p:input>
                                        </p:count>
                                        <p:wrap-sequence wrapper="x:test-result"/>
                                        <p:add-attribute match="/*" attribute-name="result">
                                            <p:with-option name="attribute-value" select="if (($min='' or number($min) &lt;= number(.)) and ($max='' or number($max) &gt;= number(.))) then 'passed' else 'failed'"/>
                                        </p:add-attribute>
                                        <p:rename match="/x:test-result/c:result" new-name="x:was"/>
                                        <p:identity name="test-result"/>
                                        
                                        
                                        <p:group>
                                            
                                            <p:string-replace match="/*/text()" name="expected">
                                                <p:with-option name="replace" select="concat('&quot;',if ($min and $max) then concat('At least ',$min,' and at most ',$max,' documents.') else if ($min) then concat('At least ',$min,' documents.') else if ($max) then concat('At most ',$max,' documents.') else 'Any number of documents','&quot;')"/>
                                                <p:input port="source">
                                                    <p:inline>
                                                        <x:expected>EXPECTED</x:expected>
                                                    </p:inline>
                                                </p:input>
                                            </p:string-replace>
                                            
                                            <p:insert match="/*" position="first-child">
                                                <p:input port="source">
                                                    <p:pipe port="result" step="test-result"/>
                                                </p:input>
                                                <p:input port="insertion">
                                                    <p:pipe port="result" step="expected"/>
                                                </p:input>
                                            </p:insert>
                                        </p:group>
                                        
                                    </p:when>

                                    <p:when test="/x:expect[@type='validate' and @grammar='relax-ng']">
                                        <!--
                                            TODO:
                                            add support for Relax NG validation
                                            skip validation when Relax NG validation is not supported and display a warning instead
                                        -->
                                        <p:identity>
                                            <p:input port="source">
                                                <p:inline>
                                                    <x:test-result result="skipped">
                                                        <x:was>Relax NG validation is not implemented yet.</x:was>
                                                    </x:test-result>
                                                </p:inline>
                                            </p:input>
                                        </p:identity>
                                    </p:when>

                                    <p:when test="/x:expect[@type='validate' and @grammar='schematron']">
                                        <!--
                                            TODO:
                                            add support for Schematron validation
                                            skip validation when Schematron validation is not supported and display a warning instead
                                        -->
                                        <p:identity>
                                            <p:input port="source">
                                                <p:inline>
                                                    <x:test-result result="skipped">
                                                        <x:was>Schematron validation is not implemented yet.</x:was>
                                                    </x:test-result>
                                                </p:inline>
                                            </p:input>
                                        </p:identity>
                                    </p:when>

                                    <p:when test="/x:expect[@type='validate' and @grammar='xml-schema']">
                                        <!--
                                            TODO:
                                            add support for XML Schema validation
                                            skip validation when XML Schema validation is not supported and display a warning instead
                                        -->
                                        <p:identity>
                                            <p:input port="source">
                                                <p:inline>
                                                    <x:test-result result="skipped">
                                                        <x:was>XML Schema validation is not implemented yet.</x:was>
                                                    </x:test-result>
                                                </p:inline>
                                            </p:input>
                                        </p:identity>
                                    </p:when>

                                    <p:otherwise>
                                        <p:identity>
                                            <!-- this should not happen since the description document is already validated; XProc requires a p:otherwise though... -->
                                            <p:input port="source">
                                                <p:inline>
                                                    <x:test-result result="failed">
                                                        <x:was>Unknown assertion type.</x:was>
                                                    </x:test-result>
                                                </p:inline>
                                            </p:input>
                                        </p:identity>
                                    </p:otherwise>
                                </p:choose>

                                <p:set-attributes match="/*">
                                    <p:input port="attributes">
                                        <p:pipe port="current" step="assertions"/>
                                    </p:input>
                                </p:set-attributes>
                                <p:add-attribute match="/*" attribute-name="contextref">
                                    <p:with-option name="attribute-value" select="/*/@contextref">
                                        <p:pipe port="result" step="assertion"/>
                                    </p:with-option>
                                </p:add-attribute>
                            </p:for-each>
                        </p:for-each>
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
                    <p:add-attribute match="/*" attribute-name="xml:base">
                        <p:with-option name="attribute-value" select="base-uri(/*)"/>
                    </p:add-attribute>
                    <p:xslt>
                        <!-- create missing namespaces in c:error/@code (see https://github.com/ndw/xmlcalabash1/issues/107) -->
                        <p:input port="parameters">
                            <p:empty/>
                        </p:input>
                        <p:input port="stylesheet">
                            <p:document href="calabash-issue-107.xsl"/>
                        </p:input>
                    </p:xslt>
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
