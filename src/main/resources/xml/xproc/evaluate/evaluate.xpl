<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" type="px:test-evaluate" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    exclude-inline-prefixes="#all" version="1.0" xpath-version="2.0" xmlns:pkg="http://expath.org/ns/pkg" xmlns:x="http://www.daisy.org/ns/pipeline/xproc/test">

    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="true"/>

    <p:import href="compare.xpl"/>
    <p:import href="../utils/load.xpl"/>
    <p:import href="../utils/recursive-directory-list.xpl"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

    <p:for-each>
        <!-- for each scenario -->
        
        <p:variable name="base" select="base-uri(/*)"/>
        
        <p:choose>
            <p:when test="/*[self::c:errors]">
                <p:identity name="c-error"/>
                <p:wrap-sequence wrapper="x:description"/>
                <p:wrap-sequence wrapper="x:scenario-results" name="without-test-result"/>
                <p:wrap-sequence wrapper="c:was">
                    <p:input port="source">
                        <p:pipe port="result" step="c-error"/>
                    </p:input>
                </p:wrap-sequence>
                <p:wrap-sequence wrapper="x:test-result"/>
                <p:add-attribute match="/*" attribute-name="result" attribute-value="false"/>
                <p:add-attribute match="/*" attribute-name="test-type" attribute-value="compile"/>
                <p:add-attribute match="/*" attribute-name="label">
                    <p:with-option name="attribute-value" select="concat('Compilation error: ',/*/*/*/@xml:base)"/>
                </p:add-attribute>
                <p:identity name="test-result"/>
                <p:insert position="last-child" match="/*">
                    <p:input port="source">
                        <p:pipe port="result" step="without-test-result"/>
                    </p:input>
                    <p:input port="insertion">
                        <p:pipe port="result" step="test-result"/>
                    </p:input>
                </p:insert>
            </p:when>
            <p:otherwise>
                <p:variable name="temp-dir" select="/*/@temp-dir"/>
                
                <p:identity name="description"/>
                <p:for-each name="test">
                    <!-- for each test in the scenario -->
                    <p:iteration-source select="/x:description/x:scenario/x:expect"/>

                    <p:group name="context">
                        <p:output port="result" sequence="true"/>
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
                                <px:xprocspec-directory-list>
                                    <p:with-option name="path" select="resolve-uri(/*/@directory,if (/*/@base-uri='temp-dir') then $temp-dir else base-uri(/*))"/>
                                    <p:with-option name="depth" select="if (/*/@recursive='true') then '-1' else '0'"/>
                                </px:xprocspec-directory-list>
                                <p:delete match="//*/@xml:base"/>
                            </p:when>
                            <p:when test="/*/@directory-info">
                                <!-- TODO: use calabash extension step, possibly rename to non-calabash namespace -->
                                <p:identity>
                                    <p:input port="source">
                                        <p:inline>
                                            <c:body>TODO: directory-info</c:body>
                                        </p:inline>
                                    </p:input>
                                </p:identity>
                            </p:when>
                            <p:when test="/*/@file">
                                <px:xprocspec-load>
                                    <p:with-option name="href" select="resolve-uri((/*/@file,/*/@href)[1],if (/*/@base-uri='temp-dir') then $temp-dir else base-uri(/*))"/>
                                    <p:with-option name="method" select="(/*/@method,'xml')[1]"/>
                                </px:xprocspec-load>
                            </p:when>
                            <p:when test="/*/@file-info">
                                <!-- TODO: use calabash extension step, possibly rename to non-calabash namespace -->
                                <p:identity>
                                    <p:input port="source">
                                        <p:inline>
                                            <c:body>TODO: file-info</c:body>
                                        </p:inline>
                                    </p:input>
                                </p:identity>
                            </p:when>
                            <p:when test="/*/@error">
                                <p:identity>
                                    <p:input port="source" select="/x:description/c:errors">
                                        <p:pipe port="result" step="description"/>
                                    </p:input>
                                </p:identity>
                            </p:when>
                            <p:otherwise>
                                <p:identity>
                                    <p:input port="source">
                                        <p:empty/>
                                    </p:input>
                                </p:identity>
                            </p:otherwise>
                        </p:choose>
                    </p:group>

                    <p:identity>
                        <p:input port="source">
                            <p:pipe port="current" step="test"/>
                        </p:input>
                    </p:identity>

                    <p:choose>
                        <p:when test="/*[@test]">
                            <!-- evaluate @test against context -->
                            <p:variable name="test" select="/*/@test"/>

                            <!-- the XPath expression must evalutate to true() for all documents on the output port, and there must be at least one document on the output port -->
                            <p:for-each>
                                <p:iteration-source>
                                    <p:pipe port="result" step="context"/>
                                </p:iteration-source>
                                <p:filter>
                                    <p:with-option name="select" select="concat('if (',$test,') then /* else /*[false()]')"/>
                                    <!--<p:input port="source">
                                        <p:pipe port="result" step="output-port"/>
                                    </p:input>-->
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
                                <p:wrap-sequence wrapper="c:was" name="was">
                                    <p:input port="source">
                                        <p:pipe port="result" step="context"/>
                                    </p:input>
                                </p:wrap-sequence>

                                <p:string-replace match="/*/text()" name="expected">
                                    <p:with-option name="replace" select="concat('&quot;',$test,'&quot;')"/>
                                    <p:input port="source">
                                        <p:inline>
                                            <c:expected>EXPECTED</c:expected>
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
                                <p:wrap-sequence wrapper="c:was" name="was">
                                    <p:input port="source">
                                        <p:pipe port="result" step="context"/>
                                    </p:input>
                                </p:wrap-sequence>

                                <p:string-replace match="/*/text()" name="expected">
                                    <p:with-option name="replace" select="concat('&quot;',$error,'&quot;')"/>
                                    <p:input port="source">
                                        <p:inline>
                                            <c:expected>EXPECTED</c:expected>
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
                                        <px:xprocspec-directory-list>
                                            <p:with-option name="path" select="resolve-uri(/*/@directory,if (/*/@base-uri='temp-dir') then $temp-dir else base-uri(/*))"/>
                                            <p:with-option name="depth" select="if (/*/@recursive='true') then '-1' else '0'"/>
                                        </px:xprocspec-directory-list>
                                        <p:delete match="//*/@xml:base"/>
                                    </p:when>
                                    <p:when test="/*/@directory-info">
                                        <!-- TODO: use calabash extension step, possibly rename to non-calabash namespace -->
                                        <p:identity>
                                            <p:input port="source">
                                                <p:inline>
                                                    <c:body>TODO: directory-info</c:body>
                                                </p:inline>
                                            </p:input>
                                        </p:identity>
                                    </p:when>
                                    <p:when test="/*/@file">
                                        <px:xprocspec-load>
                                            <p:with-option name="href" select="resolve-uri((/*/@file,/*/@href)[1],if (/*/@base-uri='temp-dir') then $temp-dir else base-uri(/*))"/>
                                            <p:with-option name="method" select="(/*/@method,'xml')[1]"/>
                                        </px:xprocspec-load>
                                    </p:when>
                                    <p:when test="/*/@file-info">
                                        <!-- TODO: use calabash extension step, possibly rename to non-calabash namespace -->
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

                            <px:compare>
                                <p:input port="source">
                                    <p:pipe port="result" step="context"/>
                                </p:input>
                                <p:input port="alternate">
                                    <p:pipe port="result" step="expect"/>
                                </p:input>
                            </px:compare>

                            <p:add-attribute match="/*" attribute-name="test-type" attribute-value="xml"/>
                        </p:otherwise>
                    </p:choose>
                    <p:rename match="/*" new-name="x:test-result"/>
                    <p:set-attributes match="/*">
                        <p:input port="attributes">
                            <p:pipe port="current" step="test"/>
                        </p:input>
                    </p:set-attributes>
                </p:for-each>

                <p:wrap-sequence wrapper="x:scenario-results"/>
                <p:insert match="/*" position="first-child">
                    <p:input port="insertion">
                        <p:pipe port="result" step="description"/>
                    </p:input>
                </p:insert>
            </p:otherwise>
        </p:choose>
        
        <!-- validate output grammar -->
        <p:for-each>
            <p:try>
                <p:group>
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
                    <p:wrap-sequence wrapper="calabash-issue-102"/>
                </p:catch>
            </p:try>
            <p:for-each>
                <!-- temporary fix for https://github.com/ndw/xmlcalabash1/issues/102 -->
                <p:iteration-source select="/calabash-issue-102/*"/>
                <p:identity/>
            </p:for-each>
        </p:for-each>
        
    </p:for-each>

</p:declare-step>
