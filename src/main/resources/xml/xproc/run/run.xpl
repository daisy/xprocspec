<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" type="pxi:test-run" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc-internal/xprocspec"
    exclude-inline-prefixes="#all" version="1.0" xpath-version="2.0" xmlns:pkg="http://expath.org/ns/pkg" xmlns:x="http://www.daisy.org/ns/pipeline/xproc/test">

    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="true"/>
    <p:option name="depend-on-stored-files" select="''"/>

    <!-- This version of run.xpl depends on Calabash and its cx:eval. Hopefully dynamic evaluation of pipelines will be included in XProc v2. -->

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

    <p:for-each>
        <p:load name="test">
            <p:with-option name="href" select="/*"/>
        </p:load>
        <p:choose>
            <p:when test="/*[self::c:errors]">
                <p:identity/>
            </p:when>
            <p:otherwise>
                <p:variable name="test-href" select="(//x:description)[1]/@test-base-uri"/>
                <p:identity name="try.input"/>
                <p:try>
                    <p:group>
                        <cx:eval>
                            <p:input port="pipeline">
                                <p:pipe port="result" step="test"/>
                            </p:input>
                            <p:input port="source">
                                <p:empty/>
                            </p:input>
                            <p:input port="options">
                                <p:empty/>
                            </p:input>
                        </cx:eval>
                        <p:identity name="test-output"/>
                        
                        <p:identity>
                            <p:input port="source">
                                <p:pipe port="result" step="test"/>
                            </p:input>
                        </p:identity>
                        <p:xslt name="option-evaluation">
                            <p:input port="parameters">
                                <p:empty/>
                            </p:input>
                            <p:input port="stylesheet">
                                <p:document href="invocation-to-option-evaluation.xsl"/>
                            </p:input>
                        </p:xslt>
                        <cx:eval name="options-and-parameters">
                            <p:input port="pipeline">
                                <p:pipe port="result" step="option-evaluation"/>
                            </p:input>
                            <p:input port="source">
                                <p:empty/>
                            </p:input>
                            <p:input port="options">
                                <p:empty/>
                            </p:input>
                        </cx:eval>
                        <p:identity>
                            <p:input port="source">
                                <p:pipe port="result" step="test-output"/>
                            </p:input>
                        </p:identity>
                        <p:viewport match="//x:call/x:option">
                            <p:variable name="name" select="/*/@name"/>
                            <p:add-attribute match="/*" attribute-name="value">
                                <p:with-option name="attribute-value" select="/*/c:options/@*[name()=$name]">
                                    <p:pipe port="result" step="options-and-parameters"/>
                                </p:with-option>
                            </p:add-attribute>
                        </p:viewport>
                        <p:viewport match="//x:call/x:param">
                            <p:variable name="name" select="/*/@name"/>
                            <p:add-attribute match="/*" attribute-name="value">
                                <p:with-option name="attribute-value" select="/*/c:params/@*[name()=$name]">
                                    <p:pipe port="result" step="options-and-parameters"/>
                                </p:with-option>
                            </p:add-attribute>
                        </p:viewport>
                        <p:wrap-sequence wrapper="calabash-issue-102"/>
                    </p:group>
                    <p:catch name="catch">
                        <p:identity>
                            <p:input port="source">
                                <p:pipe step="catch" port="error"/>
                            </p:input>
                        </p:identity>
                        <p:add-attribute match="/*" attribute-name="xml:base">
                            <p:with-option name="attribute-value" select="$test-href"/>
                        </p:add-attribute>
                        <p:add-attribute match="/*" attribute-name="error-location" attribute-value="run.xpl - dynamic evaluation"/>
                        
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
                
                <p:identity name="try.input.2"/>
                <p:try>
                    <p:group>
                        <!-- validate output grammar -->
                        <p:validate-with-relax-ng>
                            <p:input port="schema">
                                <p:document href="../../schema/xprocspec.run.rng"/>
                            </p:input>
                        </p:validate-with-relax-ng>
                        
                        <p:wrap-sequence wrapper="calabash-issue-102"/>
                    </p:group>
                    <p:catch name="catch">
                        <p:identity>
                            <p:input port="source">
                                <p:pipe step="catch" port="error"/>
                            </p:input>
                        </p:identity>
                        <p:add-attribute match="/*" attribute-name="xml:base">
                            <p:with-option name="attribute-value" select="$test-href"/>
                        </p:add-attribute>
                        <p:add-attribute match="/*" attribute-name="error-location" attribute-value="run.xpl - validation of output grammar"/>
                        
                        <p:identity name="errors-without-was"/>
                        <p:wrap-sequence wrapper="x:was">
                            <p:input port="source">
                                <p:pipe port="result" step="try.input.2"/>
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
    </p:for-each>

</p:declare-step>
